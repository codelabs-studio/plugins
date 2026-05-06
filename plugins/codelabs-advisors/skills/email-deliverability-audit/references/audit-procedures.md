# Email Deliverability Audit Procedures

## Full Audit Workflow

### Phase 1: DNS Records Audit (Cloudflare API)

For each domain, query Cloudflare API to verify all required DNS records exist and are correct.

**Procedure:**
1. Read Cloudflare API token from services.json
2. For each domain, use the zone ID from `references/infrastructure.md`
3. Query `GET /zones/{zone_id}/dns_records` to get all records
4. Verify each required record exists and has correct content:

**Required records checklist:**
- [ ] Mail A record: `mail.DOMAIN` -> `46.62.213.212`
- [ ] MX record: `DOMAIN` -> `mail.DOMAIN` priority 10
- [ ] SPF TXT: `DOMAIN` -> contains `v=spf1` and `ip4:46.62.213.212`
- [ ] DKIM TXT: `dkim._domainkey.DOMAIN` -> contains `v=DKIM1`
- [ ] DMARC TXT: `_dmarc.DOMAIN` -> contains `v=DMARC1` and `rua=mailto:admin@DOMAIN`
- [ ] Autoconfig CNAME: `autoconfig.DOMAIN` -> `autoconfig.codelabs.studio`
- [ ] Autodiscover CNAME: `autodiscover.DOMAIN` -> `autodiscover.codelabs.studio`

**Common issues to detect:**
- MX pointing to `mail.codelabs.studio` instead of `mail.DOMAIN` (wrong - should be per-domain)
- DMARC rua pointing to `admin@codelabs.studio` instead of `admin@DOMAIN`
- SPF missing `ip4:46.62.213.212`
- Multiple SPF records (only one allowed)
- DKIM record missing or truncated

### Phase 2: Mailcow Server Audit (via SSH)

Connect to the server and check Mailcow configuration.

**Procedure:**
1. SSH to server: `ssh -i ~/.ssh/hetzner_vps -p 2222 root@46.62.213.212`
2. Check domain registration via Mailcow API
3. Check mailbox quotas (should be 0 = unlimited)
4. Check DKIM keys are generated
5. Check Postfix HELO map (`/etc/postfix/smtp_helo_name`)
6. Check mail queue (`mailq`)
7. Check Postfix logs for recent errors

**HELO Map verification:**
Every domain should have an entry in `/etc/postfix/smtp_helo_name`:
```
@DOMAIN    mail.DOMAIN
```

**Mailbox quota check:**
All mailboxes should have quota=0 (unlimited). If any mailbox has a non-zero quota, flag it.

**Mail queue check:**
The mail queue should be empty or near-empty. Queued messages indicate delivery problems.

### Phase 3: Send/Receive Test

Test actual email delivery for each account.

**Outbound test (Mailcow -> Gmail):**
1. For each account, send a test email to dancestepsapp@gmail.com
2. Use SMTP on port 587 with STARTTLS
3. Check Postfix logs for delivery confirmation (status=sent)

**Inbound test (Mailcow -> Mailcow):**
1. Send from one account (e.g., jose.diaz@codelabs.studio) to all others
2. Check Dovecot logs for "Saved" confirmation

**Authentication test:**
1. Attempt SMTP login for each account
2. Flag any authentication failures (wrong password, account disabled)

### Phase 4: Advanced Checks

**Reverse DNS (PTR):**
```bash
dig -x 46.62.213.212 +short
```
Should return `mail.codelabs.studio.`

**TLS/DANE:**
```bash
# Check TLSA records
dig _25._tcp.mail.DOMAIN TLSA +short
```

**Blacklist check:**
Check server IP against common blacklists via DNS:
```bash
# Check against Spamhaus
dig +short 212.213.62.46.zen.spamhaus.org
# Empty = not listed, any result = listed
```

## Single Domain Audit

When auditing a single domain, run all phases but only for that domain.
Read the domain's email accounts from services.json.

## Report Format

Generate a report with:

```
## Email Deliverability Audit Report
**Date**: YYYY-MM-DD HH:MM UTC
**Domains audited**: N

### Summary
| Domain | DNS | Mailcow | Send | Receive | Score |
|--------|-----|---------|------|---------|-------|
| domain | OK/WARN/FAIL | OK/WARN/FAIL | OK/FAIL | OK/FAIL | X/10 |

### Issues Found
For each issue:
- Domain: X
- Component: DNS/Mailcow/SMTP/Delivery
- Severity: CRITICAL/HIGH/MEDIUM/LOW
- Description: What's wrong
- Fix: How to fix it (with exact commands/API calls)

### Actions Taken
List any automatic fixes applied.

### Recommendations
Prioritized list of remaining manual actions.
```

## Scoring

Each domain gets a score out of 10:
- Mail A record correct: +1
- MX record correct: +1
- SPF record correct: +1
- DKIM configured: +1
- DMARC configured: +1
- Autoconfig/Autodiscover: +0.5 each
- Mailcow domain active: +1
- Mailbox quota unlimited: +0.5
- HELO map entry: +0.5
- Outbound delivery works: +1
- Inbound delivery works: +1

Score 10/10 = perfect deliverability configuration.
