#!/bin/bash
# Sync /etc/hosts from routes.json (only non-.localhost domains).
# Manages a marked section. Never touches entries outside the markers.
# Reads $DEVPROXY_HOME (default: ~/.devproxy)
# Usage: hosts-sync.sh

set -e

DEVPROXY_HOME="${DEVPROXY_HOME:-$HOME/.devproxy}"
ROUTES_FILE="$DEVPROXY_HOME/config/routes.json"
MARKER_START="# >>> codelabs-dev-servers managed routes (DO NOT EDIT)"
MARKER_END="# <<< codelabs-dev-servers managed routes"

if [[ ! -f "$ROUTES_FILE" ]]; then
    echo "ERROR: $ROUTES_FILE not found" >&2
    exit 1
fi

# Extract enabled domains EXCLUDING .localhost (those resolve automatically)
DOMAINS=$(python3 -c "
import json
with open('$ROUTES_FILE') as f:
    data = json.load(f)
for r in data.get('routes', []):
    if r.get('enabled', True) and not r['domain'].endswith('.localhost'):
        print(r['domain'])
" | sort -u)

DOMAIN_COUNT=$(echo -n "$DOMAINS" | grep -c . || true)

# Build managed block
HOSTS_BLOCK="$MARKER_START"
while IFS= read -r domain; do
    [[ -n "$domain" ]] && HOSTS_BLOCK="$HOSTS_BLOCK
127.0.0.1 $domain"
done <<< "$DOMAINS"
HOSTS_BLOCK="$HOSTS_BLOCK
$MARKER_END"

if grep -q "$MARKER_START" /etc/hosts 2>/dev/null; then
    sudo python3 -c "
import re
with open('/etc/hosts') as f:
    content = f.read()
pattern = re.escape('$MARKER_START') + r'.*?' + re.escape('$MARKER_END')
new_block = '''$HOSTS_BLOCK'''
content = re.sub(pattern, new_block, content, flags=re.DOTALL)
with open('/etc/hosts', 'w') as f:
    f.write(content)
"
    echo "HOSTS_UPDATED=true"
else
    sudo sh -c "printf '\n$HOSTS_BLOCK\n' >> /etc/hosts"
    echo "HOSTS_CREATED=true"
fi

echo "HOSTS_SYNCED=$DOMAIN_COUNT domains"
