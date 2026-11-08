#!/usr/bin/env python3
"""Oracle Always Free 保活守护进程（单文件）。

目的：让 OCI Always Free 实例在 7 天滚动窗口的闲置判定下持续被判为"非闲置"，
避免被回收。OCI 同时检查 CPU / 网络（内存仅 A1），只要任一指标越过阈值即非闲置；
本程序同时温和地维持 CPU 与网络两项，留足冗余。

设计要点：
  * CPU：周期性"占空比突发"，让某分钟的均值越过 20%（跨 2 vCPU 计）。默认极省，
    平均 CPU 仅 ~4%。系统本身忙（如 colcon 构建）时自动跳过，绝不挤占主业务。
  * 网络：只发 GET、低速限流、轮换公共测速文件，把入站流量均匀铺满时间轴。
    出站仅请求头（可忽略），规避 egress 上限与 abuse。
  * 仅标准库，无外部依赖。所有可调参数集中在下方 CONFIG。

用法：
  keepalive.py run      # systemd 调用，前台常驻
  keepalive.py status   # 打印运行摘要与对照阈值的余量
"""

import json
import os
import random
import signal
import socket
import sys
import threading
import time
import urllib.request
from multiprocessing import Process

# ---------------------------------------------------------------------------
# 配置：直接改这里，然后 `systemctl restart oracle-keepalive`
# ---------------------------------------------------------------------------
CONFIG = {
    "cpu": {
        "enabled": True,
        "interval_sec": 600,        # 两次突发之间的间隔
        "burst_sec": 90,            # 单次突发时长（>60 保证盖满 ≥1 个 1 分钟桶）
        "duty_cycle": 0.55,         # 单 worker 的占空比；1 worker→~27% 总 CPU(2 vCPU)
        "workers": 1,               # 并发负载进程数（E2.1.Micro 用 1 即足够）
        "skip_if_system_busy": True,
        "busy_threshold_pct": 25,   # 系统总 CPU 已高于此 → 跳过本次突发
        "nice": 19,                 # 负载进程的 nice 值，让位主业务
        "jitter_sec": 30,           # 间隔上叠加的随机抖动，曲线更自然
    },
    "network": {
        "enabled": True,
        "interval_sec": 300,        # 两次下载之间的间隔
        "bytes_per_fetch": 10 * 1024 * 1024,   # 每次最多收 10 MB（读够即断开）
        "rate_limit_bps": 64 * 1024,           # 限速 64 KB/s → 拉成均匀低速流
        "jitter_sec": 60,
        "skip_if_recent_traffic": False,        # 近期入站速率已高则跳过
        "recent_traffic_threshold_bps": 32 * 1024,
        "timeout_sec": 60,
        # 公共测速文件，轮换使用；读够 bytes_per_fetch 即主动断开，故文件大小无所谓
        "urls": [
            "https://speed.cloudflare.com/__down?bytes=10485760",
            "https://proof.ovh.net/files/100Mb.dat",
            "http://speedtest.tele2.net/100MB.zip",
            "http://ipv4.download.thinkbroadband.com/100MB.zip",
        ],
        "user_agent": "oracle-keepalive/1.0 (+self-use; keepalive only)",
    },
    # ARM/A1 才需要；AMD E2.1.Micro 不计内存，故默认关闭。本期为 stub。
    "memory": {"enabled": False, "target_pct": 25},
    "state": {
        "path": os.environ.get(
            "STATE_DIRECTORY", "/var/lib/oracle-keepalive"
        ).split(":")[0] + "/state.json",
        "write_interval_sec": 60,
    },
}

WINDOW_SEC = 7 * 24 * 3600          # 闲置判定窗口：7 天
P95_REQUIRED_MINUTES = 504          # 7 天 10080 分钟的 5% → p95≥阈值所需的合格分钟下限


# ---------------------------------------------------------------------------
# 日志（stdout → journald）
# ---------------------------------------------------------------------------
def log(level, msg):
    print(f"[{level}] {msg}", flush=True)


# ---------------------------------------------------------------------------
# sd_notify（READY / WATCHDOG），无 systemd 时静默 no-op
# ---------------------------------------------------------------------------
def sd_notify(state):
    addr = os.environ.get("NOTIFY_SOCKET")
    if not addr:
        return
    if addr.startswith("@"):
        addr = "\0" + addr[1:]
    try:
        with socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM) as s:
            s.connect(addr)
            s.sendall(state.encode())
    except OSError:
        pass


# ---------------------------------------------------------------------------
# /proc 采样
# ---------------------------------------------------------------------------
def _read_cpu_times():
    with open("/proc/stat") as f:
        parts = f.readline().split()
    nums = [int(x) for x in parts[1:]]
    idle = nums[3] + (nums[4] if len(nums) > 4 else 0)  # idle + iowait
    return sum(nums), idle


def system_cpu_pct(interval=0.5):
    """返回当前系统总 CPU 利用率百分比（跨所有 vCPU）。"""
    t1, i1 = _read_cpu_times()
    time.sleep(interval)
    t2, i2 = _read_cpu_times()
    dt = t2 - t1
    if dt <= 0:
        return 0.0
    return 100.0 * (1.0 - (i2 - i1) / dt)


def _read_rx_bytes():
    total = 0
    with open("/proc/net/dev") as f:
        for line in f.readlines()[2:]:
            iface, _, rest = line.partition(":")
            if iface.strip() == "lo":
                continue
            total += int(rest.split()[0])  # 第 1 个字段是 rx bytes
    return total


def recent_rx_bps(interval=1.0):
    b1 = _read_rx_bytes()
    time.sleep(interval)
    b2 = _read_rx_bytes()
    return max(0, b2 - b1) / interval


# ---------------------------------------------------------------------------
# 共享状态（线程安全，原子落盘，跨重启保留 7 天历史）
# ---------------------------------------------------------------------------
class State:
    def __init__(self, path):
        self.path = path
        self.lock = threading.Lock()
        self.data = {
            "start_time": time.time(),
            "cpu_burst_ts": [],     # 各次突发的时间戳（仅留 7 天内）
            "cpu_bursts_total": 0,
            "cpu_skips": 0,
            "last_cpu_burst": None,
            "net_fetch_log": [],    # [ts, bytes] 仅留 7 天内
            "net_fetches_total": 0,
            "net_bytes_total": 0,
            "net_skips": 0,
            "last_net_fetch": None,
        }
        self._load()

    def _load(self):
        try:
            with open(self.path) as f:
                disk = json.load(f)
            # 保留历史，但本次进程的 start_time 用当前时间
            for k in ("cpu_burst_ts", "cpu_bursts_total", "cpu_skips",
                      "last_cpu_burst", "net_fetch_log", "net_fetches_total",
                      "net_bytes_total", "net_skips", "last_net_fetch"):
                if k in disk:
                    self.data[k] = disk[k]
            log("info", f"已加载历史状态：{self.path}")
        except (OSError, ValueError):
            log("info", "无历史状态，从空白开始")

    def _prune(self, now):
        cutoff = now - WINDOW_SEC
        self.data["cpu_burst_ts"] = [t for t in self.data["cpu_burst_ts"] if t >= cutoff]
        self.data["net_fetch_log"] = [e for e in self.data["net_fetch_log"] if e[0] >= cutoff]

    def record_cpu_burst(self):
        now = time.time()
        with self.lock:
            self.data["cpu_burst_ts"].append(now)
            self.data["cpu_bursts_total"] += 1
            self.data["last_cpu_burst"] = now
            self._prune(now)

    def record_cpu_skip(self):
        with self.lock:
            self.data["cpu_skips"] += 1

    def record_net_fetch(self, nbytes):
        now = time.time()
        with self.lock:
            self.data["net_fetch_log"].append([now, nbytes])
            self.data["net_fetches_total"] += 1
            self.data["net_bytes_total"] += nbytes
            self.data["last_net_fetch"] = now
            self._prune(now)

    def record_net_skip(self):
        with self.lock:
            self.data["net_skips"] += 1

    def flush(self):
        with self.lock:
            self._prune(time.time())
            snapshot = json.dumps(self.data)
        tmp = self.path + ".tmp"
        try:
            with open(tmp, "w") as f:
                f.write(snapshot)
            os.replace(tmp, self.path)
        except OSError as e:
            log("warn", f"状态落盘失败：{e}")


# ---------------------------------------------------------------------------
# CPU 负载：占空比忙循环（在子进程中跑，绕开 GIL，可真正多核）
# ---------------------------------------------------------------------------
def _cpu_burst_worker(duty, duration, nice):
    try:
        os.nice(nice)
    except OSError:
        pass
    slice_sec = 0.1
    busy_sec = slice_sec * duty
    end = time.monotonic() + duration
    while time.monotonic() < end:
        t0 = time.monotonic()
        spin_until = t0 + busy_sec
        x = 0
        while time.monotonic() < spin_until:
            x += 1  # 纯忙等，烧 CPU
        rest = slice_sec - (time.monotonic() - t0)
        if rest > 0:
            time.sleep(rest)


def cpu_loop(cfg, state, stop):
    while not stop.is_set():
        if cfg["skip_if_system_busy"]:
            cur = system_cpu_pct(0.5)
            if cur >= cfg["busy_threshold_pct"]:
                state.record_cpu_skip()
                log("info", f"CPU 突发跳过：系统已忙 {cur:.0f}% ≥ {cfg['busy_threshold_pct']}%")
                _interruptible_wait(stop, cfg["interval_sec"], cfg["jitter_sec"])
                continue
        procs = [
            Process(target=_cpu_burst_worker,
                    args=(cfg["duty_cycle"], cfg["burst_sec"], cfg["nice"]))
            for _ in range(max(1, cfg["workers"]))
        ]
        for p in procs:
            p.start()
        deadline = time.monotonic() + cfg["burst_sec"] + 10
        for p in procs:
            p.join(timeout=max(1, deadline - time.monotonic()))
            if p.is_alive():
                p.terminate()
        state.record_cpu_burst()
        log("info", f"CPU 突发完成：{cfg['workers']}×{cfg['duty_cycle']:.0%} / {cfg['burst_sec']}s")
        _interruptible_wait(stop, cfg["interval_sec"], cfg["jitter_sec"])


# ---------------------------------------------------------------------------
# 网络负载：限速、轮换、只收不发
# ---------------------------------------------------------------------------
def download(url, max_bytes, rate_bps, timeout, ua, stop):
    req = urllib.request.Request(url, headers={"User-Agent": ua})
    got = 0
    start = time.monotonic()
    chunk = 16 * 1024
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        while got < max_bytes and not stop.is_set():
            want = min(chunk, max_bytes - got)
            data = resp.read(want)
            if not data:
                break
            got += len(data)  # 读完即丢弃
            if rate_bps > 0:
                expected = got / rate_bps
                ahead = expected - (time.monotonic() - start)
                if ahead > 0:
                    time.sleep(min(ahead, 2.0))
    return got


def net_loop(cfg, state, stop):
    idx = 0
    urls = cfg["urls"]
    while not stop.is_set():
        if cfg["skip_if_recent_traffic"]:
            bps = recent_rx_bps(1.0)
            if bps >= cfg["recent_traffic_threshold_bps"]:
                state.record_net_skip()
                log("info", f"下载跳过：近期入站已 {bps/1024:.0f} KB/s")
                _interruptible_wait(stop, cfg["interval_sec"], cfg["jitter_sec"])
                continue
        url = urls[idx % len(urls)]
        idx += 1
        try:
            n = download(url, cfg["bytes_per_fetch"], cfg["rate_limit_bps"],
                         cfg["timeout_sec"], cfg["user_agent"], stop)
            state.record_net_fetch(n)
            log("info", f"下载完成：{n/1024/1024:.1f} MB @ {cfg['rate_limit_bps']/1024:.0f} KB/s ← {url}")
        except Exception as e:  # noqa: BLE001 — 任何网络异常都不应弄垮守护进程
            state.record_net_skip()
            log("warn", f"下载失败（将轮换下一个源）：{url} — {e}")
        _interruptible_wait(stop, cfg["interval_sec"], cfg["jitter_sec"])


# ---------------------------------------------------------------------------
# 内存负载（ARM/A1 用，本期 stub）
# ---------------------------------------------------------------------------
def mem_loop(cfg, state, stop):
    log("warn", "内存模块已启用但本期未实现，忽略（AMD 无需，ARM 再补）")


# ---------------------------------------------------------------------------
# 工具
# ---------------------------------------------------------------------------
def _interruptible_wait(stop, base, jitter):
    delay = base + random.uniform(0, max(0, jitter))
    stop.wait(delay)


def state_loop(state, stop, interval):
    last_wd = 0.0
    wd_period = _watchdog_period()
    while not stop.is_set():
        state.flush()
        if wd_period and time.monotonic() - last_wd >= wd_period:
            sd_notify("WATCHDOG=1")
            last_wd = time.monotonic()
        stop.wait(min(interval, wd_period or interval))
    state.flush()


def _watchdog_period():
    usec = os.environ.get("WATCHDOG_USEC")
    if not usec:
        return 0
    try:
        return max(1.0, int(usec) / 1e6 / 2.0)  # 每半个看门狗周期喂一次
    except ValueError:
        return 0


# ---------------------------------------------------------------------------
# run / status
# ---------------------------------------------------------------------------
def cmd_run():
    state = State(CONFIG["state"]["path"])
    stop = threading.Event()

    def handle(signum, _frame):
        log("info", f"收到信号 {signum}，准备退出")
        stop.set()

    signal.signal(signal.SIGTERM, handle)
    signal.signal(signal.SIGINT, handle)

    threads = []
    if CONFIG["cpu"]["enabled"]:
        threads.append(threading.Thread(target=cpu_loop, args=(CONFIG["cpu"], state, stop), daemon=True))
    if CONFIG["network"]["enabled"]:
        threads.append(threading.Thread(target=net_loop, args=(CONFIG["network"], state, stop), daemon=True))
    if CONFIG["memory"]["enabled"]:
        threads.append(threading.Thread(target=mem_loop, args=(CONFIG["memory"], state, stop), daemon=True))
    threads.append(threading.Thread(
        target=state_loop, args=(state, stop, CONFIG["state"]["write_interval_sec"]), daemon=True))

    for t in threads:
        t.start()
    log("info", f"oracle-keepalive 启动：cpu={CONFIG['cpu']['enabled']} "
                 f"net={CONFIG['network']['enabled']} mem={CONFIG['memory']['enabled']}")
    sd_notify("READY=1")

    while not stop.is_set():
        stop.wait(1.0)
    sd_notify("STOPPING=1")
    log("info", "已停止")


def _fmt_ago(ts):
    if not ts:
        return "从未"
    d = time.time() - ts
    if d < 60:
        return f"{d:.0f} 秒前"
    if d < 3600:
        return f"{d/60:.0f} 分钟前"
    return f"{d/3600:.1f} 小时前"


def cmd_status():
    path = CONFIG["state"]["path"]
    try:
        with open(path) as f:
            d = json.load(f)
    except (OSError, ValueError):
        print(f"无法读取状态文件：{path}\n（服务可能尚未运行）")
        return 1

    now = time.time()
    cutoff = now - WINDOW_SEC
    burst_ts = [t for t in d.get("cpu_burst_ts", []) if t >= cutoff]
    net_log = [e for e in d.get("net_fetch_log", []) if e[0] >= cutoff]
    qualifying_min = len(burst_ts)  # 每次突发保守计为 ≥1 个合格分钟
    bytes_7d = sum(e[1] for e in net_log)

    print("=== oracle-keepalive 状态 ===")
    print(f"状态文件        : {path}")
    print()
    print("CPU（目标：7 天 p95 ≥ 20%）")
    print(f"  7 天内突发     : {len(burst_ts)} 次")
    print(f"  估算合格分钟   : ~{qualifying_min} / 需 ≥ {P95_REQUIRED_MINUTES}  "
          f"{'✅ 余量充足' if qualifying_min >= P95_REQUIRED_MINUTES else '⚠️ 偏低，累积中或调小 interval'}")
    print(f"  累计突发/跳过  : {d.get('cpu_bursts_total', 0)} / {d.get('cpu_skips', 0)}")
    print(f"  最近一次突发   : {_fmt_ago(d.get('last_cpu_burst'))}")
    print()
    print("网络（目标：入站持续、均匀、小流量）")
    print(f"  7 天入站总量   : {bytes_7d/1024/1024/1024:.2f} GB（{len(net_log)} 次下载）")
    print(f"  日均入站       : {bytes_7d/1024/1024/7:.0f} MB/天")
    print(f"  累计下载/跳过  : {d.get('net_fetches_total', 0)} / {d.get('net_skips', 0)}")
    print(f"  最近一次下载   : {_fmt_ago(d.get('last_net_fetch'))}")
    return 0


def main():
    cmd = sys.argv[1] if len(sys.argv) > 1 else "run"
    if cmd == "run":
        cmd_run()
    elif cmd == "status":
        sys.exit(cmd_status())
    else:
        print(__doc__)
        print(f"未知命令：{cmd}", file=sys.stderr)
        sys.exit(2)


if __name__ == "__main__":
    main()
