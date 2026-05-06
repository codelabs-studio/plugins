#!/bin/bash
# Remove a proxy route from Caddy.
# Reads $DEVPROXY_HOME (default: ~/.devproxy)
# Usage: caddy-remove-route.sh <domain>
#        caddy-remove-route.sh --project <project_name>

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVPROXY_HOME="${DEVPROXY_HOME:-$HOME/.devproxy}"
ROUTES_FILE="$DEVPROXY_HOME/config/routes.json"
CADDYFILE="$DEVPROXY_HOME/Caddyfile"

if [[ ! -f "$ROUTES_FILE" ]]; then
    echo "ERROR: $ROUTES_FILE not found." >&2
    exit 1
fi

if [[ "$1" == "--project" ]]; then
    PROJECT="$2"
    if [[ -z "$PROJECT" ]]; then
        echo "Usage: $0 --project <project_name>" >&2
        exit 1
    fi

    DOMAINS=$(python3 -c "
import json
with open('$ROUTES_FILE') as f:
    data = json.load(f)
for r in data['routes']:
    if r.get('project') == '$PROJECT':
        print(r['domain'])
")

    python3 -c "
import json
from datetime import datetime, timezone
with open('$ROUTES_FILE') as f:
    data = json.load(f)
data['routes'] = [r for r in data['routes'] if r.get('project') != '$PROJECT']
data['updated_at'] = datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')
with open('$ROUTES_FILE', 'w') as f:
    json.dump(data, f, indent=2)
"

    echo "REMOVED_PROJECT=$PROJECT"
    echo "REMOVED_DOMAINS=$DOMAINS"
else
    DOMAIN="$1"
    if [[ -z "$DOMAIN" ]]; then
        echo "Usage: $0 <domain>" >&2
        echo "       $0 --project <project_name>" >&2
        exit 1
    fi

    python3 -c "
import json
from datetime import datetime, timezone
with open('$ROUTES_FILE') as f:
    data = json.load(f)
data['routes'] = [r for r in data['routes'] if r['domain'] != '$DOMAIN']
data['updated_at'] = datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')
with open('$ROUTES_FILE', 'w') as f:
    json.dump(data, f, indent=2)
"
    echo "REMOVED_DOMAIN=$DOMAIN"
fi

# Regenerate Caddyfile
"$SCRIPT_DIR/caddy-generate.sh" > /dev/null

# Reload Caddy if running
if curl -s -o /dev/null -w '%{http_code}' http://localhost:2019/config/ 2>/dev/null | grep -q "200"; then
    caddy reload --config "$CADDYFILE" --adapter caddyfile 2>/dev/null
    echo "CADDY_RELOADED=true"
fi
