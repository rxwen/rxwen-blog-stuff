# Obsidian WebDAV Sync Deployment Guide

Securely expose an Obsidian vault on an internal host to Obsidian clients on
iPad / iPhone / Mac for syncing, using **rclone (WebDAV) + frp (tunnel) + Caddy (reverse proxy/HTTPS)**.

All domains, tokens, passwords, and keys are placeholders — replace them with your own values.

---

## Placeholders and Port Conventions

**Placeholders**

| Placeholder | Meaning |
|--------|------|
| `YOUR_DOMAIN` | Your domain (e.g. `webdav.example.com`) |
| `FRP_TOKEN` | Shared secret for frps / frpc (generate a random string yourself) |
| `WEBDAV_USER` / `WEBDAV_PASSWORD` | WebDAV username / password |
| `DNS_KEY_ID` / `DNS_KEY_SECRET` | DNS provider API credentials (used by Caddy for automatic certificates) |

**Ports (customizable — just keep both ends consistent)**

| Port | Purpose |
|------|------|
| `18080` | rclone listener + both ends of the tunnel |
| `58080` | frps control port |
| `6443` | Public-facing HTTPS port |

**Overall path**

```
Client ─HTTPS:6443─▶ VPS (Caddy reverse proxy) ─127.0.0.1:18080─ frps ─tunnel (TLS)─ frpc ─127.0.0.1:18080─ rclone ─ vaults
```

Design notes:
- The WebDAV protocol, authentication, and files are all handled by **rclone** on the internal host.
- **frp** punches the internal host through to the VPS and encrypts that tunnel.
- **Caddy** terminates HTTPS on the VPS with automatic certificates (DNS-01, no dependency on ports 80/443 — suitable for environments where those ports are occupied or blocked).

---

## A. VPS Server (Caddy + frps)

### A.1 frps — Tunnel Server

`/etc/frp/frps.ini`:

```ini
[common]
bind_port = 58080
proxy_bind_addr = 127.0.0.1     # Bind the landing port to localhost only, for the local Caddy
token = FRP_TOKEN
tls_only = true                 # Force clients to connect over TLS
```

Start:

```bash
sudo systemctl enable --now frps      # or however you start services
```

### A.2 Caddy — Reverse Proxy + Automatic Certificates

`/etc/caddy/Caddyfile`:

```
{
    acme_dns <your-dns-provider> {
        access_key_id     DNS_KEY_ID
        access_key_secret DNS_KEY_SECRET
    }
}

YOUR_DOMAIN:6443 {
    reverse_proxy 127.0.0.1:18080
}
```

- Replace `<your-dns-provider>` with the matching module (e.g. `alidns`, `cloudflare`, etc.) and fill in your own credentials.
- No webdav plugin is needed — `reverse_proxy` passes through PROPFIND / LOCK / UNLOCK and other methods.
- Authentication is handled by rclone; Caddy just passes through the `Authorization` header, so there's no need to configure credentials here again.

Start / reload:

```bash
sudo systemctl enable --now caddy
sudo systemctl reload caddy           # after editing the config
```

### A.3 Firewall

- Allow: `58080` (for frpc to connect) and `6443` (public HTTPS).
- Do **not** open `18080` to the public internet (it is local to the VPS, for Caddy only).

---

## B. WebDAV Server Host (rclone + frpc)

Both run as user-level systemd services under a regular user. Enable linger first, otherwise they stop when the user logs out:

```bash
sudo loginctl enable-linger $USER
```

### B.1 rclone — WebDAV Server

Generate the bcrypt password file:

```bash
sudo apt install -y apache2-utils
mkdir -p ~/.config/rclone
htpasswd -B -c ~/.config/rclone/htpasswd WEBDAV_USER     # enter WEBDAV_PASSWORD
chmod 600 ~/.config/rclone/htpasswd
```

`~/.config/systemd/user/webdav.service`:

```ini
[Unit]
Description=rclone WebDAV server
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=%h/.local/bin/rclone serve webdav %h/vaults --addr 127.0.0.1:18080 --htpasswd %h/.config/rclone/htpasswd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
```

- Change `%h/vaults` to the parent directory that holds your vaults.
- Listens on `127.0.0.1:18080`; with the dedicated-port setup, do **not** add `--baseurl` (WebDAV is served at the root path).

#### Serving vaults scattered across different locations — rclone's `combine` backend

If your vault directories live in different places (not under one common parent), use rclone's
**`combine`** backend to mount several distinct directories under a single WebDAV root, each at its
own subpath.

First create a `combine` remote:

```bash
rclone config create obsidian combine \
  upstreams "llm=/home/USER/Documents/llm_wikis other=/home/USER/projects/notes"
```

This writes the following to `~/.config/rclone/rclone.conf`:

```ini
[obsidian]
type = combine
upstreams = llm=/home/USER/Documents/llm_wikis other=/home/USER/projects/notes
```

Each `name=path` pair becomes one top-level directory in the merged view.

Then change the systemd `ExecStart` to serve this remote (note it is `obsidian:`, not a path):

```ini
ExecStart=%h/.local/bin/rclone serve webdav obsidian: --addr 127.0.0.1:18080 --htpasswd %h/.config/rclone/htpasswd
```

Reload and restart:

```bash
systemctl --user daemon-reload && systemctl --user restart webdav
```

The WebDAV root now exposes two trees, `/llm/...` and `/other/...`, which clients access by subpath:

```
https://YOUR_DOMAIN:6443/llm/llm_wiki_slam/
https://YOUR_DOMAIN:6443/other/...
```

> `combine` maps each directory to a **distinct subpath**. If instead you want to overlay multiple
> directories into the **same** namespace, that is the `union` backend — but syncing a vault
> generally doesn't need it.

### B.2 frpc — Tunnel Client

`~/.config/frp/frpc.toml`:

```toml
serverAddr = "YOUR_DOMAIN"     # or the VPS public IP
serverPort = 58080             # = frps bind_port

auth.method = "token"
auth.token = "FRP_TOKEN"       # must match frps

transport.tls.enable = true    # encrypt the tunnel

[[proxies]]
name = "webdav"
type = "tcp"
localIP = "127.0.0.1"
localPort = 18080              # local rclone listening port
remotePort = 18080             # landing port on the VPS for Caddy's reverse proxy
```

> Note: `localPort` is the local rclone port, `remotePort` is the landing port on the VPS;
> the numbers being identical is just a coincidence (they're on different machines), there is no conflict.

`~/.config/systemd/user/frpc.service`:

```ini
[Unit]
Description=frpc tunnel
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=%h/.local/bin/frpc -c %h/.config/frp/frpc.toml
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
```

Enable both services:

```bash
systemctl --user daemon-reload
systemctl --user enable --now webdav frpc
systemctl --user status frpc      # should show login success + proxy added
```

---

## C. Obsidian Client (WebDAV Sync Plugin)

Configure once per **vault** — each Obsidian vault maps to one remote subdirectory.

1. Open the target vault and enable the WebDAV sync plugin inside that vault.
2. Fill in the fields:
   - **WebDAV server URL**: `https://YOUR_DOMAIN:6443` (up to the port, no trailing `/`)
   - **Account**: `WEBDAV_USER`
   - **Credential**: `WEBDAV_PASSWORD`
   - **Remote directory**: that vault's subdirectory, e.g. `/my_vault/` (with leading and trailing `/`)
   - Combined = `https://YOUR_DOMAIN:6443/my_vault/`
   - **Encryption**: as needed (enabling it gives client-side encryption; all devices must use the same password)
3. Click **Check connection** — success means the configuration is correct.
4. **Back up before the first sync**; on a new device, syncing into an empty vault for the first time is a safe pull.
5. Trigger a sync:
   - the sync icon in the left ribbon; or
   - the command palette (`Cmd/Ctrl + P` → search `sync`); or
   - enable "sync on startup / scheduled sync" in the plugin settings for automatic syncing.

**Common pitfalls**

- Path depth: Remote directory must point exactly at the vault folder itself.
- Slashes: no trailing `/` on the base URL; leading and trailing `/` on the Remote directory.
- Don't put any extra subpath in the base URL (rclone serves at the root path, `--baseurl` is not used).

---

## D. Three-Layer Verification

```bash
# ① Locally on the WebDAV host: confirm rclone is listening
curl -u WEBDAV_USER:WEBDAV_PASSWORD -X PROPFIND -H "Depth: 1" http://127.0.0.1:18080/

# ② Locally on the VPS: confirm the tunnel frps→frpc→rclone works
curl -u WEBDAV_USER:WEBDAV_PASSWORD -X PROPFIND -H "Depth: 1" http://127.0.0.1:18080/

# ③ Externally: confirm Caddy on 6443 + the certificate
curl -u WEBDAV_USER:WEBDAV_PASSWORD -X PROPFIND -H "Depth: 1" https://YOUR_DOMAIN:6443/
```

If all three return **207 Multi-Status** plus a directory listing, the whole chain is working.

---

## E. Port Quick Reference

| Location | Port | Role |
|------|------|------|
| WebDAV host | `127.0.0.1:18080` | rclone WebDAV |
| Host → VPS | `58080` | frpc connecting to the frps control port |
| VPS local | `127.0.0.1:18080` | frps landing port, reverse-proxied by Caddy |
| VPS public | `6443` | Public HTTPS (Caddy) |

---

## Security and Operations Notes

- **Transport encryption**: client ↔ VPS goes over HTTPS (Caddy + a real certificate); VPS ↔ internal host goes over the frp TLS tunnel.
  Never expose plaintext HTTP + Basic Auth on the public internet (the password is base64, effectively plaintext).
- **Certificates**: Caddy issues and renews automatically via DNS-01, with no dependency on ports 80/443 — so it still works even if those ports are occupied or blocked.
- **Multiple engines managing the same directory**: if the vault directory is also managed by another sync engine such as Syncthing,
  avoid "modifying the same file on both ends at the same time" to prevent conflict copies.
- **iOS note**: the client must use a trusted real certificate (self-signed certificates are not accepted by Obsidian's networking layer on iOS).
