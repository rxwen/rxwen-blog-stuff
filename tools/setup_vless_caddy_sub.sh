#!/usr/bin/env bash
# =============================================================================
# VPS Setup Script
# Purpose: Install Xray (VLESS+REALITY) + Caddy Subscription Server
#
# Two subscription-server modes, auto-selected:
#   * No domain  -> plain HTTP on SUB_PORT (default 8080), gated by URL token.
#   * With domain (SUB_DOMAIN set) -> HTTPS on SUB_HTTPS_PORT (default 8443):
#       - Aliyun keys present -> DNS-01 cert (custom Caddy build w/ alidns).
#       - no keys             -> automatic HTTP-01 cert (stock Caddy, needs
#                                port 80 open + an A-record pointing here).
#
# Configure via environment variables OR command-line flags (flags win).
# Run with -h / --help for the full flag list.
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# Color output
# -----------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }
section() { echo -e "\n${BOLD}${CYAN}=== $* ===${NC}"; }

usage() {
    cat <<'USAGE'
Usage: setup_vless_caddy_sub.sh [options]

Options (each also settable via the same-named environment variable):
  --reality-sni <domain>     REALITY camouflage domain (borrowed, e.g.
                             www.microsoft.com). REQUIRED. [REALITY_SNI]
  --node-name <name>         Friendly node / subscription title.
                             Default: <hostname>-REALITY. [NODE_NAME]

  --domain <domain>          Subscription domain. If set, the subscription
                             server runs over HTTPS. If omitted, it runs over
                             plain HTTP. [SUB_DOMAIN]
  --sub-port <port>          HTTP port used in no-domain mode. Default 8080.
                             [SUB_PORT]
  --https-port <port>        HTTPS port used in domain mode. Default 8443.
                             [SUB_HTTPS_PORT]

  --ali-key-id <id>          Aliyun AccessKey ID     (enables DNS-01 in domain
  --ali-key-secret <secret>  Aliyun AccessKey Secret  mode). Both optional.
                             [ALI_ACCESS_KEY_ID / ALI_ACCESS_KEY_SECRET]

  -h, --help                 Show this help and exit.

Examples:
  # No domain (HTTP, token-gated):
  REALITY_SNI=www.microsoft.com NODE_NAME=hk-node bash setup_vless_caddy_sub.sh

  # Domain, automatic HTTP-01 cert (needs port 80 open + A-record):
  bash setup_vless_caddy_sub.sh --reality-sni www.microsoft.com \
       --domain sub.example.com

  # Domain, DNS-01 cert via Aliyun (works even with port 80/443 busy):
  bash setup_vless_caddy_sub.sh --reality-sni www.microsoft.com \
       --domain sub.example.com --ali-key-id LTAIxxx --ali-key-secret xxx
USAGE
}

# -----------------------------------------------------------------------------
# Resolve configuration: environment defaults, then override with CLI flags.
# -----------------------------------------------------------------------------
REALITY_SNI="${REALITY_SNI:-}"
NODE_NAME="${NODE_NAME:-}"
SUB_DOMAIN="${SUB_DOMAIN:-}"
SUB_PORT="${SUB_PORT:-8080}"
SUB_HTTPS_PORT="${SUB_HTTPS_PORT:-8443}"
ALI_ACCESS_KEY_ID="${ALI_ACCESS_KEY_ID:-}"
ALI_ACCESS_KEY_SECRET="${ALI_ACCESS_KEY_SECRET:-}"

need_val() { [ $# -ge 2 ] || error "Option '$1' requires a value (see --help)"; }

while [ $# -gt 0 ]; do
    case "$1" in
        --reality-sni|--sni)   need_val "$@"; REALITY_SNI="$2";           shift 2 ;;
        --node-name)           need_val "$@"; NODE_NAME="$2";             shift 2 ;;
        --domain|--sub-domain) need_val "$@"; SUB_DOMAIN="$2";            shift 2 ;;
        --sub-port)            need_val "$@"; SUB_PORT="$2";              shift 2 ;;
        --https-port)          need_val "$@"; SUB_HTTPS_PORT="$2";        shift 2 ;;
        --ali-key-id)          need_val "$@"; ALI_ACCESS_KEY_ID="$2";     shift 2 ;;
        --ali-key-secret)      need_val "$@"; ALI_ACCESS_KEY_SECRET="$2"; shift 2 ;;
        -h|--help)             usage; exit 0 ;;
        *) error "Unknown argument: $1 (see --help)" ;;
    esac
done

NODE_NAME="${NODE_NAME:-$(hostname)-REALITY}"

# -----------------------------------------------------------------------------
# Validate and derive mode
# -----------------------------------------------------------------------------
section "Checking Configuration"

[ -n "$REALITY_SNI" ] || {
    echo -e "${RED}REALITY_SNI is required.${NC} Set it and re-run, e.g.:"
    echo "  export REALITY_SNI=\"www.microsoft.com\""
    echo "  # or: --reality-sni www.microsoft.com"
    echo ""
    echo "Run with --help for all options."
    exit 1
}

if [ -n "$SUB_DOMAIN" ]; then
    USE_TLS=true
    if [ -n "$ALI_ACCESS_KEY_ID" ] && [ -n "$ALI_ACCESS_KEY_SECRET" ]; then
        USE_ALIDNS=true
        CERT_METHOD="DNS-01 (Aliyun alidns)"
    else
        USE_ALIDNS=false
        CERT_METHOD="HTTP-01 (automatic, needs port 80 + A-record)"
    fi
    SUB_SCHEME="https"
    SUB_LISTEN_PORT="$SUB_HTTPS_PORT"
    SITE_ADDRESS="${SUB_DOMAIN}:${SUB_HTTPS_PORT}"
else
    USE_TLS=false
    USE_ALIDNS=false
    CERT_METHOD="none (plain HTTP)"
    SUB_SCHEME="http"
    SUB_LISTEN_PORT="$SUB_PORT"
    SITE_ADDRESS=":${SUB_PORT}"
fi

success "REALITY SNI:   $REALITY_SNI"
success "Node name:     $NODE_NAME"
if [ "$USE_TLS" = true ]; then
    success "Mode:          HTTPS  (domain: $SUB_DOMAIN, port: $SUB_HTTPS_PORT)"
    success "Cert method:   $CERT_METHOD"
else
    success "Mode:          HTTP   (port: $SUB_PORT, token-gated)"
fi

# -----------------------------------------------------------------------------
# Check root privileges
# -----------------------------------------------------------------------------
[ "$(id -u)" -eq 0 ] || error "Please run this script as root"

# -----------------------------------------------------------------------------
# System update
# -----------------------------------------------------------------------------
section "Updating System Packages"
apt update -qq
apt install -y -qq curl wget unzip ufw qrencode
success "System packages updated"

# -----------------------------------------------------------------------------
# Optimize network: enable BBR congestion control + larger TCP buffers.
# Cubic collapses throughput on high-latency, lossy paths (e.g. crossing the
# GFW) because it treats random packet loss as congestion and shrinks the
# window. BBR paces by measured bandwidth x RTT and ignores random loss, so it
# sustains throughput; the larger buffers let a single flow fill a high
# bandwidth-delay-product pipe (a ~200 ms RTT link needs multi-MB buffers).
# -----------------------------------------------------------------------------
section "Optimizing Network (BBR)"

modprobe tcp_bbr 2>/dev/null || true
echo tcp_bbr > /etc/modules-load.d/bbr.conf   # load the module on every boot

cat > /etc/sysctl.d/99-bbr.conf << 'SYSCTL'
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_fastopen = 3
SYSCTL
sysctl -p /etc/sysctl.d/99-bbr.conf > /dev/null

if [ "$(sysctl -n net.ipv4.tcp_congestion_control)" = "bbr" ]; then
    success "BBR enabled (qdisc=fq, TCP buffers up to 16 MiB)"
else
    warn "BBR not active; kernel may lack tcp_bbr (needs >= 4.9). Continuing."
fi

# -----------------------------------------------------------------------------
# 1. Install Xray
# -----------------------------------------------------------------------------
section "Installing Xray"

bash -c "$(curl -fsSL https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install
success "Xray installed: $(xray version | head -1)"

# -----------------------------------------------------------------------------
# 2. Generate Xray parameters
# -----------------------------------------------------------------------------
section "Generating Xray Parameters"

UUID=$(xray uuid)
success "UUID:      $UUID"

KEYPAIR=$(xray x25519)
# Output format differs across Xray versions:
#   old (<= v1.8):  "Private key: xxx"      / "Public key: xxx"
#   new (v26.x):    "PrivateKey: xxx"       / "Password (PublicKey): xxx"
# Match case-insensitively on private/public and take the last field (the key).
PRIVATE_KEY=$(echo "$KEYPAIR" | grep -i "private" | awk '{print $NF}')
PUBLIC_KEY=$(echo "$KEYPAIR"  | grep -i "public"  | awk '{print $NF}')
[ -n "$PRIVATE_KEY" ] && [ -n "$PUBLIC_KEY" ] || error "Failed to parse keys from 'xray x25519' output:\n$KEYPAIR"
success "PrivateKey: $PRIVATE_KEY"
success "PublicKey:  $PUBLIC_KEY"

SHORT_ID=$(openssl rand -hex 4)
success "Short ID:  $SHORT_ID"

# -----------------------------------------------------------------------------
# 3. Write Xray config
# -----------------------------------------------------------------------------
section "Writing Xray Configuration"

cat > /usr/local/etc/xray/config.json << EOF
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "listen": "0.0.0.0",
      "port": 443,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "${UUID}",
            "flow": "xtls-rprx-vision"
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "tcp",
        "security": "reality",
        "realitySettings": {
          "show": false,
          "dest": "${REALITY_SNI}:443",
          "xver": 0,
          "serverNames": [
            "${REALITY_SNI}"
          ],
          "privateKey": "${PRIVATE_KEY}",
          "shortIds": [
            "${SHORT_ID}"
          ]
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": ["http", "tls"]
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "tag": "direct"
    }
  ]
}
EOF

success "Xray config written to /usr/local/etc/xray/config.json"

# -----------------------------------------------------------------------------
# 4. Start Xray
# -----------------------------------------------------------------------------
section "Starting Xray"

systemctl enable xray
systemctl restart xray
sleep 2

if systemctl is-active --quiet xray; then
    success "Xray is running"
else
    error "Xray failed to start. Check: journalctl -u xray -n 30"
fi

if ss -tlnp | grep -q ":443"; then
    success "Port 443 is listening"
else
    error "Port 443 is not listening. Check Xray configuration"
fi

# -----------------------------------------------------------------------------
# 5. Install Caddy
# -----------------------------------------------------------------------------
section "Installing Caddy"

install_caddy_repo() {
    apt install -y -qq debian-keyring debian-archive-keyring apt-transport-https
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' \
      | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg 2>/dev/null
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' \
      | tee /etc/apt/sources.list.d/caddy-stable.list > /dev/null
    apt update -qq
    apt install -y -qq caddy
}

# Stock Caddy (provides the systemd unit + caddy user). Skip if already present.
if command -v caddy >/dev/null 2>&1; then
    success "Caddy already installed, skipping: $(caddy version | head -1)"
else
    install_caddy_repo
    success "Caddy installed: $(caddy version | head -1)"
fi

# DNS-01 needs the alidns plugin, which the stock package lacks. Overlay a custom
# build over the package binary (keeping the package's systemd unit + user).
if [ "$USE_ALIDNS" = true ]; then
    if caddy list-modules 2>/dev/null | grep -q "alidns"; then
        success "alidns plugin already present: $(caddy version | head -1)"
    else
        info "Downloading Caddy with alidns plugin (for DNS-01)..."
        systemctl stop caddy 2>/dev/null || true
        curl -fsSL \
          "https://caddyserver.com/api/download?os=linux&arch=amd64&p=github.com%2Fcaddy-dns%2Falidns" \
          -o /usr/bin/caddy
        chmod +x /usr/bin/caddy
        caddy list-modules 2>/dev/null | grep -q "alidns" \
            || error "alidns plugin failed to load"
        success "alidns plugin loaded: $(caddy version | head -1)"
    fi
fi

# -----------------------------------------------------------------------------
# 6. Generate subscription token and VLESS URL
# -----------------------------------------------------------------------------
section "Generating Subscription Token and VLESS URL"

SUB_TOKEN=$(openssl rand -hex 20)
success "Subscription token: $SUB_TOKEN"

# Base64 form of the friendly name, for the Clash "profile-title" response header
# (clients display this as the subscription title instead of the URL token).
SUB_TITLE_B64=$(printf '%s' "$NODE_NAME" | base64 -w 0)

SERVER_IP=$(curl -s --max-time 10 https://api.ipify.org || curl -s --max-time 10 https://ifconfig.me)
[ -n "$SERVER_IP" ] || error "Could not determine public IP address"
success "Server IP: $SERVER_IP"

# Subscription URL host: the domain in HTTPS mode, the public IP in HTTP mode.
if [ "$USE_TLS" = true ]; then
    SUB_HOST="$SUB_DOMAIN"
else
    SUB_HOST="$SERVER_IP"
fi
SUB_BASE_URL="${SUB_SCHEME}://${SUB_HOST}:${SUB_LISTEN_PORT}/sub/${SUB_TOKEN}"

# The VLESS node itself always connects to the server IP on 443 (REALITY),
# regardless of subscription-server mode.
VLESS_URL="vless://${UUID}@${SERVER_IP}:443?encryption=none&flow=xtls-rprx-vision&security=reality&sni=${REALITY_SNI}&fp=chrome&pbk=${PUBLIC_KEY}&sid=${SHORT_ID}&type=tcp#${NODE_NAME}"
success "VLESS URL generated"

# -----------------------------------------------------------------------------
# 7. Create subscription files
# -----------------------------------------------------------------------------
section "Creating Subscription Files"

mkdir -p /etc/caddy/sub

# Base64 subscription file
echo -n "$VLESS_URL" | base64 -w 0 > /etc/caddy/sub/base64.txt
success "Base64 subscription file created"

# Clash YAML subscription file (NODE_NAME defined earlier)
cat > /etc/caddy/sub/clash.yaml << EOF
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

proxies:
  - name: "${NODE_NAME}"
    type: vless
    server: ${SERVER_IP}
    port: 443
    uuid: ${UUID}
    flow: xtls-rprx-vision
    tls: true
    network: tcp
    reality-opts:
      public-key: ${PUBLIC_KEY}
      short-id: ${SHORT_ID}
    servername: ${REALITY_SNI}
    client-fingerprint: chrome
    udp: true

proxy-groups:
  - name: "Proxy"
    type: select
    proxies:
      - ${NODE_NAME}
      - DIRECT

  - name: "Direct"
    type: select
    proxies:
      - DIRECT
      - Proxy

rules:
  - GEOIP,private,DIRECT,no-resolve
  - GEOSITE,cn,Direct
  - GEOIP,CN,Direct
  - MATCH,Proxy
EOF

success "Clash YAML subscription file created"

# -----------------------------------------------------------------------------
# 8. Write Caddyfile
# -----------------------------------------------------------------------------
section "Writing Caddyfile"

# Optional global block: only DNS-01 mode needs the acme_dns directive.
GLOBAL_BLOCK=""
if [ "$USE_ALIDNS" = true ]; then
    GLOBAL_BLOCK="{
    acme_dns alidns {
        access_key_id     ${ALI_ACCESS_KEY_ID}
        access_key_secret ${ALI_ACCESS_KEY_SECRET}
    }
}

"
fi

# Site address is either ':<port>' (HTTP, all interfaces) or
# '<domain>:<port>' (HTTPS, Caddy auto-provisions a cert for the domain).
cat > /etc/caddy/Caddyfile << EOF
${GLOBAL_BLOCK}${SITE_ADDRESS} {

    # Friendly subscription title for Clash-family clients (Clash Verge / Mihomo /
    # Stash). Base64-encoded so non-ASCII names work. Applied to every response.
    header profile-title "base64:${SUB_TITLE_B64}"

    # Smart dispatch: return format based on client User-Agent
    handle /sub/${SUB_TOKEN} {

        @shadowrocket {
            header User-Agent *Shadowrocket*
        }
        handle @shadowrocket {
            root * /etc/caddy/sub
            rewrite * /base64.txt
            file_server
            header Content-Type "text/plain; charset=utf-8"
            header Cache-Control "no-cache"
        }

        @v2rayng {
            header User-Agent *okhttp*
        }
        handle @v2rayng {
            root * /etc/caddy/sub
            rewrite * /base64.txt
            file_server
            header Content-Type "text/plain; charset=utf-8"
            header Cache-Control "no-cache"
        }

        @stash {
            header User-Agent *Stash*
        }
        handle @stash {
            root * /etc/caddy/sub
            rewrite * /clash.yaml
            file_server
            header Content-Type "application/x-yaml; charset=utf-8"
            header Cache-Control "no-cache"
        }

        @clash {
            header User-Agent *clash*
        }
        handle @clash {
            root * /etc/caddy/sub
            rewrite * /clash.yaml
            file_server
            header Content-Type "application/x-yaml; charset=utf-8"
            header Cache-Control "no-cache"
        }

        # Default: return Clash YAML
        handle {
            root * /etc/caddy/sub
            rewrite * /clash.yaml
            file_server
            header Content-Type "application/x-yaml; charset=utf-8"
            header Cache-Control "no-cache"
        }
    }

    # Explicit format endpoints (for debugging)
    handle /sub/${SUB_TOKEN}/base64 {
        root * /etc/caddy/sub
        rewrite * /base64.txt
        file_server
        header Content-Type "text/plain; charset=utf-8"
        header Cache-Control "no-cache"
    }

    handle /sub/${SUB_TOKEN}/clash {
        root * /etc/caddy/sub
        rewrite * /clash.yaml
        file_server
        header Content-Type "application/x-yaml; charset=utf-8"
        header Cache-Control "no-cache"
    }

    handle {
        respond 404
    }
}
EOF

success "Caddyfile written to /etc/caddy/Caddyfile"

# -----------------------------------------------------------------------------
# 9. Start Caddy
# -----------------------------------------------------------------------------
section "Starting Caddy"

caddy validate --config /etc/caddy/Caddyfile 2>&1 | tail -3

systemctl enable caddy
systemctl restart caddy
sleep 3

if systemctl is-active --quiet caddy; then
    success "Caddy is running"
else
    error "Caddy failed to start. Check: journalctl -u caddy -n 30"
fi

# -----------------------------------------------------------------------------
# 10. Configure firewall
# -----------------------------------------------------------------------------
section "Configuring Firewall"

# Allow SSH FIRST — enabling ufw with a default-deny policy and no SSH rule
# would lock you out of the server. Detect the active sshd port (defaults to 22).
SSH_PORT=$(sshd -T 2>/dev/null | awk '/^port /{print $2; exit}')
SSH_PORT=${SSH_PORT:-22}
ufw allow "${SSH_PORT}/tcp"   > /dev/null
ufw allow 443/tcp             > /dev/null   # Xray VLESS+REALITY

OPENED="${SSH_PORT} (SSH), 443 (Xray)"
if [ "$USE_TLS" = true ]; then
    ufw allow "${SUB_HTTPS_PORT}/tcp" > /dev/null
    OPENED="${OPENED}, ${SUB_HTTPS_PORT} (HTTPS sub)"
    if [ "$USE_ALIDNS" = false ]; then
        # Automatic HTTP-01 ACME challenge is served on port 80.
        ufw allow 80/tcp > /dev/null
        OPENED="${OPENED}, 80 (ACME HTTP-01)"
    fi
else
    ufw allow "${SUB_PORT}/tcp" > /dev/null
    OPENED="${OPENED}, ${SUB_PORT} (HTTP sub)"
fi
ufw --force enable > /dev/null
success "Ports open: ${OPENED}"

# -----------------------------------------------------------------------------
# 11. Save and print summary
# -----------------------------------------------------------------------------
section "Setup Complete"

SUMMARY_FILE="/root/vps-setup-summary.txt"
cat > "$SUMMARY_FILE" << EOF
================================================================
  VPS Setup Summary
  Generated: $(date '+%Y-%m-%d %H:%M:%S')
================================================================

[Server Info]
  IP Address:          ${SERVER_IP}
  Subscription Mode:   ${SUB_SCHEME^^}
  Subscription Host:   ${SUB_HOST}
  Subscription Port:   ${SUB_LISTEN_PORT}
  Cert Method:         ${CERT_METHOD}
  Camouflage Domain:   ${REALITY_SNI}
  Node Name:           ${NODE_NAME}

[Xray Node Parameters]
  UUID:         ${UUID}
  Public Key:   ${PUBLIC_KEY}
  Private Key:  ${PRIVATE_KEY}
  Short ID:     ${SHORT_ID}
  Port:         443
  Flow:         xtls-rprx-vision
  Transport:    TCP
  Security:     reality
  Fingerprint:  chrome

[VLESS URL]
  ${VLESS_URL}

[Subscription URLs]
  Unified (auto-detect client):
  ${SUB_BASE_URL}

  Base64 format (Shadowrocket / v2rayNG / PassWall):
  ${SUB_BASE_URL}/base64

  Clash YAML format (Clash Verge / Stash / OpenClash):
  ${SUB_BASE_URL}/clash

[Client Setup]
  The server auto-detects your client by User-Agent and returns the right
  format, so the "Unified" URL above works for every client below. Append
  /clash or /base64 only if you need to force a format.

  Clash Verge / Mihomo / Stash:
    Profiles -> New -> paste the Unified URL -> Import.
    The node and subscription both show as "${NODE_NAME}".

  v2rayN (Windows) / v2rayNG (Android):
    Subscriptions -> add a group -> paste the Unified URL -> Update.
    (Returns base64; node shows as "${NODE_NAME}".)

  Shadowrocket (iOS):
    + -> Type: Subscribe -> paste the Unified URL -> Done -> pull to update.

  Single-node import (no subscription) — paste the VLESS URL above directly:
    most clients support "Import from clipboard" / scan-QR of that URL.

  Note: re-running this script rotates the token, UUID and keys, so every
  client must re-import afterwards.

[Config File Paths]
  Xray config:    /usr/local/etc/xray/config.json
  Caddy config:   /etc/caddy/Caddyfile
  Sub files:      /etc/caddy/sub/
  This summary:   /root/vps-setup-summary.txt

[Maintenance Commands]
  systemctl status xray        # Xray status
  systemctl restart xray       # Restart Xray
  journalctl -u xray -f        # Xray logs
  systemctl status caddy       # Caddy status
  systemctl restart caddy      # Restart Caddy
  journalctl -u caddy -f       # Caddy logs
================================================================
EOF

cat "$SUMMARY_FILE"

# -----------------------------------------------------------------------------
# QR codes for quick mobile import (Shadowrocket etc.)
# qrencode renders directly in the terminal with -t ANSIUTF8; scan it with the
# phone camera / the client's built-in "scan QR" import.
# -----------------------------------------------------------------------------
if command -v qrencode >/dev/null 2>&1; then
    section "QR Codes (scan with your phone)"

    echo -e "${BOLD}Subscription (Shadowrocket / v2rayNG / Clash — auto-detect):${NC}"
    echo "  ${SUB_BASE_URL}"
    # -m 1 trims the quiet-zone margin (default 4) so the code is compact enough
    # to fit in a terminal window while still scanning reliably.
    qrencode -t ANSIUTF8 -m 1 "$SUB_BASE_URL"
    echo -e "${BOLD}Single node (VLESS — import without a subscription):${NC}"
else
    warn "qrencode not installed; skipping QR codes. Install with: apt install -y qrencode"
fi

echo ""
if [ "$USE_TLS" = true ]; then
    info "Certificate issuance may take 1-2 minutes. Monitor with:"
    echo "  journalctl -u caddy -f | grep -i cert"
    if [ "$USE_ALIDNS" = false ]; then
        warn "HTTP-01 mode: ensure ${SUB_DOMAIN} has an A-record -> ${SERVER_IP} and port 80 is reachable."
    fi
else
    warn "Subscription is served over plain HTTP — protected only by the URL token."
    warn "Keep the subscription URL secret; rotate it by re-running if it leaks."
fi
echo ""
info "Summary saved to: $SUMMARY_FILE"
