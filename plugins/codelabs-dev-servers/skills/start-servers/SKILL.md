---
name: start-servers
description: Start all development servers for the current project with deterministic ports. Two modes — "ports" (localhost:PORT, fastest) or "domains" (HTTPS via embedded Caddy). Auto-detects stack on first run, persists config in .claude/servers.json. Use when user says "start servers", "arranca servidores", "arranca el servidor", "launch dev", "start dev", "run dev", "pon a funcionar", "inicia el proyecto", "levanta los servicios", "start the project", "run the app".
argument-hint: Optional mode ("ports" or "domains") and/or service name (e.g., "ports", "domains", "ports web", "domains api")
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, AskUserQuestion
---

# Start servers

Arguments: `$ARGUMENTS`

## Step 1 — Resolve MODE (blocking)

Look at `$ARGUMENTS`:
- Contains `ports`/`port`/`local` → `MODE=ports`
- Contains `domains`/`domain`/`https`/`caddy` → `MODE=domains`
- Empty or unrecognized → check `.claude/servers.json` for `defaultMode`. If missing, ask the user with `AskUserQuestion`:
  - **Ports (recommended)**: localhost:PORT, no Caddy, fastest HMR. Daily dev.
  - **Domains (HTTPS)**: subdomains via Caddy. Necessary for Secure cookies, Service Workers, OAuth callbacks, simulating prod.

Don't proceed without MODE. Do NOT read files or run commands before this.

## Step 2 — Read or create `.claude/servers.json`

```bash
SERVERS_FILE=".claude/servers.json"
test -f "$SERVERS_FILE" && echo "EXISTS" || echo "MISSING"
```

### If exists
Read it. It has `services`, `ports`, optionally `domain`. Skip to Step 4 (or Step 3 if MODE=domains and `domain` is missing).

### If missing — auto-detect

Detect the stack:

1. **`package.json`** — scripts (`dev`, `start`, `worker`), deps signaling Redis (`ioredis`/`bullmq`), Postgres (`pg`/`@prisma/client`).
2. **`.env`/`.env.local`** — `PORT=`, `REDIS_PORT=`, `DATABASE_URL=`, `NEXT_PUBLIC_APP_URL=`.
3. **`docker-compose.yml`** — extra services.
4. **Framework configs** — `next.config.*`, `vite.config.*`, `nuxt.config.*`, `astro.config.*`.
5. **Monorepo signals** — `apps/`, `packages/`, npm/pnpm workspaces.
6. **Python** — `pyproject.toml`, `requirements.txt`, `main.py`/`app.py` for FastAPI/Flask.
7. **Go** — `go.mod`, `main.go`.

### Calculate deterministic base port

```bash
BASE_PORT=$(echo -n "$(basename "$PWD")" | cksum | awk '{print ($1 % 1200) * 5 + 3500}')
```

Range: 3500-9499. Block: 5 ports per project.

Offsets:
- `+0`: web
- `+1`: api
- `+2`: worker
- `+3`: cache (Redis, etc.)
- `+4`: db (only when running locally, not when using a managed service)

### Write initial `.claude/servers.json`

```json
{
  "project": "<basename>",
  "basePort": <BASE_PORT>,
  "ports": { "web": <BASE_PORT>, "api": <BASE_PORT+1>, ... },
  "services": {
    "web": {
      "port": <BASE_PORT>,
      "command": "<detected dev command with port substituted>",
      "type": "web"
    }
  },
  "createdAt": "<ISO date>"
}
```

### Update the project's `dev` script if needed

Many tools default to port 3000 / 5173 / 8000. Override the port in `package.json` scripts:
- Next.js: `"dev": "next dev -p {port}"`
- Vite: `"dev": "vite --port {port}"`
- Nuxt: `"dev": "nuxt dev --port {port}"`
- Astro: `"dev": "astro dev --port {port}"`

If the user has a `PORT` env var system, set that instead.

## Step 3 — Domain configuration (only if MODE=domains and domain missing)

Gather signals:
1. `package.json` `name`/`homepage`/`description`
2. `.env*` for `NEXT_PUBLIC_APP_URL`, `NEXTAUTH_URL`, `APP_URL`, `SITE_URL`, `BASE_URL`, `VITE_APP_URL` — extract hostnames
3. `vercel.json` `alias`
4. `CLAUDE.md` references
5. Existing routes in `~/.devproxy/config/routes.json`

Generate 3-4 proposals using `AskUserQuestion`. **Always include `{cleaned-name}.localhost` as option 1 (recommended)**. Reasons:
- No `/etc/hosts` edits — `*.localhost` resolves automatically (RFC 6761)
- HTTPS works via Caddy local CA
- Visually distinct from production — prevents OAuth/cookie/HSTS confusion
- Vercel `portless` works the same way

Other proposals: real production domain found in env (option 2 if it exists), then 1-2 TLD variants (`.app`, `.ai`, `.io`, `.studio`). **Avoid `.dev`** (HSTS preload forces HTTPS, breaks fallbacks). **Avoid `.local`** (mDNS conflict on macOS).

Once chosen:
1. Update `.claude/servers.json` with `domain` field.
2. Set `subdomain` per service:
   - `web` named `landing`/`main`/`marketing` → `null` (root)
   - `api`/`backend` → `api`
   - `worker` → no subdomain (not navigable)
   - Single web service → `null`
   - Otherwise → service key
3. Compute `url` field per service: `https://dev.{subdomain ? subdomain + '.' : ''}{domain}`.

## Step 4 — Worktree detection (only if MODE=domains)

When the cwd is a linked git worktree, prepend the branch name as a sub-subdomain so each worktree has isolated cookies/sessions:

```bash
GIT_DIR=$(git rev-parse --git-dir 2>/dev/null)
BRANCH_PREFIX=""
if [ -n "$GIT_DIR" ] && echo "$GIT_DIR" | grep -q "worktrees"; then
  BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  BRANCH_PREFIX=$(echo "$BRANCH" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g; s/--*/-/g; s/^-//; s/-$//')
fi
```

When `BRANCH_PREFIX` is non-empty, prepend it to all dev URLs and Caddy routes.

## Step 5 — Port collision check

For each service:
```bash
lsof -iTCP:$PORT -sTCP:LISTEN -nP
```

- **Free** → continue
- **In use by our service (same command)** → mark "Already running"; don't restart
- **In use by something else** → ask user: kill / find new port / skip

## Step 6 — Sync env files (only if MODE=domains)

For each navigable service, in `.env.local` (preferred) or `.env`, update only existing variables:
- `NEXT_PUBLIC_APP_URL` → service URL (with worktree prefix if applicable)
- `NEXTAUTH_URL` → service URL
- `APP_URL`, `BASE_URL`, `SITE_URL`, `VITE_APP_URL` → service URL
- `PORT` → service port

Never modify `.env.example`. If `.env.local` doesn't exist but `.env.example` does, copy and substitute.

## Step 7 — Start services

In dependency order (db → cache → worker → api → web). For each:

```bash
# macOS: bump file descriptors so Node doesn't hit EMFILE
ulimit -n 65536 && {service.command}
```

Use `run_in_background: true` for long-running processes. After each, healthcheck:
```bash
sleep 2
curl -s -o /dev/null -w '%{http_code}' http://localhost:$PORT
```
Accept 200/301/302/307 as healthy. Wait 3-5s between dependent services if the next one needs the previous.

## Step 8 — Configure Caddy proxy (only if MODE=domains)

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/caddy-ensure.sh"

# For each navigable service:
FINAL_DOMAIN="dev.${SUBDOMAIN:+${SUBDOMAIN}.}${PROJECT_DOMAIN}"
[ -n "$BRANCH_PREFIX" ] && FINAL_DOMAIN="${BRANCH_PREFIX}.${FINAL_DOMAIN}"
"${CLAUDE_PLUGIN_ROOT}/scripts/caddy-add-route.sh" "$FINAL_DOMAIN" "$PORT" "$PROJECT"
done

"${CLAUDE_PLUGIN_ROOT}/scripts/hosts-sync.sh"
```

Verify HTTPS:
```bash
curl -sk -o /dev/null -w "%{http_code}" https://$FINAL_DOMAIN
```

## Step 9 — Summary

### Ports mode
```
## {Project} — Development (Ports Mode)

| Service | Port | Status | URL                       |
|---------|------|--------|---------------------------|
| Web     | 4875 | Ready  | http://localhost:4875     |
| API     | 4876 | Ready  | http://localhost:4876     |

Tip: run with "domains" arg for HTTPS subdomains.
```

### Domains mode
```
## {Project} — Development (Domains Mode{worktree:  · worktree: BRANCH})

| Service | Port | Status | Dev URL                           |
|---------|------|--------|-----------------------------------|
| Web     | 4875 | Ready  | https://dev.myapp.localhost       |
| API     | 4876 | Ready  | https://dev.api.myapp.localhost   |

Tip: run with "ports" arg for direct localhost (faster HMR).
```

## Critical rules

- **NEVER use default ports** (3000, 5000, 5173, 8000, 8080). Always use deterministic hash.
- **Same project = same ports forever.** This is a feature.
- **Ports mode**: never show `https://dev.*` URLs.
- **Domains mode**: never show `http://localhost:*` URLs.
- **macOS**: prefix with `ulimit -n 65536 &&`.
- **Already-running services**: don't restart, mark as "Already running".

## Anti-patterns

- ❌ Re-asking the domain question on subsequent runs (it's persisted).
- ❌ Killing a port the user said to skip.
- ❌ Modifying `.env.example`.
- ❌ Starting services without checking ports first.
