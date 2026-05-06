---
name: add-service
description: Add a new service (worker, queue, additional API, admin panel, etc.) to an existing project's .claude/servers.json. Calculates the next available port within the project's deterministic block, prompts for service type and command, registers Caddy route if domains mode is configured. Use when user says "add service", "añadir servicio", "agregar otro servidor", "add worker", "add api", "new service for the project", "nuevo servicio".
argument-hint: Optional — service name (e.g., "worker", "admin") and/or type (e.g., "worker queue", "admin web")
allowed-tools: Bash, Read, Write, Edit, AskUserQuestion
---

# Add service to project

## Step 1 — Read existing config

```bash
test -f .claude/servers.json || (echo "No .claude/servers.json. Run 'start-servers' first to bootstrap." && exit 1)
cat .claude/servers.json
```

If the project hasn't been initialized, tell the user to run `/start-servers` first to auto-detect the stack and create the initial config.

## Step 2 — Gather service info

If `$ARGUMENTS` already specifies name + type, use them. Otherwise ask via `AskUserQuestion`:

1. **Service name** — short identifier (e.g., `worker`, `admin`, `cron`, `webhooks`).
2. **Service type** — pick one:
   - `web` — navigable HTTP service (gets a subdomain)
   - `api` — backend API (gets `api` subdomain by default)
   - `worker` — background process, not navigable, no Caddy route
   - `cache` — Redis or similar, not navigable
   - `db` — database, not navigable
3. **Start command** — how to launch it (e.g., `node worker.js`, `bullmq-worker`, `celery -A app worker`).

## Step 3 — Allocate next port

Read existing ports from `services.*.port` and pick the next free offset within the project's block (basePort + 0..4). If all 5 are used, allocate basePort+5..+9 (extend the block).

```bash
USED_PORTS=$(jq -r '.services | to_entries | .[].value.port' .claude/servers.json | sort -n)
BASE=$(jq -r '.basePort' .claude/servers.json)
for offset in 0 1 2 3 4 5 6 7 8 9; do
    P=$((BASE + offset))
    if ! echo "$USED_PORTS" | grep -q "^$P$"; then
        echo "NEW_PORT=$P"
        break
    fi
done
```

## Step 4 — Update `.claude/servers.json`

```bash
python3 -c "
import json
from datetime import datetime, timezone

with open('.claude/servers.json') as f:
    data = json.load(f)

name = '$NAME'
data['services'][name] = {
    'port': $NEW_PORT,
    'command': '$COMMAND',
    'type': '$TYPE'
}

# If type is web/api, compute subdomain
if '$TYPE' in ('web', 'api'):
    if '$TYPE' == 'api' and 'api' not in data['services']:
        data['services'][name]['subdomain'] = 'api'
    else:
        data['services'][name]['subdomain'] = name

# Compute URL if domain configured
if 'domain' in data and data['services'][name].get('subdomain') is not None:
    sub = data['services'][name]['subdomain']
    data['services'][name]['url'] = f'https://dev.{sub}.{data[\"domain\"]}' if sub else f'https://dev.{data[\"domain\"]}'

# Update ports map
data.setdefault('ports', {})[name] = $NEW_PORT

# Bump updated_at
data['updatedAt'] = datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')

with open('.claude/servers.json', 'w') as f:
    json.dump(data, f, indent=2)
"
```

## Step 5 — Register Caddy route (only for `web`/`api` types AND if `domain` is configured)

```bash
if [[ "$TYPE" == "web" || "$TYPE" == "api" ]] && jq -e '.domain' .claude/servers.json >/dev/null 2>&1; then
    DOMAIN=$(jq -r '.domain' .claude/servers.json)
    SUB=$(jq -r ".services.\"$NAME\".subdomain" .claude/servers.json)
    [ "$SUB" != "null" ] && FINAL_DOMAIN="dev.${SUB}.${DOMAIN}" || FINAL_DOMAIN="dev.${DOMAIN}"
    PROJECT=$(jq -r '.project' .claude/servers.json)

    "${CLAUDE_PLUGIN_ROOT}/scripts/caddy-add-route.sh" "$FINAL_DOMAIN" "$NEW_PORT" "$PROJECT"
fi
```

## Step 6 — Summary

```
## Added service "{name}" to {project}

- Type: {type}
- Port: {port}
- Command: {command}
- URL: {url if web/api with domain, else "—"}

To start: re-run /start-servers (the new service will be picked up).
```

If the user wants to start *just* the new service immediately, suggest: `/start-servers {name}`.

## Anti-patterns

- ❌ Allocating ports outside the project's deterministic block — breaks reproducibility.
- ❌ Adding a Caddy route for `worker`/`cache`/`db` types — they're not navigable.
- ❌ Hardcoding the port — always derive from the basePort.
