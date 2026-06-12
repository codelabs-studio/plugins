---
name: readme
description: Generate a polished, attractive README.md for the current project's git repository, citing all documentation and providing quick access links
arguments:
  - name: style
    description: "README style: 'full' (comprehensive with all sections), 'minimal' (clean and concise), 'landing' (marketing-oriented landing page). Default: full"
    required: false
    default: "full"
  - name: lang
    description: "Language: 'es' (Spanish), 'en' (English), 'bilingual' (both). Default: detect from project"
    required: false
    default: "auto"
user_invocable: true
---

# Generate Project README

Generate a polished, visually attractive `README.md` for the current project's git repository.

**Style**: {{ style }}
**Language**: {{ lang }}

## Protocol

### Phase 1: Project Analysis

Gather all project information by reading these files (in parallel where possible):

1. **Project identity**:
   - `package.json` or `pyproject.toml` or `Cargo.toml` or `composer.json` (name, version, description, scripts, dependencies)
   - Existing `README.md` (preserve any manual content the user wants to keep)
   - `.env.example` or `.env.local.example` (required environment variables)

2. **Documentation inventory** - Find ALL documentation files:
   ```bash
   find . -name "*.md" -not -path "*/node_modules/*" -not -path "*/.git/*" | sort
   ```
   Read the first 20 lines of each to understand its purpose.

3. **Project structure**:
   - Run `ls` on root directory
   - Check for `src/`, `app/`, `pages/`, `api/`, `lib/`, `components/`, `tests/`, `scripts/`
   - Identify framework (Next.js, Vite, Express, Fastify, Django, Rails, etc.)

4. **Tech stack detection**:
   - Dependencies from package manager files
   - Config files (next.config.*, vite.config.*, tsconfig.json, tailwind.config.*, etc.)
   - Database (prisma, drizzle, migrations/, pg, mongoose, etc.)
   - Auth (next-auth, keycloak, clerk, auth0, etc.)
   - Deployment (Dockerfile, docker-compose.yml, vercel.json, fly.toml, etc.)

5. **Git context**:
   - Remote URL (for repo link)
   - License file
   - `.claude/servers.json` (if exists, for dev setup section)

6. **Visual assets**:
   - Check for `public/logo*`, `public/favicon*`, `public/og-image*`
   - Check for screenshots in `docs/screenshots/` or similar

### Phase 2: README Generation

Generate the README with these sections based on the chosen style:

---

#### Style: `full` (default)

```markdown
<div align="center">

# [Project Name]

**[One-line tagline from package.json description or inferred]**

[Tech badges - framework, language, database, deployment platform]

[Link to live site if detectable] | [Link to docs]

</div>

---

## About

[2-3 paragraph description of what the project does, who it's for, and why it exists.
Infer from docs, package.json description, and project structure.]

## Features

- [Feature 1 with brief description]
- [Feature 2 with brief description]
- [Feature 3 with brief description]
[Infer from routes, components, API endpoints, and docs/FEATURE_TRACKING.md if exists]

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Next.js 16 / Vite / etc. |
| Language | TypeScript / Python / etc. |
| Database | PostgreSQL / etc. |
| Auth | NextAuth + Keycloak / etc. |
| Styling | Tailwind CSS / etc. |
| Deployment | Docker / Vercel / etc. |
[Detect from actual dependencies, not generic]

## Getting Started

### Prerequisites

- Node.js >= 18 (or whatever is in engines)
- [Other requirements]

### Installation

```bash
git clone [repo-url]
cd [project-name]
npm install
```

### Environment Variables

Copy `.env.example` to `.env.local` and fill in:

```env
# [Group 1: Essential]
DATABASE_URL=           # PostgreSQL connection string
NEXTAUTH_SECRET=        # Random secret for auth

# [Group 2: Services]
...
```
[Read from .env.example or .env.local.example. NEVER include actual values.]

### Development

```bash
npm run dev             # Start development server
```

[If .claude/servers.json exists, document the full dev setup:]
```bash
/start                  # Start all services (Redis, Next.js, Worker)
```

| Service | Port | URL |
|---------|------|-----|
| [from servers.json] | | |

## Project Structure

```
[project-name]/
├── src/
│   ├── app/            # Next.js App Router pages
│   ├── components/     # React components
│   ├── lib/            # Core business logic
│   └── hooks/          # Custom React hooks
├── docs/               # Documentation
├── migrations/         # Database migrations
└── scripts/            # Utility scripts
```
[Adapt to actual project structure. Only show top 2 levels.]

## Documentation

| Document | Description |
|----------|-------------|
| [FEATURE_TRACKING.md](docs/FEATURE_TRACKING.md) | Feature status and roadmap |
| [CHANGELOG.md](docs/CHANGELOG.md) | Version history |
| [ARCHITECTURE.md](docs/ARCHITECTURE.md) | System architecture |
| ... | ... |
[List ALL .md files in docs/ with brief description inferred from content]

## Scripts

| Command | Description |
|---------|-------------|
| `npm run dev` | Start development server |
| `npm run build` | Production build |
| `npm run test` | Run tests |
| ... | ... |
[From package.json scripts, skip internal/obscure ones]

## Deployment

[Brief deployment instructions based on detected platform]

## License

[From LICENSE file or package.json]

---

<div align="center">
Built with [detected tech] by [author from package.json]
</div>
```

---

#### Style: `minimal`

Same structure but:
- No badges section
- Features as a simple bullet list (max 5)
- No project structure diagram
- No scripts table
- Shorter descriptions everywhere
- Skip Documentation table (just link to docs/ folder)

---

#### Style: `landing`

Marketing-oriented:
- Hero section with logo and tagline
- "Why [Project Name]?" section with value propositions
- Feature showcase with descriptions (not just bullets)
- Screenshots section (if available in docs/screenshots/)
- Call to action (getting started link)
- Testimonials section (placeholder)
- Comparison table vs alternatives (if competitive analysis docs exist)
- Footer with links

---

### Phase 3: Badge Generation

Generate shields.io badges for:

- **Framework**: `![Next.js](https://img.shields.io/badge/Next.js-16-black?style=flat-square&logo=next.js)`
- **Language**: `![TypeScript](https://img.shields.io/badge/TypeScript-5.3-blue?style=flat-square&logo=typescript)`
- **Database**: `![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-336791?style=flat-square&logo=postgresql)`
- **Deployment**: `![Docker](https://img.shields.io/badge/Docker-deployed-2496ED?style=flat-square&logo=docker)`
- **Styling**: `![Tailwind](https://img.shields.io/badge/Tailwind-3.4-38B2AC?style=flat-square&logo=tailwind-css)`

Detect versions from actual dependencies, not placeholders.

### Phase 4: Documentation Links

For EVERY `.md` file in the project's `docs/` directory:

1. Read the first 5-10 lines to extract the title and purpose
2. Create a relative link: `[Title](docs/filename.md)`
3. Write a 1-line description
4. Group by subdirectory if docs has subdirectories

### Phase 5: Write and Verify

1. **Ask user before overwriting**: If `README.md` already exists, show a diff summary and ask for confirmation
2. **Write the file**: Use the Write tool
3. **Verify links**: Check that all documentation links point to files that actually exist
4. **Show preview**: Display the first 30 lines of the generated README

### Language Rules

- **`auto`**: Detect from existing README, package.json description, or docs language
- **`es`**: All section headers and descriptions in Spanish
- **`en`**: All section headers and descriptions in English
- **`bilingual`**: English headers with Spanish descriptions (or vice versa based on project)

### Important Rules

- **NEVER include API keys or secrets** in the README, even as examples
- **NEVER fabricate features** - only list what actually exists in the code
- **ALWAYS use relative links** for documentation (not absolute paths)
- **ALWAYS verify linked files exist** before adding links
- **Keep badges accurate** - use actual versions from dependencies
- **Preserve user content** - if the existing README has custom sections, ask before removing
