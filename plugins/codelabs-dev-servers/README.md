# codelabs-dev-servers

Local development server manager with **deterministic ports** and **optional HTTPS dev domains**. No more "port 3000 already in use" pain. No more memorizing which port is which app.

## Why this exists

If you work on more than one project, you've hit these problems:

- **Port collisions**: app A on 3000, app B also defaults to 3000, second one silently steals the port.
- **Port amnesia**: which port was the dashboard? Was it 5173 or 8080?
- **HTTPS for OAuth/cookies**: real production uses HTTPS. Local dev on `http://localhost:3000` doesn't simulate this — your Service Workers, Secure cookies, and OAuth callbacks behave differently.

This plugin solves all three. Same project name = same ports forever (deterministic hash). Optional HTTPS subdomains routed via embedded Caddy reverse proxy.

## Two modes

### Ports mode (default, fastest)
- `http://localhost:4875` style URLs
- Zero overhead, instant HMR
- Use for daily development

### Domains mode (HTTPS via Caddy)
- `https://dev.myapp.localhost` style URLs
- Real TLS via mkcert local CA
- Necessary for: Secure cookies, Service Workers, OAuth callbacks, simulating production
- Subdomain per service: `dev.api.myapp.localhost`, `dev.app.myapp.localhost`, etc.

## Skills

- **`init`** — Install dependencies (Caddy, mkcert) and bootstrap `~/.devproxy/`. Run once per machine.
- **`start`** — Start all dev servers for the current project. Auto-detects stack on first run.
- **`stop`** — Stop all dev servers for the current project. Cleanly kills by PID and by port.
- **`restart`** — Stop + start.
- **`list`** — Show all servers running across all projects.
- **`port-lookup`** — Identify which project owns a given port.
- **`add-service`** — Add a new service (e.g. worker, queue) to an existing project.
- **`tmux-projects`** — List development sessions in tmux.

## Deterministic port assignment

Same project directory name → same port range, forever:

```
BASE_PORT = (cksum(project_name) % 1200) * 5 + 3500
```

- Range: 3500-9499 (avoids common defaults)
- Block: 5 ports per project (web, api, worker, cache, db)
- Reproducible across machines: clone the repo on a different Mac, get the same ports

## Project config: `.claude/servers.json`

The plugin generates and reads this file in your project root. Example:

```json
{
  "project": "myapp",
  "basePort": 4875,
  "domain": "myapp.localhost",
  "ports": { "web": 4875, "api": 4876, "worker": 4877 },
  "services": {
    "web": {
      "port": 4875,
      "command": "next dev -p 4875",
      "subdomain": null,
      "url": "https://dev.myapp.localhost"
    },
    "api": {
      "port": 4876,
      "command": "uvicorn main:app --port 4876",
      "subdomain": "api",
      "url": "https://dev.api.myapp.localhost"
    }
  }
}
```

## Where data lives

```
~/.devproxy/
├── Caddyfile               ← auto-generated from routes.json
├── config/
│   └── routes.json         ← source of truth for all routes
└── certs/                  ← mkcert local CA
```

`/etc/hosts` is managed in a marked block:
```
# >>> dev-proxy managed routes (DO NOT EDIT)
127.0.0.1 dev.myapp.localhost
# <<< dev-proxy managed routes
```

## Install

```
/plugin marketplace add codelabs https://codelabs.studio/plugins/marketplace.json
/plugin install codelabs-dev-servers@codelabs
```

Then run the `init` skill once per machine to install Caddy + mkcert and bootstrap `~/.devproxy/`.

## Requirements

- macOS or Linux (tested on macOS; Linux works with sudo for /etc/hosts)
- Homebrew (or apt/equivalent for Linux)
- Python 3 (used by scripts to manipulate JSON — already on most systems)

## License

MIT
