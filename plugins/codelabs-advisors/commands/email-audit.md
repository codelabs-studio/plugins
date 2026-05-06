---
name: email-audit
description: Run email deliverability audit for all Mailcow domains or a specific domain
arguments:
  - name: scope
    description: "Domain name to audit, or 'all' for all domains (default: all)"
    required: false
    default: "all"
user_invocable: true
---

Run a comprehensive email deliverability audit using the `email-deliverability-audit` skill.

**Scope**: {{ scope }}

Perform the full audit workflow:

1. Read credentials from `/Users/josediaz/.config/codelabs/services.json`
2. If scope is "all", get all domains from Mailcow API. If a specific domain, audit only that one.
3. For each domain:
   - Check DNS records via Cloudflare API (MX, SPF, DKIM, DMARC, autoconfig, autodiscover, mail A)
   - Check Mailcow configuration via SSH (domain active, mailbox quotas, DKIM keys)
   - Check Postfix HELO map and mail queue
4. Generate a summary report with scores and issues
5. Ask if the user wants to auto-fix any issues found
6. Optionally run send/receive tests if requested

Use the reference files in the `email-deliverability-audit` skill for zone IDs, API endpoints, and detailed procedures.
