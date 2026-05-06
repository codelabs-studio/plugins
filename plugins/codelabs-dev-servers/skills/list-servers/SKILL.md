---
name: list-servers
description: Show all dev servers currently running across all projects. Reads ~/.devproxy/config/routes.json plus active port scan to surface what's up. Use when user says "list servers", "what servers are running", "qué servidores hay corriendo", "show running dev", "list dev servers", "que esta corriendo", "puertos activos".
allowed-tools: Bash, Read
---

# List servers

## Step 1 — Read all known routes

```bash
DEVPROXY_HOME="${DEVPROXY_HOME:-$HOME/.devproxy}"
test -f "$DEVPROXY_HOME/config/routes.json" && cat "$DEVPROXY_HOME/config/routes.json"
```

This gives you every domain → port mapping ever registered, grouped by project.

## Step 2 — Check which ports are actually listening

```bash
lsof -iTCP -sTCP:LISTEN -nP 2>/dev/null | awk 'NR>1 {print $9}' | grep -oE ':[0-9]+$' | tr -d ':' | sort -u
```

## Step 3 — Cross-reference

For each route in `routes.json`:
- If its port is in the listening set → status: 🟢 Running
- If not → status: ⚫ Idle (route exists but service not running)

## Step 4 — Discover orphan ports

Ports that are listening but NOT in any route. These are services started without going through the plugin (or projects without Caddy routes). Surface them separately.

For each orphan port:
```bash
lsof -iTCP:$PORT -sTCP:LISTEN -nP | awk 'NR==2 {print $1, $2}'
# command, pid
```

## Step 5 — Output

```markdown
# Dev servers

## 🟢 Running

### {project}
| Service | Port | URL |
|---------|------|-----|
| web | 4875 | https://dev.myapp.localhost |
| api | 4876 | https://dev.api.myapp.localhost |

### {another project}
...

## ⚫ Idle (route registered, not running)
- {project}: {domain} → port {port}

## ⚠️ Orphan ports (running, no route)
| Port | Command | PID |
|------|---------|-----|
| 3000 | node | 12345 |
```

If no servers are running across all projects, say so directly: "No dev servers running."

## Anti-patterns

- ❌ Listing every line of `lsof` output. Group and dedupe.
- ❌ Ignoring orphan ports — they're often the source of "port already in use" surprises.
