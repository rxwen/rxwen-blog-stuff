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
#   gen [--extra-sub <url>]             rebuild out/base64.txt + clash.yaml
#                                       (--extra-sub merges a 飞机场 sub this run
#                                        only; nodes inlined into both formats)
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
import re
import subprocess
import sys
import urllib.request
from datetime import datetime
from pathlib import Path
from urllib.parse import urlsplit, parse_qs, unquote, quote

# Registry defaults to <repo>/vless-subs (anchored to this script, not the cwd).
# It holds UUIDs (= credentials), so keep it out of git. Override with the
# VLESS_SUBS_HOME env var (e.g. point it at a synced/backed-up directory).
DEFAULT_HOME = Path(__file__).resolve().parent.parent / "vless-subs"
REGISTRY = Path(os.environ.get("VLESS_SUBS_HOME", DEFAULT_HOME))
NODES_DIR = REGISTRY / "nodes"
OUT_DIR = REGISTRY / "out"
REMOTE_SUB_DIR = "/etc/caddy/sub"  # where Caddy serves the files on each VPS

# User-Agent for fetching subscriptions (our own /base64 endpoint AND third-party
# 飞机场). v2rayNG's real UA is "okhttp/<ver>"; many panels (V2Board/Xboard) gate
# their subscribe endpoint on a UA whitelist and 403 a bare "okhttp" or curl's
# default, so send the versioned form. It also still matches our Caddy *okhttp*
# rule, and its UA class makes panels return the base64 node list (not clash yaml).
SUB_FETCH_UA = "okhttp/3.12.0"

# User-Agent for fetching a 飞机场's CLASH config: both server-side (to inline its
# proxies into our clash.yaml) and as the `header` of any fallback proxy-provider.
# Panels whitelist "clash"/"clash.meta"/"clash-verge" style UAs (returning a
# proxies: document) and 403 the "mihomo/<ver>" a bare core sends, so a client-side
# proxy-provider fetch often fails silently -- which is exactly why we prefer to
# fetch + inline server-side and only fall back to a provider when we cannot.
PROVIDER_FETCH_UA = "clash.meta"
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


def parse_extra_sub(spec):
    """Parse a --extra-sub value 'LABEL=URL' (or bare 'URL') -> (label, url).

    The label groups/tags that source's nodes (name prefix in both formats, and a
    per-source clash group). A bare URL defaults its label to the URL host. The
    'LABEL=' form is only recognized when LABEL has no '/' and the value looks like
    an http(s) URL, so a query string's own '=' (e.g. ?token=..) is never split."""
    m = re.match(r"^([^=/\s]+)=(\s*https?://\S+)$", spec.strip(), re.I)
    if m:
        label, url = m.group(1).strip(), m.group(2).strip()
    else:
        label, url = "", spec.strip()
    if not re.match(r"^https?://", url, re.I):
        die(f"--extra-sub expects an http(s) URL (optionally 'LABEL=URL'): {spec}")
    if not label:
        label = urlsplit(url).hostname or "sub"
    return label, url


def _slugify(s):
    """A YAML-key / filename-safe slug ([A-Za-z0-9_-]) for proxy-provider names."""
    return re.sub(r"[^A-Za-z0-9_-]", "-", s).strip("-") or "sub"


def _yaml_sq(s):
    """Single-quote a scalar for YAML (doubling any embedded single quote)."""
    return "'" + s.replace("'", "''") + "'"


def _prefix_url_name(url, label):
    """Prefix a node URL's #fragment (its display name) with 'label | '.

    Fragments are percent-encoded UTF-8; decode, prefix, re-encode. This tags each
    base64 node with its source so names never collide across 飞机场."""
    if "#" in url:
        base, frag = url.split("#", 1)
        name = unquote(frag)
    else:
        base, name = url, ""
    new = f"{label} | {name}" if name else label
    return f"{base}#{quote(new, safe='')}"


def build_base64(nodes, extra_subs=()):
    urls = [n.url for n in nodes]
    for label, url in extra_subs:
        for line in fetch_sub_lines(url):   # any protocol; failures warn -> []
            urls.append(_prefix_url_name(line, label))
    blob = "\n".join(urls)
    return base64.b64encode(blob.encode()).decode()


def build_clash(nodes, extra_subs=()):
    own_names = [n.name for n in nodes]
    own_proxies = [n.clash_proxy() for n in nodes]

    def yaml_list(items, indent):
        pad = " " * indent
        return "\n".join(f'{pad}- "{i}"' for i in items)

    # Pull each 飞机场's proxies server-side and INLINE them, so the served
    # clash.yaml is self-contained (no client-side provider fetch, no per-client
    # UA/refresh/reachability issues). Each source becomes its own select group.
    # A sub with no usable clash config (e.g. JMS only serves base64) has its
    # node URLs converted instead; if that yields nothing too, it falls back to a
    # proxy-provider reference, carried by that same per-source group via `use:`.
    extra_proxy_lines = []
    sources = []                            # per-source: label, names, slug|None, url
    seen_names = set(own_names)
    seen_slugs = {}
    for label, url in extra_subs:
        plines, pnames = fetch_clash_proxies(url, label)
        if not plines:
            plines, pnames = uri_clash_proxies(url, label)
            if plines:
                info(f"[{label}] no clash config; converted {len(plines)} node URL(s)")
        if plines:
            uniq_names = []
            for ln, nm in zip(plines, pnames):
                if nm in seen_names:        # mihomo rejects duplicate proxy names
                    continue
                seen_names.add(nm)
                extra_proxy_lines.append(ln)
                uniq_names.append(nm)
            sources.append({"label": label, "names": uniq_names, "slug": None, "url": url})
        else:
            warn(f"[{label}] could not inline any clash proxies; "
                 "falling back to a proxy-provider reference")
            base = _slugify(label)          # fallback proxy-provider needs a safe key
            seen_slugs[base] = seen_slugs.get(base, 0) + 1
            slug = base if seen_slugs[base] == 1 else f"{base}-{seen_slugs[base]}"
            sources.append({"label": label, "names": [], "slug": slug, "url": url})

    all_extra_names = [nm for s in sources for nm in s["names"]]
    header = CLASH_HEADER.format(
        generated=datetime.now().astimezone().strftime("%Y-%m-%d %H:%M:%S %Z")
    )

    proxies_body = "\n".join(own_proxies + extra_proxy_lines)
    proxies_section = f"proxies:\n{proxies_body}\n\n" if proxies_body else "proxies: []\n\n"

    # Fallback-only proxy-providers block (for subs that couldn't be embedded).
    fb = [s for s in sources if s["slug"]]
    providers_block = ""
    if fb:
        entries = "\n".join(
            f"""\
  {s['slug']}:
    type: http
    url: "{s['url']}"
    interval: 3600
    path: ./providers/{s['slug']}.yaml
    header:
      User-Agent:
        - "{PROVIDER_FETCH_UA}"
    health-check:
      enable: true
      url: http://www.gstatic.com/generate_204
      interval: 300"""
            for s in fb
        )
        providers_block = f"proxy-providers:\n{entries}\n\n"

    # One select group per source (the 飞机场's nodes, or its fallback provider).
    source_groups, source_group_names = "", []
    for s in sources:
        source_group_names.append(s["label"])
        blk = [f'  - name: "{s["label"]}"', "    type: select"]
        if s["slug"]:
            blk.append(f"    use:\n      - {s['slug']}")
        if s["names"]:
            blk.append("    proxies:\n" + yaml_list(s["names"], 6))
        source_groups += "\n".join(blk) + "\n\n"

    # Proxy select: Auto, own nodes, then each source as a foldable group, DIRECT.
    proxy_members = yaml_list(["Auto"] + own_names + source_group_names + ["DIRECT"], 6)
    # Auto (url-test) races every concrete node (own + embedded 飞机场), and also
    # the fallback providers via `use:`; omit an empty proxies: key if no nodes.
    auto_names = own_names + all_extra_names
    auto_use = ("    use:\n" + "\n".join(f"      - {s['slug']}" for s in fb) + "\n") if fb else ""
    auto_proxies = f"    proxies:\n{yaml_list(auto_names, 6)}\n" if auto_names else ""

    groups = f"""\
proxy-groups:
  - name: "Proxy"
    type: select
    proxies:
{proxy_members}

  - name: "Auto"
    type: url-test
    url: http://www.gstatic.com/generate_204
    interval: 300
{auto_use}{auto_proxies}
{source_groups}  - name: "Direct"
    type: select
    proxies:
      - "DIRECT"
      - "Proxy"
"""

    return f"{header}\n{providers_block}{proxies_section}{groups}\n{CLASH_RULES}"


def cmd_gen(args):
    # --extra-sub is one-shot: only this invocation merges them, and they are
    # never persisted. Auto-regens (via _after_change) pass args=None -> no subs.
    extra_subs = [parse_extra_sub(s) for s in (getattr(args, "extra_sub", None) or [])]
    nodes = load_nodes()
    if not nodes and not extra_subs:
        die("No nodes registered. Add one first: vless_subs.py add <ssh-target>")
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    (OUT_DIR / "base64.txt").write_text(build_base64(nodes, extra_subs))
    (OUT_DIR / "clash.yaml").write_text(build_clash(nodes, extra_subs))
    ok(f"Generated subscription for {len(nodes)} node(s) in {OUT_DIR}")
    for n in nodes:
        print(f"    - {n.name}  ({n.server})")
    if extra_subs:
        warn(f"Merged {len(extra_subs)} external sub(s) THIS run only (not saved):")
        for label, url in extra_subs:
            print(f"    + [{label}] {url}")
        info("Re-run `gen` without --extra-sub to drop them again.")
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

    Sends a v2rayNG-style User-Agent (SUB_FETCH_UA) so the unified endpoint
    returns the base64 form (the explicit /base64 endpoint returns it regardless).
    Clash-YAML responses are rejected with a hint to use the base64 endpoint."""
    req = urllib.request.Request(sub_url, headers={"User-Agent": SUB_FETCH_UA})
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


def fetch_sub_lines(sub_url):
    """GET a subscription and return ALL of its node URLs, any protocol.

    Like fetch_sub_urls() but does NOT restrict to vless:// (a 飞机场 typically
    mixes ss/vmess/trojan/hysteria2), and NEVER raises: a fetch/decode failure
    warns and returns [] so a dead upstream can't wipe our own nodes from gen."""
    req = urllib.request.Request(sub_url, headers={"User-Agent": SUB_FETCH_UA})
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            body = resp.read().decode().strip()
    except Exception as e:
        warn(f"Could not fetch extra sub {sub_url}: {e} (skipping)")
        return []
    try:
        decoded = base64.b64decode(body + "=" * (-len(body) % 4)).decode()
    except Exception:
        decoded = body  # maybe already plain text
    lines = [ln.strip() for ln in decoded.splitlines()]
    urls = [ln for ln in lines if re.match(r"^[a-z][a-z0-9+.\-]*://", ln, re.I)]
    if not urls:
        warn(f"No node URLs found in extra sub {sub_url} (skipping)")
    return urls


def fetch_clash_proxies(sub_url, label=""):
    """Fetch a 飞机场's clash config and return (proxy_yaml_lines, names).

    Sends PROVIDER_FETCH_UA (a clash-family UA panels whitelist, which makes them
    return a clash document rather than 403 or base64). Slices the top-level
    `proxies:` block and keeps only single-line flow items ("- { ... }"),
    re-indented to 2 spaces to match our own proxies so the merged list is valid
    YAML. Each proxy's `name` is prefixed with 'label | ' so names carry their
    source and never collide across 飞机场. Returns ([], []) on any failure (fetch
    error, or block-style proxies we can't re-indent) so the caller can fall back
    to a proxy-provider."""
    req = urllib.request.Request(sub_url, headers={"User-Agent": PROVIDER_FETCH_UA})
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            body = resp.read().decode("utf-8", "replace")
    except Exception as e:
        warn(f"Could not fetch clash config from {sub_url}: {e}")
        return [], []
    block, in_block = [], False
    for ln in body.splitlines():
        if re.match(r"^proxies:\s*$", ln):
            in_block = True
            continue
        if in_block:
            if re.match(r"^\S", ln):        # next top-level key -> block ended
                break
            if ln.strip():
                block.append(ln)
    flow = [ln for ln in block if re.match(r"^\s*-\s*\{.*\}\s*$", ln)]
    if not flow or len(flow) != len(block):
        if block:
            warn(f"{sub_url}: clash proxies are not single-line flow items; "
                 "trying its node-URL list instead")
        return [], []
    lines, names = [], []
    for ln in flow:
        m = re.search(r"name:\s*('([^']*)'|\"([^\"]*)\"|([^,}]+))", ln)
        raw = (m.group(2) or m.group(3) or m.group(4) or "").strip() if m else ""
        if not raw:
            continue                        # a proxy with no name is unusable
        name = f"{label} | {raw}" if label else raw
        # Rewrite the (only) name: field to the prefixed, safely-quoted name.
        ln = re.sub(r"(name:\s*)('[^']*'|\"[^\"]*\"|[^,}]+)",
                    lambda mm: mm.group(1) + _yaml_sq(name), ln, count=1)
        lines.append("  " + ln.strip())     # normalize to 2-space list indent
        names.append(name)
    return lines, names


def _b64decode_loose(s):
    """Decode standard or URL-safe base64, tolerating missing padding."""
    s = s.strip().replace("-", "+").replace("_", "/")
    return base64.b64decode(s + "=" * (-len(s) % 4)).decode()


def _ss_clash_proxy(url, name):
    """Render an ss:// URL as a single-line clash proxy, or None if unsupported.

    Accepts SIP002 (ss://b64(method:pass)@host:port) and the legacy form
    (ss://b64(method:pass@host:port)) that e.g. JMS serves. Plugin URLs are
    skipped since their plugin-opts don't map 1:1 onto clash."""
    body = url[len("ss://"):].split("#", 1)[0]
    body, _, query = body.partition("?")
    if "plugin=" in query:
        return None
    body = body.rstrip("/")
    try:
        if "@" in body:
            userinfo, _, hostport = body.rpartition("@")
            userinfo = unquote(userinfo)
            if ":" not in userinfo:
                userinfo = _b64decode_loose(userinfo)
        else:
            userinfo, _, hostport = _b64decode_loose(body).rpartition("@")
    except Exception:
        return None
    method, _, password = userinfo.partition(":")
    host, _, port = hostport.rpartition(":")
    host = host.strip("[]")
    if not (method and password and host and port.isdigit()):
        return None
    return ("  - {" f"name: {_yaml_sq(name)}, type: ss, server: {_yaml_sq(host)}, "
            f"port: {port}, cipher: {method}, password: {_yaml_sq(password)}, "
            "udp: true}")


def uri_clash_proxies(sub_url, label=""):
    """Convert a sub's base64 node-URL list into clash proxies -> (lines, names).

    Fallback for providers (e.g. JMS) that only serve the v2rayN-style list and
    never a clash config. Handles vless+reality (via Node) and ss; any other node
    is skipped with a warning. Names get the same 'label | ' prefix as the base64
    output, so both formats agree."""
    lines, names, skipped = [], [], []
    for i, url in enumerate(fetch_sub_lines(sub_url), 1):
        scheme = url.split("://", 1)[0].lower()
        raw = unquote(url.split("#", 1)[1]) if "#" in url else f"{scheme}-{i}"
        name = f"{label} | {raw}" if label else raw
        line = None
        if scheme == "vless":
            q = parse_qs(urlsplit(url).query)
            if q.get("security", [""])[0] == "reality" and q.get("pbk", [""])[0]:
                node = Node(url)
                node.name = name
                line = node.clash_proxy()
        elif scheme == "ss":
            line = _ss_clash_proxy(url, name)
        if line:
            lines.append(line)
            names.append(name)
        else:
            skipped.append(raw)
    if skipped:
        warn(f"{sub_url}: can't convert {len(skipped)} node(s) to clash "
             f"(only vless+reality and ss are supported): {', '.join(skipped)}")
    return lines, names


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

To fold in another provider's (飞机场) subscription, pass `gen --extra-sub <url>`.
It is merged into that one build only (never saved): the 飞机场's nodes are inlined
into BOTH formats server-side (base64 node URLs, and clash proxies pulled from its
config), so the served subscription is self-contained -- no client-side fetch.
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

  # 5. Also serve another provider's (飞机场) sub, just this once (not saved):
  {PROG} gen --extra-sub 'https://airport.example.com/link/xxxx'
  {PROG} sync                       # push; next plain `gen` drops it again

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

    pg = sub.add_parser(
        "gen", help="rebuild the subscription files locally",
        formatter_class=raw,
        description="Rebuild out/base64.txt + out/clash.yaml from the registry.\n\n"
                    "--extra-sub merges another provider's (飞机场) subscription\n"
                    "INTO this build only. It is NOT saved: the next `gen` without\n"
                    "the flag reverts to your own nodes. Its nodes are inlined into\n"
                    "BOTH formats server-side (base64 URLs + clash proxies pulled\n"
                    "from its config), so the served sub is self-contained. A sub we\n"
                    "cannot inline falls back to a clash proxy-provider reference.\n\n"
                    "Repeatable. Prefix a label with 'LABEL=URL' to tag/group that\n"
                    "source: every node name is prefixed 'LABEL | ...' (avoids cross-\n"
                    "飞机场 name clashes) and clash gets a per-source select group.\n"
                    "A bare URL uses its host as the label.",
        epilog=f"Examples:\n  {PROG} gen\n"
               f"  {PROG} gen --extra-sub 'https://airport.example.com/link/xxxx'\n"
               f"  {PROG} gen --extra-sub 'HK-Air=https://a.com/sub' "
               f"--extra-sub 'JP-Air=https://b.com/sub' && {PROG} sync",
    )
    pg.add_argument(
        "--extra-sub", action="append", metavar="[LABEL=]URL",
        help="external subscription to merge THIS run only (repeatable; not "
             "persisted). 'LABEL=URL' tags/groups the source; bare URL uses its "
             "host. Omit entirely to build from your own nodes only.",
    )
    pg.set_defaults(func=cmd_gen)

    sub.add_parser("sync", help="rsync the files to every VPS").set_defaults(func=cmd_sync)

    args = p.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
