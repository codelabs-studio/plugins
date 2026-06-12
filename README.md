# codelabs-plugins

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Plugins for [Claude Code](https://claude.com/claude-code) by [codelabs.studio](https://codelabs.studio). Production-grade tools for solo founders and small teams shipping ambitious products.

## What's inside

| Plugin | What it does |
|--------|--------------|
| [`codelabs-cofounder`](plugins/codelabs-cofounder) | Virtual co-founder with persistent project journal. Brutally honest posture (no sycophancy). Auto-routes questions to specialist sub-agents (CTO, CFO, PM, QA, UX, Security) when depth is needed. |
| [`codelabs-dev-servers`](plugins/codelabs-dev-servers) | Local dev server manager. Deterministic ports across projects, optional HTTPS dev domains via embedded Caddy + mkcert. Solves port collisions for multi-project setups. |
| [`codelabs-advisors`](plugins/codelabs-advisors) | Pre-launch audit suite. SEO, security (OWASP), performance (Core Web Vitals), DNS, database. Each audit produces a historical report. |
| [`codelabs-feature-port`](plugins/codelabs-feature-port) | Cross-project feature migration. Take a feature from project A, adapt it to project B's architecture and conventions. |
| [`codelabs-role-empathy`](plugins/codelabs-role-empathy) | User-centered feature development. Identifies user roles, generates personas, validates UX per role. Pairs with journey-map for role-based test coverage. |

## Install

Add the marketplace once:

```
/plugin marketplace add codelabs https://codelabs.studio/plugins/marketplace.json
```

Or, if you prefer the GitHub raw URL during development:

```
/plugin marketplace add codelabs https://raw.githubusercontent.com/codelabs-studio/plugins/main/marketplace.json
```

Then install whichever plugins you want:

```
/plugin install codelabs-dev-servers@codelabs
/plugin install codelabs-cofounder@codelabs
/plugin install codelabs-advisors@codelabs
/plugin install codelabs-feature-port@codelabs
/plugin install codelabs-role-empathy@codelabs
```

> **New here?** Start with `codelabs-dev-servers` (the most universally useful), then `codelabs-cofounder` if you want a strategic advisor.

## Bootstrap a fresh machine

If you're setting up a new Mac or onboarding a teammate, the [`codelabs-studio/setup`](https://github.com/codelabs-studio/setup) repo provides a one-line installer that handles dependencies (Caddy, mkcert, gh, jq, tmux), installs all these plugins, and wires up baseline configuration:

```bash
curl -fsSL https://codelabs.studio/setup | bash --personal
```

## Philosophy

Each plugin is **opinionated by default but unopinionated about your stack**:

- We don't assume you're using Next.js, Vue, FastAPI, or any specific framework — the plugins detect what you have and adapt.
- We don't assume you're using a specific managed service (Supabase, AWS, self-hosted PostgreSQL, etc.) — they read from your project config or ask once and remember.
- We don't soften feedback. The cofounder plugin in particular overrides Claude's default sycophantic behavior. If your idea has problems, you'll hear about them.

## Contributing

1. Fork the repo
2. Create a feature branch (`git checkout -b feature/my-improvement`)
3. Commit your changes (`git commit -am 'Add feature X'`)
4. Push to the branch (`git push origin feature/my-improvement`)
5. Open a PR

For new plugins or major features, please open an issue first to discuss the approach.

## Plugin development

Each plugin is self-contained in `plugins/<plugin-name>/` with this structure:

```
plugins/codelabs-foo/
├── .claude-plugin/
│   └── plugin.json     # Manifest (name, version, description, author)
├── README.md           # Plugin-specific docs
├── skills/             # Skills (each in its own subdirectory with SKILL.md)
├── agents/             # Specialized sub-agents (optional)
├── hooks/              # Event handlers (optional)
└── scripts/            # Bundled scripts referenced by skills (optional)
```

See the [Claude Code plugin docs](https://code.claude.com/docs/en/plugins) for the full spec.

## Versioning

Each plugin tracks its own version in its `plugin.json`. The `marketplace.json` at the repo root pins the version users will install. Bump per plugin when you ship a meaningful change; the marketplace.json `version` field tracks the catalog as a whole.

## License

MIT — see [LICENSE](LICENSE).

## Maintainers

[codelabs.studio](https://codelabs.studio)
