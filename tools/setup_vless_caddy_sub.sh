#!/usr/bin/env bash
# =============================================================================
# VPS Setup Script
# Purpose: Install Xray (VLESS+REALITY) + Caddy Subscription Server
# Usage: Set environment variables then run this script
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

# -----------------------------------------------------------------------------
# Check environment variables
# -----------------------------------------------------------------------------
section "Checking Environment Variables"

MISSING=0

check_env() {
    local var=$1
    local desc=$2
    if [ -z "${!var:-}" ]; then
        echo -e "  ${RED}✗${NC} ${BOLD}${var}${NC} not set — ${desc}"
        MISSING=$((MISSING + 1))
    else
        echo -e "  ${GREEN}✓${NC} ${BOLD}${var}${NC} = ${!var}"
    fi
}

check_env "SUB_DOMAIN"            "Subscription domain, e.g. sub.example.com"
check_env "ALI_ACCESS_KEY_ID"     "Aliyun AccessKey ID"
check_env "ALI_ACCESS_KEY_SECRET" "Aliyun AccessKey Secret"
check_env "REALITY_SNI"           "REALITY camouflage domain, e.g. www.example.com"

if [ $MISSING -gt 0 ]; then
    echo ""
    echo -e "${RED}Missing ${MISSING} required environment variable(s). Set them and re-run:${NC}"
    echo ""
    echo "  export SUB_DOMAIN=\"sub.example.com\""
    echo "  export ALI_ACCESS_KEY_ID=\"LTAIxxxxxxxxxxxxxxxxx\""
    echo "  export ALI_ACCESS_KEY_SECRET=\"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx\""
    echo "  export REALITY_SNI=\"www.microsoft.com\""
    echo ""
    exit 1
fi

success "All environment variables are set"

# -----------------------------------------------------------------------------
# Check root privileges
# -----------------------------------------------------------------------------
[ "$(id -u)" -eq 0 ] || error "Please run this script as root"

# -----------------------------------------------------------------------------
# System update
# -----------------------------------------------------------------------------
section "Updating System Packages"
apt update -qq
apt install -y -qq curl wget unzip ufw
success "System packages updated"

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
PRIVATE_KEY=$(echo "$KEYPAIR" | grep "Private key" | awk '{print $3}')
PUBLIC_KEY=$(echo "$KEYPAIR" | grep "Public key" | awk '{print $3}')
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

apt install -y -qq debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' \
  | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg 2>/dev/null
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' \
  | tee /etc/apt/sources.list.d/caddy-stable.list > /dev/null
apt update -qq
apt install -y -qq caddy
success "Caddy base version installed"

info "Downloading Caddy with alidns plugin..."
systemctl stop caddy
curl -fsSL \
  "https://caddyserver.com/api/download?os=linux&arch=amd64&p=github.com%2Fcaddy-dns%2Falidns" \
  -o /usr/bin/caddy
chmod +x /usr/bin/caddy

if caddy list-modules 2>/dev/null | grep -q "alidns"; then
    success "alidns plugin loaded: $(caddy version)"
else
    error "alidns plugin failed to load"
fi

# -----------------------------------------------------------------------------
# 6. Generate subscription token and VLESS URL
# -----------------------------------------------------------------------------
section "Generating Subscription Token and VLESS URL"

SUB_TOKEN=$(openssl rand -hex 20)
success "Subscription token: $SUB_TOKEN"

SERVER_IP=$(curl -s https://api.ipify.org || curl -s https://ifconfig.me)
success "Server IP: $SERVER_IP"

VLESS_URL="vless://${UUID}@${SERVER_IP}:443?encryption=none&flow=xtls-rprx-vision&security=reality&sni=${REALITY_SNI}&fp=chrome&pbk=${PUBLIC_KEY}&sid=${SHORT_ID}&type=tcp#$(hostname)"
success "VLESS URL generated"

# -----------------------------------------------------------------------------
# 7. Create subscription files
# -----------------------------------------------------------------------------
section "Creating Subscription Files"

mkdir -p /etc/caddy/sub

# Base64 subscription file
echo -n "$VLESS_URL" | base64 -w 0 > /etc/caddy/sub/base64.txt
success "Base64 subscription file created"

# Clash YAML subscription file
NODE_NAME="$(hostname)-REALITY"
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

cat > /etc/caddy/Caddyfile << EOF
{
    acme_dns alidns {
        access_key_id     ${ALI_ACCESS_KEY_ID}
        access_key_secret ${ALI_ACCESS_KEY_SECRET}
    }
}

${SUB_DOMAIN}:8443 {

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

ufw allow 443/tcp  > /dev/null
ufw allow 8443/tcp > /dev/null
ufw --force enable > /dev/null
success "Ports 443 and 8443 are open"

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
  IP Address:       ${SERVER_IP}
  Subscription Domain: ${SUB_DOMAIN}
  Camouflage Domain:   ${REALITY_SNI}

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
  https://${SUB_DOMAIN}:8443/sub/${SUB_TOKEN}

  Base64 format (Shadowrocket / v2rayNG / PassWall):
  https://${SUB_DOMAIN}:8443/sub/${SUB_TOKEN}/base64

  Clash YAML format (Clash Verge / Stash / OpenClash):
  https://${SUB_DOMAIN}:8443/sub/${SUB_TOKEN}/clash

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

echo ""
info "Certificate issuance may take 1-2 minutes. Monitor with:"
echo "  journalctl -u caddy -f | grep -i cert"
echo ""
info "Summary saved to: $SUMMARY_FILE"
