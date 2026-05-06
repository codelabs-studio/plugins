#!/bin/bash
# Add a proxy route to Caddy.
# Reads $DEVPROXY_HOME (default: ~/.devproxy)
# Usage: caddy-add-route.sh <domain> <port> [project_name]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVPROXY_HOME="${DEVPROXY_HOME:-$HOME/.devproxy}"
ROUTES_FILE="$DEVPROXY_HOME/config/routes.json"
CADDYFILE="$DEVPROXY_HOME/Caddyfile"

DOMAIN="$1"
PORT="$2"
PROJECT="${3:-unknown}"

if [[ -z "$DOMAIN" || -z "$PORT" ]]; then
    echo "Usage: $0 <domain> <port> [project_name]" >&2
    exit 1
fi

if [[ ! -f "$ROUTES_FILE" ]]; then
    echo "ERROR: $ROUTES_FILE not found. Run 'init' skill first." >&2
    exit 1
fi

# 1. Update routes.json
python3 -c "
import json
from datetime import datetime, timezone

with open('$ROUTES_FILE') as f:
    data = json.load(f)

data['routes'] = [r for r in data['routes'] if r['domain'] != '$DOMAIN']
data['routes'].append({
    'domain': '$DOMAIN',
    'upstream': 'localhost:$PORT',
    'project': '$PROJECT',
    'ssl': True,
    'enabled': True
})
data['updated_at'] = datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')

with open('$ROUTES_FILE', 'w') as f:
    json.dump(data, f, indent=2)
"

# 2. Regenerate Caddyfile
"$SCRIPT_DIR/caddy-generate.sh" > /dev/null

# 3. Reload Caddy if running
if curl -s -o /dev/null -w '%{http_code}' http://localhost:2019/config/ 2>/dev/null | grep -q "200"; then
    caddy reload --config "$CADDYFILE" --adapter caddyfile 2>/dev/null
    echo "CADDY_RELOADED=true"
else
    echo "CADDY_RELOADED=false (not running)"
fi

# 4. /etc/hosts (only for non-.localhost domains; .localhost resolves automatically)
if [[ "$DOMAIN" != *.localhost ]]; then
    if ! grep -q " $DOMAIN" /etc/hosts 2>/dev/null; then
        sudo sh -c "echo '127.0.0.1 $DOMAIN' >> /etc/hosts"
        echo "HOSTS_ADDED=$DOMAIN"
    else
        echo "HOSTS_EXISTS=$DOMAIN"
    fi
fi

echo "ROUTE_ADDED=https://$DOMAIN -> localhost:$PORT ($PROJECT)"
