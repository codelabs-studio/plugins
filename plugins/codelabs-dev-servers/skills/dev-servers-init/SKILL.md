---
name: dev-servers-init
description: One-time bootstrap for codelabs-dev-servers. Installs Caddy + mkcert via Homebrew (or apt), creates ~/.devproxy/ with empty routes.json, generates initial Caddyfile. Run this once per machine before using start/stop/etc. Use when user says "/dev-servers init", "setup dev servers", "configurar dev-servers", "instalar caddy", "init devproxy", "first time setup".
allowed-tools: Bash, Read
---

# Init — bootstrap codelabs-dev-servers

One-time setup for a machine. Idempotent: safe to re-run.

## What it does

1. Detects package manager (Homebrew on macOS, apt on Linux).
2. Installs Caddy if missing.
3. Installs mkcert if missing (and runs `mkcert -install` to add the local CA).
4. Creates `~/.devproxy/` with `config/`, `certs/` subdirectories.
5. Copies `templates/routes.json` to `~/.devproxy/config/routes.json` if missing.
6. Generates initial empty `Caddyfile` from routes.json.

## Run

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/install-deps.sh"
```

The script handles all detection and installation. It will prompt for `sudo` once (for `mkcert -install` and Homebrew if needed).

## After init

Run the `start` skill in any project directory. The first time, it will auto-detect the stack (Next.js, Vite, FastAPI, etc.), assign deterministic ports, and write `.claude/servers.json` to your project.

## Custom location

If you want `~/.devproxy/` somewhere else (e.g., on an external drive), export `DEVPROXY_HOME` in your shell:

```bash
export DEVPROXY_HOME="/path/to/your/devproxy"
```

All scripts and skills respect this variable.

## Verify

```bash
caddy version       # should print version
mkcert -version     # should print version
ls ~/.devproxy/     # should show: Caddyfile  certs/  config/
```

## Anti-patterns

- ❌ Don't manually edit `~/.devproxy/Caddyfile` — it's regenerated. Edit `config/routes.json` if you must, or use `caddy-add-route.sh`.
- ❌ Don't put service-specific routes here. Each project's services go in its own `.claude/servers.json` and the plugin manages the proxy entries automatically.
