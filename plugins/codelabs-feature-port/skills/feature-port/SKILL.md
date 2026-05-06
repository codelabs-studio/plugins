---
name: feature-port
description: Migrates/ports a feature from one project to another. Deep-analyzes the feature in the source project, understands it in isolation, then adapts and implements it in the target project respecting the target's architecture, conventions, tech stack, and role system.
argument-hint: "[feature] from [project-a] to [project-b]"
model: opus
---

# Feature Port - Cross-Project Feature Migration

## When to Use

- When you've built something great in Project A and want it in Project B
- When you see a feature in one project that would benefit another
- After using `/feature-analyze` to identify a feature worth porting
- When you want to replicate a specific capability across projects

## Input

The user will provide (in this order):
1. **Feature name/description** - what to port (can be multi-word)
2. **Source project** - where the feature currently lives (after `from`)
3. **Target project** - where the feature should be ported to (after `to`)

All projects are located under `/Users/josediaz/Dev/code/`.

**Expected format**: `/feature-port [feature] from [source-project] to [target-project]`

Example invocations:
- `/feature-port chatbot from almasuite.coach to fittrack-pro`
- `/feature-port audit-logs from project-a to project-b`
- `/feature-port google gemini ai image editor from image-metadata to trichosuite`
- "Port the notification system from X to Y"
- "Copy the check-in feature from almasuite to project-z"

### Argument Parsing

Parse arguments using `from` and `to` as delimiters:
- Everything before `from` = feature name
- Between `from` and `to` = source project
- After `to` = target project

**If `from`/`to` keywords are missing**: Do NOT guess. Instead, list the folders in `/Users/josediaz/Dev/code/` to identify which words are project names, and ask the user to confirm if ambiguous.

If any information is missing or ambiguous, ask the user.

## Process

### Phase 1: Source Feature Extraction

Use the `feature-extractor` agent to deeply analyze the feature in the source project.

The agent will produce:
- Complete file map of the feature
- Data model documentation
- Business logic extraction
- UI/UX pattern documentation
- Integration points
- A technology-agnostic BLUEPRINT

**This phase is READ-ONLY on the source project.**

### Phase 2: Target Project Analysis

Analyze the target project to understand:

1. **Tech Stack**: What framework, language, database, styling, etc.
2. **Architecture Patterns**: How is code organized? What patterns are used?
3. **Existing Features**: What's already built? Avoid duplicating.
4. **Role System**: What user roles exist? Check `docs/ROLE_EMPATHY_ANALYSIS.md`.
5. **Design System**: What does the UI look like? Colors, components, styling approach.
6. **Conventions**: Naming, file organization, import patterns, error handling.
7. **Database**: What ORM, what schema patterns, what naming conventions.
8. **API Layer**: REST, tRPC, GraphQL? What patterns are used?

Read these files in the target project:
- `package.json` / equivalent
- `README.md`
- `CLAUDE.md` / `.claude/CLAUDE.md`
- `docs/ROLE_EMPATHY_ANALYSIS.md`
- `docs/DESIGN_SYSTEM_ANALYSIS.md`
- `docs/FEATURE_TRACKING.md`
- Sample route/page files (to understand patterns)
- Sample API endpoint files (to understand patterns)
- Database schema files (to understand conventions)

### Phase 3: Adaptation Plan

Create a detailed plan that maps the source feature to the target project.

Present this plan to the user BEFORE implementing:

```
FEATURE PORT PLAN
═══════════════════════════════════════════════

SOURCE: [project] → TARGET: [project]
FEATURE: [name]

## What's Being Ported
[2-3 sentence description of the feature's essence]

## Tech Stack Translation
┌─────────────────┬─────────────────────┬─────────────────────┐
│ Aspect          │ Source              │ Target              │
├─────────────────┼─────────────────────┼─────────────────────┤
│ Framework       │ [e.g., Next.js 14]  │ [e.g., SvelteKit]   │
│ Database        │ [e.g., Prisma]      │ [e.g., Drizzle]     │
│ API             │ [e.g., tRPC]        │ [e.g., REST]        │
│ Styling         │ [e.g., Tailwind]    │ [e.g., CSS Modules] │
│ Auth            │ [e.g., NextAuth]    │ [e.g., Lucia]       │
└─────────────────┴─────────────────────┴─────────────────────┘

## Data Model Changes
[Tables/fields to create, how they map from source schema to target schema]

## Role Adaptation
[How the feature maps to the target project's roles]
- Source role [X] → Target role [Y]
- Permission changes needed
- UI adjustments per role

## Files to Create/Modify
NEW FILES:
  - [path] - [purpose]
  - [path] - [purpose]

MODIFIED FILES:
  - [path] - [what changes and why]

## Dependencies to Add
  - [package] - [purpose] - [alternative if target uses something different]

## Environment Variables Needed
  - [VAR] - [purpose]

## What Changes from Source
[Specific adaptations being made and WHY]
1. [Change] - [Reason]
2. [Change] - [Reason]

## What Stays the Same
[Core logic/patterns being preserved]

## Risks & Considerations
- [Risk 1 and mitigation]
- [Risk 2 and mitigation]

## Estimated Scope
- Database: [N tables, N migrations]
- API: [N endpoints/procedures]
- UI: [N pages, N components]
- Tests: [what testing is recommended]
```

### Phase 4: User Approval

**STOP and present the plan to the user.** Wait for approval before implementing.

The user may:
- Approve as-is → proceed to Phase 5
- Request changes → update plan and re-present
- Ask questions → answer and re-present if needed
- Cancel → stop (no changes made)

### Phase 5: Implementation

Execute the migration following the approved plan:

**Order of operations:**

1. **Database First**
   - Create schema files / migration files
   - Add new tables, fields, enums
   - Run migrations (if user approves)

2. **Types & Interfaces**
   - Create TypeScript types / interfaces / Zod schemas
   - Ensure type safety from the start

3. **Backend Logic**
   - API endpoints / procedures / routes
   - Service layer / business logic
   - Integrations (external APIs, etc.)

4. **Frontend**
   - Pages / routes
   - Components (feature-specific)
   - State management / hooks
   - Forms and validation

5. **Wiring**
   - Navigation (add to sidebar, menus)
   - Permissions / auth guards
   - Configure environment variables

6. **Documentation**
   - Update `docs/FEATURE_TRACKING.md` in target project
   - Update `docs/CHANGELOG.md` if exists

### Phase 6: Validation

After implementation:

1. **Type Check** - Run the project's type checker (tsc, etc.)
2. **Lint** - Run linter to catch convention violations
3. **Build** - Verify the project builds
4. **Visual Check** - If Playwright is available, take screenshots of the new feature
5. **Role Check** - If role empathy analysis exists, validate the feature matches role expectations

Report any issues found and fix them.

## Important Rules

### DO:
- Respect the target project's EXISTING patterns (naming, file structure, import style)
- Adapt the UI to match the target's design system
- Map roles correctly (source role X might not exist in target)
- Use the target project's existing utilities and components (don't duplicate)
- Create proper migrations (never modify schema files directly in production projects)
- Handle the case where the target already has a similar (but different) feature

### DON'T:
- Don't blindly copy-paste code from source to target
- Don't bring source project's dependencies if the target has equivalents
- Don't ignore the target project's conventions to match the source
- Don't create a "Frankenstein" mix of both project's patterns
- Don't skip the planning phase - ALWAYS present the plan first
- Don't modify the source project (read-only)
- Don't assume the same database, ORM, or API layer

### EDGE CASES:
- **Same tech stack**: Faster port, but still adapt to conventions
- **Different tech stack**: Focus on the blueprint, implement natively
- **Feature partially exists**: Identify overlap, port only what's missing
- **Missing roles**: Suggest role mapping, ask user for guidance
- **Missing dependencies**: Present alternatives, let user choose
- **Database conflicts**: Check for naming collisions, schema conflicts

## After Completion

1. Summarize what was ported and what was adapted
2. List any TODO items that need manual attention
3. Suggest running `/ux-validate` if role empathy analysis exists in target
4. Offer to update documentation
