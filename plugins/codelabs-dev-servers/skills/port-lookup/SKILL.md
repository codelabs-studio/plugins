---
name: port-lookup
description: Identify which project and service uses a specific port. Searches .claude/servers.json across known projects, plus ~/.devproxy/config/routes.json. Triggers when user asks "what project uses port X", "who owns port X", "a quién pertenece el puerto X", "qué proyecto usa el puerto X", "what's on port X".
argument-hint: The port number to look up (e.g., "4875")
allowed-tools: Bash, Read, Glob, Grep
---

# Port lookup

`$ARGUMENTS` should contain a port number. If empty, ask for one.

## Step 1 — Check ~/.devproxy/config/routes.json

```bash
PORT="$1"
DEVPROXY_HOME="${DEVPROXY_HOME:-$HOME/.devproxy}"
ROUTES="$DEVPROXY_HOME/config/routes.json"

python3 -c "
import json
with open('$ROUTES') as f:
    data = json.load(f)
matches = [r for r in data['routes'] if str(r['upstream']).endswith(':$PORT')]
for m in matches:
    print(f\"{m.get('project','?')} | {m['domain']} | {m['upstream']}\")
"
```

## Step 2 — Check live process

```bash
lsof -iTCP:$PORT -sTCP:LISTEN -nP 2>/dev/null
```

If a process is listening, surface command + PID + working directory:

```bash
PID=$(lsof -ti:$PORT -sTCP:LISTEN 2>/dev/null | head -1)
[ -n "$PID" ] && lsof -p $PID 2>/dev/null | grep cwd | awk '{$1=""; $2=""; $3=""; $4=""; $5=""; $6=""; $7=""; $8=""; print $0}' | xargs
```

## Step 3 — Search all `.claude/servers.json` files (if needed)

If routes.json gives nothing useful, scan for project configs:

```bash
find ~ -maxdepth 6 -path '*/.claude/servers.json' -type f 2>/dev/null | while read f; do
    if grep -q "\"port\":[[:space:]]*$PORT[,}]" "$f"; then
        PROJECT=$(python3 -c "import json; print(json.load(open('$f')).get('project','?'))" 2>/dev/null)
        echo "$PROJECT | $f"
    fi
done
```

## Step 4 — Output

```markdown
# Port {port}

## Owner
- **Project**: {project}
- **Service**: {service name}
- **Domain**: {domain if any}
- **Status**: {running / idle}

## Live process (if any)
- **Command**: {command}
- **PID**: {pid}
- **Working dir**: {cwd}
```

If port is free and no project owns it: "Port {port} is free and not registered to any project."

## Anti-patterns

- ❌ Killing the process. This skill only identifies — use the `stop` skill to kill.
- ❌ Searching the entire filesystem with `find /`. Scope to home or known dev directories.
