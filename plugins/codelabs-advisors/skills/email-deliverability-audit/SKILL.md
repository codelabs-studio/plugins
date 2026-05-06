---
name: email-deliverability-audit
description: >
  This skill should be used when the user asks to "audit email deliverability",
  "check email configuration", "verify DNS records for email", "test email sending",
  "audit mailcow", "check SPF/DKIM/DMARC", "email audit", "deliverability check",
  "revisar correos", "auditar entregabilidad", "verificar emails", or wants to
  ensure maximum email deliverability for Mailcow-hosted domains on codelabs.studio
  infrastructure. Supports auditing all domains or a specific project/domain.
---

# Email Deliverability Audit

Perform comprehensive email deliverability audits for domains hosted on the codelabs.studio Mailcow infrastructure. Audit all registered domains or a specific project.

## When to Use

- User requests an email audit for all projects or a specific domain
- After DNS changes or domain migrations
- When email delivery problems are reported
- Periodic health checks of email infrastructure

## Prerequisites

Read credentials from `/Users/josediaz/.config/codelabs/services.json`:
- **SSH access**: `services.hetzner_vps` or use `ssh -i ~/.ssh/hetzner_vps -p 2222 root@46.62.213.212`
- **Mailcow API key**: `services.mailcow.credentials.api_key`
- **Cloudflare API token**: `services.cloudflare.api_token`
- **Email passwords**: Under each project's `email_accounts` section

## Audit Workflow

### Step 1: Determine Scope

If user specifies a domain or project name, audit only that domain.
If user says "all" or "todos", get the full domain list from Mailcow API via SSH:

```bash
ssh -i ~/.ssh/hetzner_vps -p 2222 root@46.62.213.212 \
  'curl -s -H "X-API-Key: API_KEY" http://127.0.0.1:8081/api/v1/get/domain/all' \
  | python3 -c "import sys,json; [print(d['domain_name']) for d in json.load(sys.stdin)]"
```

### Step 2: DNS Records Audit (Cloudflare API)

For each domain, query Cloudflare DNS records using the zone IDs from `references/infrastructure.md`.

Verify these records exist and are correct:
1. **Mail A**: `mail.DOMAIN` -> `46.62.213.212`
2. **MX**: `DOMAIN` -> `mail.DOMAIN` priority 10
3. **SPF**: TXT containing `v=spf1` with `ip4:46.62.213.212`
4. **DKIM**: TXT at `dkim._domainkey.DOMAIN` containing `v=DKIM1`
5. **DMARC**: TXT at `_dmarc.DOMAIN` with `rua=mailto:admin@DOMAIN`
6. **Autoconfig**: CNAME -> `autoconfig.codelabs.studio`
7. **Autodiscover**: CNAME -> `autodiscover.codelabs.studio`

Use local `dig` commands for external DNS verification alongside Cloudflare API checks.

### Step 3: Mailcow Server Audit (via SSH)

Connect via SSH and check:
1. **Domain active** in Mailcow
2. **Mailbox quotas** = 0 (unlimited)
3. **DKIM keys** generated for each domain
4. **HELO map** entries in `/etc/postfix/smtp_helo_name`
5. **Mail queue** is empty (`mailq`)
6. **Recent Postfix errors** in logs

Upload and run `scripts/audit_mailcow.sh` on the server for automated checks.

### Step 4: Send/Receive Test (Optional)

Only run if user requests delivery testing or if DNS/Mailcow checks found issues.

1. Upload `scripts/test_smtp.py` to server
2. Send test emails from each account to `dancestepsapp@gmail.com`
3. Check Postfix logs for `status=sent`
4. Optionally send cross-domain test (one account to all others)

### Step 5: Generate Report

Produce a summary table:

```
| Domain | DNS | Mailcow | Send | Receive | Score |
|--------|-----|---------|------|---------|-------|
```

List all issues found with severity and recommended fixes.
If `--fix` or auto-fix is requested, apply fixes via Cloudflare API or Mailcow API.

## Fixing Issues

When issues are found and user approves fixes:

- **Missing/wrong DNS records**: Create or update via Cloudflare API
- **Wrong MX**: PATCH the record via Cloudflare API
- **Missing HELO entry**: Append to `/etc/postfix/smtp_helo_name` and run `postmap`
- **Wrong quota**: Update via Mailcow API `POST /edit/mailbox`
- **Stale mail queue**: Flush with `postqueue -f` or investigate stuck messages

## Scripts

- **`scripts/audit_dns.sh`** - Local DNS checks via dig for a single domain
- **`scripts/audit_mailcow.sh`** - Server-side Mailcow API + Postfix audit (run via SSH)
- **`scripts/test_smtp.py`** - SMTP send test for one or all accounts

## Additional Resources

### Reference Files
- **`references/infrastructure.md`** - Server access, API endpoints, zone IDs, expected DNS records
- **`references/audit-procedures.md`** - Detailed audit procedures, scoring criteria, report format

### Credentials
All credentials are centralized in `/Users/josediaz/.config/codelabs/services.json`. Never hardcode credentials - always read from this file at runtime.
