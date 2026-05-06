#!/bin/bash
# Ensure Caddy is running. Start it if not.
# Reads $DEVPROXY_HOME (default: ~/.devproxy)
# Usage: caddy-ensure.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVPROXY_HOME="${DEVPROXY_HOME:-$HOME/.devproxy}"
CADDYFILE="$DEVPROXY_HOME/Caddyfile"

# Check Caddy binary
if ! command -v caddy >/dev/null 2>&1; then
    echo "CADDY_BINARY=missing"
    echo "Run the 'init' skill or: brew install caddy" >&2
    exit 1
fi

# Already running?
if curl -s -o /dev/null -w '%{http_code}' http://localhost:2019/config/ 2>/dev/null | grep -q "200"; then
    echo "CADDY_STATUS=running"
    exit 0
fi

# Ensure devproxy home exists
if [[ ! -d "$DEVPROXY_HOME" ]]; then
    echo "DEVPROXY_HOME=missing ($DEVPROXY_HOME)"
    echo "Run the 'init' skill first." >&2
    exit 1
fi

# Ensure Caddyfile exists (regenerate from routes.json if missing)
if [[ ! -f "$CADDYFILE" ]]; then
    "$SCRIPT_DIR/caddy-generate.sh" >/dev/null
fi

# Trust local CA (one-time)
if [[ "$(uname)" == "Darwin" ]]; then
    if ! security find-certificate -c "Caddy Local Authority" /Library/Keychains/System.keychain &>/dev/null; then
        echo "CADDY_CA=installing"
        sudo caddy trust 2>/dev/null || true
    fi
fi

# Start Caddy (sudo required for ports 80/443)
sudo caddy start --config "$CADDYFILE" --adapter caddyfile 2>/dev/null

# Verify
sleep 1
if curl -s -o /dev/null -w '%{http_code}' http://localhost:2019/config/ 2>/dev/null | grep -q "200"; then
    echo "CADDY_STATUS=started"
    exit 0
else
    echo "CADDY_STATUS=failed"
    exit 1
fi
