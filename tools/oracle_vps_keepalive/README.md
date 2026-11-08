# Oracle VPS 保活

从 `ubuntu@vps-sg.showmethemoney.top` 复制的部署文件：

- `keepalive.py`：周期性 CPU 负载与限速下载，使用 Python 3 标准库。
- `oracle-keepalive.service`：systemd 服务，开机启动、自动重启、资源限制与权限隔离。

## 安装到其他主机

目标主机需安装 Python 3、使用 systemd，并允许访问脚本中配置的下载源。
在本地执行（将主机名替换为目标主机）：

```sh
scp keepalive.py oracle-keepalive.service ubuntu@YOUR_HOST:/tmp/
ssh ubuntu@YOUR_HOST
```

然后在目标主机执行：

```sh
id oracle-keepalive >/dev/null 2>&1 || sudo useradd --system --no-create-home --shell /usr/sbin/nologin oracle-keepalive
sudo install -d -m 0755 /opt/oracle-keepalive
sudo install -m 0755 /tmp/keepalive.py /opt/oracle-keepalive/keepalive.py
sudo install -m 0644 /tmp/oracle-keepalive.service /etc/systemd/system/oracle-keepalive.service
sudo systemctl daemon-reload
sudo systemctl enable --now oracle-keepalive
```

## 配置与查看

修改 `/opt/oracle-keepalive/keepalive.py` 顶部的 `CONFIG`，然后执行：

```sh
sudo systemctl restart oracle-keepalive
systemctl status oracle-keepalive --no-pager
python3 /opt/oracle-keepalive/keepalive.py status
sudo journalctl -u oracle-keepalive -n 30 --no-pager
```

默认配置：

- CPU：1 个 worker，以 55% 占空比运行 90 秒，然后等待 600～630 秒；系统总 CPU 达到 25% 时跳过。
- 网络：每次最多下载 10 MiB，限速 64 KiB/s，完成后等待 300～360 秒；轮换公共测速源，数据不写入文件。
- 服务限制：CPUQuota=70%（以一个 CPU 为基准）、MemoryMax=200M、Nice=19。
- 状态保存在 `/var/lib/oracle-keepalive/state.json`，由 systemd 创建目录。
- 内存负载默认关闭，当前仅为占位实现。

脚本针对原主机配置；其他 CPU 核数和实例规格应调整参数。脚本的状态输出是本地估算，不能证明满足云平台当前的闲置回收条件。

## 停止与取消开机启动

```sh
sudo systemctl disable --now oracle-keepalive
```
