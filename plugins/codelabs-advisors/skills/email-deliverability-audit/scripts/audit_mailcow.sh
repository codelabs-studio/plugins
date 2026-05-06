#!/bin/bash
# Mailcow API Audit Script - runs on the server via SSH
# Usage: ./audit_mailcow.sh [domain]
# If no domain specified, audits all domains

API_URL="${MAILCOW_API_URL:-http://127.0.0.1:8081/api/v1}"
API_KEY="${MAILCOW_API_KEY:?Error: MAILCOW_API_KEY environment variable is required}"

api_get() {
    curl -s -H "X-API-Key: ${API_KEY}" "${API_URL}${1}"
}

echo "=== Mailcow Audit ==="

# List all domains
if [ -z "$1" ]; then
    DOMAINS=$(api_get "/get/domain/all" | python3 -c "
import sys, json
for d in json.load(sys.stdin):
    print(d['domain_name'])
" 2>/dev/null)
else
    DOMAINS="$1"
fi

echo "Domains: $(echo "$DOMAINS" | tr '\n' ', ')"
echo ""

for DOMAIN in $DOMAINS; do
    echo "--- ${DOMAIN} ---"

    # Check domain status
    DOMAIN_INFO=$(api_get "/get/domain/${DOMAIN}")
    ACTIVE=$(echo "$DOMAIN_INFO" | python3 -c "import sys,json; print(json.load(sys.stdin).get('active','?'))" 2>/dev/null)
    echo "  Domain active: ${ACTIVE}"

    # Check mailboxes
    MAILBOXES=$(api_get "/get/mailbox/all" | python3 -c "
import sys, json
for m in json.load(sys.stdin):
    if m['domain'] == '${DOMAIN}':
        quota = m.get('quota', 0)
        quota_used = m.get('quota_used', 0)
        active = m.get('active', '?')
        print(f\"  Mailbox: {m['username']} | active={active} | quota={quota} | used={quota_used}\")
" 2>/dev/null)
    if [ -z "$MAILBOXES" ]; then
        echo "  No mailboxes found"
    else
        echo "$MAILBOXES"
    fi

    # Check DKIM
    DKIM=$(api_get "/get/dkim/${DOMAIN}")
    DKIM_LEN=$(echo "$DKIM" | python3 -c "
import sys, json
d = json.load(sys.stdin)
if 'dkim_txt' in d:
    print(f\"configured ({d.get('length', '?')}-bit)\")
else:
    print('NOT CONFIGURED')
" 2>/dev/null)
    echo "  DKIM: ${DKIM_LEN}"
    echo ""
done

# Check mail queue
echo "=== Postfix Mail Queue ==="
QUEUE=$(mailq 2>/dev/null | tail -1)
echo "  ${QUEUE:-Queue check requires root access}"

# Check HELO map
echo ""
echo "=== HELO Map ==="
if [ -f /etc/postfix/smtp_helo_name ]; then
    cat /etc/postfix/smtp_helo_name
else
    echo "  HELO map not found at /etc/postfix/smtp_helo_name"
fi
