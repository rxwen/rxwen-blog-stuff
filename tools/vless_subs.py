#!/usr/bin/env python3
# =============================================================================
# vless_subs.py - central manager for multi-VPS VLESS subscriptions
#
# Each VPS is provisioned independently by setup_vless_caddy_sub.sh and serves a
# subscription over HTTP/HTTPS from /etc/caddy/sub/{base64.txt,clash.yaml}.
# Out of the box each subscription lists only that VPS's own node. This tool
# keeps a registry of ALL nodes on your laptop, regenerates the two subscription
# files containing every node, and pushes them to every VPS so all subscriptions
# stay identical.
#
# Source of truth (default <repo>/vless-subs/; contains UUIDs = credentials, so
# keep it out of git. Override the location with the VLESS_SUBS_HOME env var):
#     nodes/<name>.conf    one per node:  SSH=<target>  and  URL=vless://...
#     out/base64.txt       generated
#     out/clash.yaml       generated
#
# A node is fully described by its VLESS URL (uuid, ip, sni, pbk, sid, ...), so
# the registry only stores that URL plus an SSH target for syncing.
#
# Caddy serves the files via file_server with Cache-Control: no-cache, reading
# from disk on every request, so syncing the files is all that's needed - there
# is nothing to reload.
#
# Commands:
#   import <sub-url> [--ssh <target>]   register every node in a subscription
#   add <vless-url> [--ssh <target>]    register one node from its VLESS URL
#   update <vless-url> [--ssh <target>] refresh a node after a reinstall
#   remove <name>                       drop a node
#   list                                show registered nodes
#   gen                                 rebuild out/base64.txt + clash.yaml
#   sync                                rsync the files to every VPS
#
# import/add/update/remove auto-run gen and then print the exact `sync` command.
#
# Node info comes straight from the VLESS URL (printed by setup_vless_caddy_sub.sh
# for `add`/`update`, or fetched over HTTP by `import`). The subscription/URL
# carries no SSH info, so each node's sync target defaults to root@<server-ip>;
# override with --ssh or by editing nodes/<name>.conf.
# =============================================================================

import argparse
import base64
import os
import subprocess
import sys
import urllib.request
from datetime import datetime
from pathlib import Path
from urllib.parse import urlsplit, parse_qs, unquote

# Registry defaults to <repo>/vless-subs (anchored to this script, not the cwd).
# It holds UUIDs (= credentials), so keep it out of git. Override with the
# VLESS_SUBS_HOME env var (e.g. point it at a synced/backed-up directory).
DEFAULT_HOME = Path(__file__).resolve().parent.parent / "vless-subs"
REGISTRY = Path(os.environ.get("VLESS_SUBS_HOME", DEFAULT_HOME))
NODES_DIR = REGISTRY / "nodes"
OUT_DIR = REGISTRY / "out"
REMOTE_SUB_DIR = "/etc/caddy/sub"  # where Caddy serves the files on each VPS
PROG = os.path.basename(sys.argv[0]) or "vless_subs.py"  # for help/examples

# --- tiny color helpers -------------------------------------------------------
def _c(code, s):
    return s if not sys.stdout.isatty() else f"\033[{code}m{s}\033[0m"

def info(s):    print(_c("0;34", "[INFO]"), s)
def ok(s):      print(_c("0;32", "[OK]"), s)
def warn(s):    print(_c("1;33", "[WARN]"), s)
def die(s):     print(_c("0;31", "[ERROR]"), s); sys.exit(1)


# --- VLESS URL parsing --------------------------------------------------------
class Node:
    """A single VLESS node, parsed from its vless:// URL."""

    def __init__(self, url, ssh=""):
        self.url = url.strip()
        self.ssh = ssh.strip()
        if not self.url.startswith("vless://"):
            die(f"Not a VLESS URL: {self.url[:40]}...")
        parts = urlsplit(self.url)
        q = parse_qs(parts.query)
        self.uuid = unquote(parts.username or "")
        self.server = parts.hostname or ""
        self.port = parts.port or 443
        self.name = unquote(parts.fragment) or self.server

        def g(key, default=""):
            return q.get(key, [default])[0]

        self.flow = g("flow")
        self.sni = g("sni")
        self.pbk = g("pbk")
        self.sid = g("sid")
        self.fp = g("fp", "chrome")
        self.network = g("type", "tcp")
        self.security = g("security", "reality")
        if not (self.uuid and self.server and self.pbk):
            die(f"VLESS URL missing uuid/server/pbk: {self.url[:60]}...")

    def clash_proxy(self):
        """Render this node as a Clash (Mihomo) proxy block. Reality-only."""
        # Names may contain spaces / non-ASCII; quote to keep YAML valid.
        lines = [
            f'  - name: "{self.name}"',
            f"    type: vless",
            f"    server: {self.server}",
            f"    port: {self.port}",
            f"    uuid: {self.uuid}",
            f"    flow: {self.flow}",
            f"    tls: true",
            f"    network: {self.network}",
            f"    reality-opts:",
            f"      public-key: {self.pbk}",
            f"      short-id: {self.sid}",
            f"    servername: {self.sni}",
            f"    client-fingerprint: {self.fp}",
            f"    udp: true",
        ]
        return "\n".join(lines)


# --- registry I/O -------------------------------------------------------------
def conf_path(name):
    return NODES_DIR / f"{name}.conf"


def load_nodes():
    """Load all nodes from the registry, sorted by name for stable output."""
    NODES_DIR.mkdir(parents=True, exist_ok=True)
    nodes = []
    for conf in sorted(NODES_DIR.glob("*.conf")):
        data = {}
        for line in conf.read_text().splitlines():
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            k, _, v = line.partition("=")
            data[k.strip()] = v.strip()
        url = data.get("URL", "")
        if not url:
            warn(f"{conf.name}: no URL=, skipping")
            continue
        nodes.append(Node(url, data.get("SSH", "")))
    return nodes


def save_node(node):
    NODES_DIR.mkdir(parents=True, exist_ok=True)
    conf_path(node.name).write_text(
        f"# Managed by vless_subs.py\nSSH={node.ssh}\nURL={node.url}\n"
    )


# --- SSH target parsing (for sync) --------------------------------------------
def parse_ssh(target):
    """Split 'user@host:port' / 'user@host' / 'host' -> (rsync_target, port)."""
    port = None
    host = target
    # A ':' before any '@'-less host means port; only split a trailing :NNN.
    if ":" in target:
        head, _, tail = target.rpartition(":")
        if tail.isdigit():
            host, port = head, tail
    return host, port


# --- generation ---------------------------------------------------------------
CLASH_HEADER = """\
# Generated by vless_subs.py on {generated} - do not edit by hand.
mixed-port: 7890
allow-lan: false
mode: rule
log-level: warning

dns:
  enable: true
  nameserver:
    - 223.5.5.5
    - 119.29.29.29
  fallback:
    - 8.8.8.8
    - 1.1.1.1
"""

CLASH_RULES = """\
rules:
  - GEOIP,private,DIRECT,no-resolve
  - GEOSITE,cn,Direct
  - GEOIP,CN,Direct
  - MATCH,Proxy
"""


def build_base64(nodes):
    blob = "\n".join(n.url for n in nodes)
    return base64.b64encode(blob.encode()).decode()


def build_clash(nodes):
    names = [n.name for n in nodes]

    def yaml_list(items, indent):
        pad = " " * indent
        return "\n".join(f'{pad}- "{i}"' for i in items)

    proxies = "\n".join(n.clash_proxy() for n in nodes)
    header = CLASH_HEADER.format(
        generated=datetime.now().astimezone().strftime("%Y-%m-%d %H:%M:%S %Z")
    )

    groups = f"""\
proxy-groups:
  - name: "Proxy"
    type: select
    proxies:
      - "Auto"
{yaml_list(names, 6)}
      - "DIRECT"

  - name: "Auto"
    type: url-test
    url: http://www.gstatic.com/generate_204
    interval: 300
    proxies:
{yaml_list(names, 6)}

  - name: "Direct"
    type: select
    proxies:
      - "DIRECT"
      - "Proxy"
"""

    return f"{header}\nproxies:\n{proxies}\n\n{groups}\n{CLASH_RULES}"


def cmd_gen(_args):
    nodes = load_nodes()
    if not nodes:
        die("No nodes registered. Add one first: vless_subs.py add <ssh-target>")
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    (OUT_DIR / "base64.txt").write_text(build_base64(nodes))
    (OUT_DIR / "clash.yaml").write_text(build_clash(nodes))
    ok(f"Generated subscription for {len(nodes)} node(s) in {OUT_DIR}")
    for n in nodes:
        print(f"    - {n.name}  ({n.server})")
    return nodes


# --- sync ---------------------------------------------------------------------
def cmd_sync(_args):
    nodes = load_nodes()
    if not nodes:
        die("No nodes registered.")
    b64 = OUT_DIR / "base64.txt"
    clash = OUT_DIR / "clash.yaml"
    if not (b64.exists() and clash.exists()):
        info("Output files missing; generating first.")
        cmd_gen(_args)

    targets = [n for n in nodes if n.ssh]
    skipped = [n.name for n in nodes if not n.ssh]
    if skipped:
        warn(f"No SSH target for: {', '.join(skipped)} (won't receive files)")
    if not targets:
        die("No nodes have an SSH target; nothing to sync.")

    failures = []
    for n in targets:
        host, port = parse_ssh(n.ssh)
        cmd = ["rsync", "-az"]
        if port:
            cmd += ["-e", f"ssh -p {port}"]
        cmd += [str(b64), str(clash), f"{host}:{REMOTE_SUB_DIR}/"]
        info(f"Syncing -> {n.name} ({n.ssh})")
        rc = subprocess.run(cmd).returncode
        if rc != 0:
            failures.append(n.name)
            warn(f"rsync to {n.name} failed (exit {rc})")
    if failures:
        die(f"Sync failed for: {', '.join(failures)}")
    ok(f"Synced to {len(targets)} VPS. Caddy serves the new files immediately "
       "(no reload needed).")


# --- mutating commands --------------------------------------------------------
def _after_change():
    cmd_gen(None)
    print()
    ok("Registry updated. Push to all servers with:")
    print(f"    {sys.argv[0]} sync")


def fetch_sub_urls(sub_url):
    """GET a subscription URL and return the VLESS URLs it contains.

    Sends an okhttp User-Agent so the unified endpoint returns the base64 form
    (the explicit /base64 endpoint returns it regardless). Clash-YAML responses
    are rejected with a hint to use the base64 endpoint."""
    req = urllib.request.Request(sub_url, headers={"User-Agent": "okhttp"})
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            body = resp.read().decode().strip()
    except Exception as e:
        die(f"Could not fetch {sub_url}: {e}")
    # The body is base64 of newline-joined VLESS URLs. Tolerate missing padding.
    try:
        decoded = base64.b64decode(body + "=" * (-len(body) % 4)).decode()
    except Exception:
        decoded = body  # maybe already plain text
    urls = [u.strip() for u in decoded.splitlines() if u.strip().startswith("vless://")]
    if not urls:
        die(f"No VLESS URLs found at {sub_url}. Use the .../base64 endpoint?")
    return urls


def cmd_import(args):
    urls = fetch_sub_urls(args.url)
    if args.ssh and len(urls) > 1:
        die(f"--ssh applies to a single node, but {len(urls)} were found. "
            "Import without --ssh (defaults to root@<ip>) and edit confs as needed.")
    info(f"Found {len(urls)} node(s) in subscription.")
    for url in urls:
        node = Node(url)
        node.ssh = args.ssh or f"root@{node.server}"
        save_node(node)
        ok(f"Imported '{node.name}' ({node.server}), ssh={node.ssh}")
    _after_change()


def cmd_add(args):
    # The node is registered straight from its VLESS URL (printed by setup). The
    # SSH target is only needed for syncing; default it to root@<server-ip>.
    node = Node(args.url, ssh=args.ssh or "")
    if not node.ssh:
        node.ssh = f"root@{node.server}"
    if conf_path(node.name).exists():
        die(f"Node '{node.name}' already exists. Use 'update' to refresh it.")
    save_node(node)
    ok(f"Added '{node.name}' ({node.server}), ssh={node.ssh}")
    _after_change()


def cmd_update(args):
    node = Node(args.url)
    existing = {n.name: n for n in load_nodes()}
    if node.name not in existing:
        die(f"No node named '{node.name}'. Use 'add' to register it first.")
    # Keep the existing SSH target unless overridden (server IP may be unchanged).
    node.ssh = args.ssh or existing[node.name].ssh or f"root@{node.server}"
    save_node(node)
    ok(f"Updated '{node.name}' ({node.server}), ssh={node.ssh}")
    _after_change()


def cmd_remove(args):
    p = conf_path(args.name)
    if not p.exists():
        die(f"No such node: {args.name}")
    p.unlink()
    ok(f"Removed node '{args.name}'")
    _after_change()


def cmd_list(_args):
    nodes = load_nodes()
    if not nodes:
        info("No nodes registered.")
        return
    print(f"{'NAME':<24} {'SERVER':<18} SSH")
    for n in nodes:
        print(f"{n.name:<24} {n.server:<18} {n.ssh or '(none)'}")


# --- CLI ----------------------------------------------------------------------
MAIN_DESC = """\
Manage one shared VLESS subscription across many VPS.

Each VPS is set up independently by setup_vless_caddy_sub.sh and serves a
subscription from /etc/caddy/sub/. Out of the box each subscription lists only
that VPS's own node. This tool keeps a registry of ALL nodes on your laptop,
regenerates the subscription files containing every node, and pushes them to
every VPS so all subscriptions stay identical.

A node is fully described by its VLESS URL, so the registry just stores that URL
plus an SSH target (used only for pushing files). Caddy serves the files from
disk with no caching, so a push takes effect immediately - nothing to reload.
"""


def _epilog():
    return f"""\
Typical workflow
  # 1. Bootstrap from VPS you already have (fetch each one's subscription):
  {PROG} import http://<ip1>:8080/sub/<token1>/base64
  {PROG} import http://<ip2>:8080/sub/<token2>/base64
  {PROG} sync                       # push the merged all-nodes sub to every VPS

  # 2. Add a brand-new VPS later (paste the VLESS URL setup printed):
  {PROG} add 'vless://...#node-name'
  {PROG} sync

  # 3. A VPS was reinstalled (UUID / keys rotated) -> paste its new URL:
  {PROG} update 'vless://...#node-name'
  {PROG} sync

  # 4. Retire a node:
  {PROG} remove <name>
  {PROG} sync

Registry location
  Default: {REGISTRY}
  (holds UUIDs = credentials; keep it out of git)
  Override with the VLESS_SUBS_HOME environment variable.

SSH targets accept  host  /  user@host  /  user@host:port .
HTTP import can't discover SSH info, so it defaults each node to root@<ip>;
fix non-standard ones in nodes/<name>.conf or via `add`/`import --ssh`.
"""


def main():
    p = argparse.ArgumentParser(
        prog=PROG,
        description=MAIN_DESC,
        epilog=_epilog(),
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    sub = p.add_subparsers(dest="command", required=True, metavar="<command>")
    raw = argparse.RawDescriptionHelpFormatter  # for multi-line example epilogs

    pi = sub.add_parser(
        "import", help="register every node in a subscription URL",
        formatter_class=raw,
        description="Fetch a subscription URL and register every VLESS node in it.",
        epilog=f"Example:\n  {PROG} import http://1.2.3.4:8080/sub/<token>/base64\n"
               f"  {PROG} import https://sub.example.com:8443/sub/<token>/base64 --ssh root@1.2.3.4:2222",
    )
    pi.add_argument("url", help="subscription URL (the .../base64 endpoint is most reliable)")
    pi.add_argument("--ssh", help="SSH target for the node (single-node import only)")
    pi.set_defaults(func=cmd_import)

    pa = sub.add_parser(
        "add", help="register one node from its VLESS URL",
        formatter_class=raw,
        description="Register a node from the vless:// URL printed by "
                    "setup_vless_caddy_sub.sh.",
        epilog=f"Examples:\n  {PROG} add 'vless://...#hk-node'\n"
               f"  {PROG} add 'vless://...#hk-node' --ssh root@host:2222",
    )
    pa.add_argument("url", help="the node's vless:// URL (quote it; it contains '&')")
    pa.add_argument("--ssh", help="SSH target for syncing (default: root@<server-ip>)")
    pa.set_defaults(func=cmd_add)

    pu = sub.add_parser(
        "update", help="refresh a node after a reinstall (rotated keys)",
        formatter_class=raw,
        description="Replace an existing node with its new VLESS URL (the node "
                    "name in the URL fragment identifies which node to update).",
        epilog=f"Examples:\n  {PROG} update 'vless://...#hk-node'   # keeps its SSH target\n"
               f"  {PROG} update 'vless://...#hk-node' --ssh root@1.2.3.4",
    )
    pu.add_argument("url", help="the node's new vless:// URL")
    pu.add_argument("--ssh", help="SSH target for syncing (default: keep existing)")
    pu.set_defaults(func=cmd_update)

    pr = sub.add_parser("remove", help="drop a node from the registry")
    pr.add_argument("name", help="node name (see `list`)")
    pr.set_defaults(func=cmd_remove)

    sub.add_parser("list", help="show registered nodes").set_defaults(func=cmd_list)
    sub.add_parser("gen", help="rebuild the subscription files locally").set_defaults(func=cmd_gen)
    sub.add_parser("sync", help="rsync the files to every VPS").set_defaults(func=cmd_sync)

    args = p.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
