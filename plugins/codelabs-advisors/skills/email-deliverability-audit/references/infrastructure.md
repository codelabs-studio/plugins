# Infrastructure Reference - Mailcow Email System

## Server Access

- **Host**: 46.62.213.212
- **SSH Port**: 2222
- **SSH Key**: ~/.ssh/hetzner_vps
- **SSH Command**: `ssh -i ~/.ssh/hetzner_vps -p 2222 root@46.62.213.212`
- **Mailcow Path**: /opt/mailcow

## Mailcow API

- **Endpoint**: `http://127.0.0.1:8081/api/v1/` (accessed via SSH, NOT externally)
- **API Key**: Read from `/Users/josediaz/.config/codelabs/services.json` -> `services.mailcow.credentials.api_key`
- **Auth Header**: `X-API-Key: <api_key>`

### Key API Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/get/domain/all` | GET | List all domains |
| `/get/domain/<domain>` | GET | Domain details |
| `/get/mailbox/all` | GET | List all mailboxes |
| `/get/mailbox/<email>` | GET | Mailbox details |
| `/get/dkim/<domain>` | GET | DKIM key info |
| `/edit/mailbox` | POST | Update mailbox (quota, active, etc.) |
| `/edit/domain` | POST | Update domain settings |

### Mailbox Quota API

Set quota to 0 for unlimited:
```bash
curl -s -X POST "http://127.0.0.1:8081/api/v1/edit/mailbox" \
  -H "X-API-Key: API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"items":["jose.diaz@domain.com"],"attr":{"quota":0}}'
```

## Cloudflare DNS API

- **API Token**: Read from `/Users/josediaz/.config/codelabs/services.json` -> `services.cloudflare.api_token`
- **Base URL**: `https://api.cloudflare.com/client/v4`

### Zone IDs (all domains)

| Domain | Zone ID |
|--------|---------|
| almasuite.coach | 09b6374af47ec4dd66a66e8fa14416e0 |
| codelabs.studio | f467c2468c6c4f0f470911fae3dbed96 |
| dancesteps.app | 35d7e3486b9bbcb490e4abb8decd07d4 |
| docu.expert | 09d0bb98d2f1e160406570eaa29c09d0 |
| el-mejor-dj.com | f5872b8157e9b380546a0a906ec735c2 |
| flirtmaster.app | d551fe8e057da4efa4374726c5b4d12a |
| iaprendo.online | 0575c13eccf8e862cb562392724a762e |
| kitt-ai.app | 23a89329575deaa2cb3e9f01ba3b27cc |
| mytradingai.expert | cabf70878c4245505764369b73e8a8f5 |
| pasosdebaile.app | 980aacb906db98b25f9dc241966638e3 |
| ticketsuite.pro | 38c72c27fd853763805bb9e913724ab5 |
| transfersmanager.ai | 9f9060c21f3dfd0c058ed080c8d11a9f |
| trichosuite.com | 27792fa6000cf1f41eae882dae85ec43 |
| tubexperto.com | 8da3722921fdba809dbd8d89f6b63612 |

### Cloudflare API Examples

```bash
# List DNS records for a zone
curl -s "https://api.cloudflare.com/client/v4/zones/ZONE_ID/dns_records" \
  -H "Authorization: Bearer CF_TOKEN" | python3 -m json.tool

# Create DNS record
curl -s -X POST "https://api.cloudflare.com/client/v4/zones/ZONE_ID/dns_records" \
  -H "Authorization: Bearer CF_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"type":"TXT","name":"domain.com","content":"v=spf1 ...","ttl":1}'

# Update DNS record
curl -s -X PATCH "https://api.cloudflare.com/client/v4/zones/ZONE_ID/dns_records/RECORD_ID" \
  -H "Authorization: Bearer CF_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"content":"new value"}'
```

## SMTP Configuration

- **Server**: mail.codelabs.studio
- **Port**: 587 (STARTTLS)
- **IMAP Port**: 993 (SSL/TLS)
- **Auth**: Email + password per account

## Postfix Configuration (on server)

- **HELO Map**: `/etc/postfix/smtp_helo_name`
- **TLS Mode**: `smtp_tls_security_level = dane`
- **Container**: `mailcowdockerized-postfix-mailcow-1`

### Restart Commands (on server)
```bash
cd /opt/mailcow && docker compose restart postfix-mailcow
cd /opt/mailcow && docker compose restart dovecot-mailcow
```

## Expected DNS Records per Domain

For each domain `DOMAIN`:

| Record | Type | Name | Content |
|--------|------|------|---------|
| Mail A | A | mail.DOMAIN | 46.62.213.212 |
| MX | MX | DOMAIN | mail.DOMAIN (priority 10) |
| SPF | TXT | DOMAIN | v=spf1 a mx ip4:46.62.213.212 ~all |
| DKIM | TXT | dkim._domainkey.DOMAIN | v=DKIM1; k=rsa; p=... (from Mailcow) |
| DMARC | TXT | _dmarc.DOMAIN | v=DMARC1; p=quarantine; rua=mailto:admin@DOMAIN |
| Autoconfig | CNAME | autoconfig.DOMAIN | autoconfig.codelabs.studio |
| Autodiscover | CNAME | autodiscover.DOMAIN | autodiscover.codelabs.studio |

## Email Account Passwords

Account passwords are stored in `/Users/josediaz/.config/codelabs/services.json` under each project's `email_accounts` section. Always read from there - never hardcode passwords.

## Test Gmail Account

- **Email**: dancestepsapp@gmail.com
- **Password**: Read from services.json -> `services.gmail_test` or project configs
