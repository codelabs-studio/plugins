---
name: stop-servers
description: Stop all dev servers for the current project. Cleanly kills by PID (when started via this plugin) AND by port (fallback for orphaned processes). Use when user says "stop servers", "para los servidores", "stop dev", "kill the servers", "matar los servidores", "para el dev", "detener servicios".
argument-hint: Optional service name (e.g., "web", "api") to stop only that service. Without args, stops all services for the project.
allowed-tools: Bash, Read
---

# Stop servers

## Step 1 — Read project config

```bash
test -f .claude/servers.json && cat .claude/servers.json
```

If missing, the user has nothing started by this plugin in this dir. Tell them; don't try to kill random processes.

## Step 2 — Determine target

If `$ARGUMENTS` names a service (`web`, `api`, etc.) → only stop that service.
Otherwise → stop all services in `services`.

## Step 3 — Kill by PID first (if recorded)

If `.claude/servers.json` has a `pids` field (this plugin tracks them):

```bash
for pid in $(jq -r '.pids[]' .claude/servers.json 2>/dev/null); do
  kill "$pid" 2>/dev/null && echo "Killed PID $pid"
done
```

Wait 1 second, then check if any are still alive:
```bash
kill -0 "$pid" 2>/dev/null && kill -9 "$pid"
```

## Step 4 — Kill by port (fallback for orphans)

For every port in `services.{key}.port` (or matching the targeted service):

```bash
for port in $TARGET_PORTS; do
  PIDS=$(lsof -ti:"$port" -sTCP:LISTEN 2>/dev/null)
  if [ -n "$PIDS" ]; then
    echo "$PIDS" | xargs kill 2>/dev/null
    sleep 1
    # Force kill if still alive
    PIDS=$(lsof -ti:"$port" -sTCP:LISTEN 2>/dev/null)
    [ -n "$PIDS" ] && echo "$PIDS" | xargs kill -9 2>/dev/null
    echo "Port $port: cleared"
  else
    echo "Port $port: already free"
  fi
done
```

This handles the common case where tmux/nodemon/etc. spawned processes whose PIDs the plugin didn't record.

## Step 5 — Optional: remove Caddy routes

If MODE was `domains` for this project, the user might want to keep the routes (so they work next time without re-adding) OR remove them.

**Default: keep them.** Routes are passive — they don't consume resources when the upstream is down.

If the user passed `--clean` or similar, remove project routes:
```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/caddy-remove-route.sh" --project "$PROJECT_NAME"
```

## Step 6 — Clear `pids` field

```bash
python3 -c "
import json
with open('.claude/servers.json') as f:
    data = json.load(f)
data.pop('pids', None)
with open('.claude/servers.json', 'w') as f:
    json.dump(data, f, indent=2)
"
```

## Step 7 — Summary

```
## {Project} — Stopped

| Service | Port | Status |
|---------|------|--------|
| web     | 4875 | Stopped |
| api     | 4876 | Stopped |
| worker  | 4877 | Already free |
```

If any port couldn't be cleared, show which and the PID still holding it. The user may need to investigate (e.g., another project using the same port unexpectedly).

## Anti-patterns

- ❌ `pkill -f "next dev"` — too broad, kills other projects.
- ❌ Killing without checking PIDs first — racy.
- ❌ Removing Caddy routes by default — passive routes don't hurt anyone.
