#!/bin/bash
# Install required dependencies (Caddy + mkcert) and bootstrap $DEVPROXY_HOME.
# Idempotent — safe to run multiple times.
# Usage: install-deps.sh

set -e

DEVPROXY_HOME="${DEVPROXY_HOME:-$HOME/.devproxy}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "==> Installing dependencies"

# Detect package manager
if command -v brew >/dev/null 2>&1; then
    PKG="brew"
elif command -v apt-get >/dev/null 2>&1; then
    PKG="apt"
else
    echo "ERROR: neither Homebrew nor apt found. Install Caddy and mkcert manually." >&2
    exit 1
fi

# Caddy
if command -v caddy >/dev/null 2>&1; then
    echo "  caddy: $(caddy version | head -1)"
else
    echo "  Installing caddy via $PKG..."
    if [[ "$PKG" == "brew" ]]; then
        brew install caddy
    else
        sudo apt-get update && sudo apt-get install -y caddy
    fi
fi

# mkcert
if command -v mkcert >/dev/null 2>&1; then
    echo "  mkcert: $(mkcert -version)"
else
    echo "  Installing mkcert via $PKG..."
    if [[ "$PKG" == "brew" ]]; then
        brew install mkcert nss
    else
        sudo apt-get install -y libnss3-tools
        # mkcert via go install or prebuilt binary
        echo "  NOTE: For Linux, install mkcert from https://github.com/FiloSottile/mkcert/releases" >&2
    fi
    mkcert -install 2>/dev/null || true
fi

echo "==> Bootstrapping $DEVPROXY_HOME"

mkdir -p "$DEVPROXY_HOME/config" "$DEVPROXY_HOME/certs"

if [[ ! -f "$DEVPROXY_HOME/config/routes.json" ]]; then
    cp "$PLUGIN_ROOT/templates/routes.json" "$DEVPROXY_HOME/config/routes.json"
    echo "  routes.json: created"
else
    echo "  routes.json: exists, leaving as-is"
fi

# Generate initial Caddyfile (empty)
"$SCRIPT_DIR/caddy-generate.sh" > /dev/null
echo "  Caddyfile: generated"

echo ""
echo "✅ Setup complete."
echo "   DEVPROXY_HOME=$DEVPROXY_HOME"
echo ""
echo "Next: open a project and run the 'start' skill."
