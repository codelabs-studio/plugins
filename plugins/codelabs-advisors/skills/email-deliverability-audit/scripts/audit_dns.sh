#!/bin/bash
# Email Deliverability DNS Audit Script
# Usage: ./audit_dns.sh <domain> [mail_server]
# Returns JSON-like output for each check

DOMAIN="${1:?Usage: audit_dns.sh <domain> [mail_server]}"
MAIL_SERVER="${2:-mail.codelabs.studio}"
SERVER_IP="46.62.213.212"
ERRORS=0
WARNINGS=0

check() {
    local label="$1"
    local status="$2"
    local detail="$3"
    echo "${status}  ${label}: ${detail}"
}

echo "=== DNS Audit: ${DOMAIN} ==="
echo ""

# 1. MX Record
MX=$(dig +short "${DOMAIN}" MX 2>/dev/null)
if [ -z "$MX" ]; then
    check "MX" "FAIL" "No MX record found"
    ERRORS=$((ERRORS+1))
elif echo "$MX" | grep -qi "mail.${DOMAIN}"; then
    check "MX" "OK" "$MX"
else
    check "MX" "WARN" "MX points to ${MX} (expected mail.${DOMAIN})"
    WARNINGS=$((WARNINGS+1))
fi

# 2. Mail A Record
MAIL_A=$(dig +short "mail.${DOMAIN}" A 2>/dev/null)
if [ -z "$MAIL_A" ]; then
    check "MAIL_A" "FAIL" "No A record for mail.${DOMAIN}"
    ERRORS=$((ERRORS+1))
elif [ "$MAIL_A" = "$SERVER_IP" ]; then
    check "MAIL_A" "OK" "mail.${DOMAIN} -> ${MAIL_A}"
else
    check "MAIL_A" "WARN" "mail.${DOMAIN} -> ${MAIL_A} (expected ${SERVER_IP})"
    WARNINGS=$((WARNINGS+1))
fi

# 3. SPF Record
SPF=$(dig +short "${DOMAIN}" TXT 2>/dev/null | grep -i 'v=spf1')
if [ -z "$SPF" ]; then
    check "SPF" "FAIL" "No SPF record found"
    ERRORS=$((ERRORS+1))
elif echo "$SPF" | grep -q "${SERVER_IP}"; then
    check "SPF" "OK" "$SPF"
elif echo "$SPF" | grep -qi "mail.${DOMAIN}"; then
    check "SPF" "OK" "$SPF"
else
    check "SPF" "WARN" "SPF may not include server IP. Record: ${SPF}"
    WARNINGS=$((WARNINGS+1))
fi

# 4. DKIM Record
DKIM=$(dig +short "dkim._domainkey.${DOMAIN}" TXT 2>/dev/null)
if [ -z "$DKIM" ]; then
    check "DKIM" "FAIL" "No DKIM record at dkim._domainkey.${DOMAIN}"
    ERRORS=$((ERRORS+1))
elif echo "$DKIM" | grep -qi 'v=DKIM1'; then
    check "DKIM" "OK" "DKIM record found ($(echo "$DKIM" | wc -c) bytes)"
else
    check "DKIM" "WARN" "DKIM record exists but may be malformed"
    WARNINGS=$((WARNINGS+1))
fi

# 5. DMARC Record
DMARC=$(dig +short "_dmarc.${DOMAIN}" TXT 2>/dev/null)
if [ -z "$DMARC" ]; then
    check "DMARC" "FAIL" "No DMARC record found"
    ERRORS=$((ERRORS+1))
elif echo "$DMARC" | grep -qi 'v=DMARC1'; then
    check "DMARC" "OK" "$DMARC"
else
    check "DMARC" "WARN" "DMARC record exists but may be malformed"
    WARNINGS=$((WARNINGS+1))
fi

# 6. Autoconfig
AUTOCONFIG=$(dig +short "autoconfig.${DOMAIN}" CNAME 2>/dev/null)
if [ -z "$AUTOCONFIG" ]; then
    check "AUTOCONFIG" "WARN" "No autoconfig CNAME (optional but recommended)"
    WARNINGS=$((WARNINGS+1))
else
    check "AUTOCONFIG" "OK" "autoconfig.${DOMAIN} -> ${AUTOCONFIG}"
fi

# 7. Autodiscover
AUTODISCOVER=$(dig +short "autodiscover.${DOMAIN}" CNAME 2>/dev/null)
if [ -z "$AUTODISCOVER" ]; then
    check "AUTODISCOVER" "WARN" "No autodiscover CNAME (optional but recommended)"
    WARNINGS=$((WARNINGS+1))
else
    check "AUTODISCOVER" "OK" "autodiscover.${DOMAIN} -> ${AUTODISCOVER}"
fi

echo ""
echo "=== Summary: ${ERRORS} errors, ${WARNINGS} warnings ==="
