---
name: brainstorm
description: Generative brainstorming session with market research and idea generation. Use when user says "brainstorm", "/brainstorm", "let's explore", "ideate", "generate ideas about X", "ideas para X", "qué podríamos construir en Y", "explore opportunities in Z", or wants to generate ideas around a topic with market signals (not just blind ideation). Combines web research with structured generation.
argument-hint: Topic or domain (e.g., "AI tools for solo developers", "B2B SaaS in Spain", "things adjacent to my current portfolio")
allowed-tools: WebSearch, WebFetch, Read, Write, Bash, AskUserQuestion
---

# Brainstorm — generative session with signal

Brainstorming without market research is just guessing. This skill grounds idea generation in real signals.

## Step 1 — Frame the topic

If `$ARGUMENTS` is too broad ("ideas for AI"), narrow it with one or two questions:

- What's the **constraint** you'd accept? (Time-to-MVP < X weeks, budget < €Y, must use existing skills, must complement project Z)
- What's the **success criterion**? (Revenue, learning, leverage on existing portfolio, market positioning)

If the user has an active portfolio (read `~/.config/codelabs/projects.json` if present, or scan `~/.config/codelabs/cofounder/` for project journals), surface it: ideas should usually leverage existing skills/infrastructure unless the user explicitly wants a clean slate.

## Step 2 — Gather signal (web research)

Run 2-4 targeted searches before generating ideas. The goal is to ground ideation in current reality, not training-data assumptions.

Useful query patterns:
- "{topic} startups 2026" — surface recent entrants
- "{topic} reddit pain points" — surface unmet user needs
- "{topic} site:producthunt.com" — surface what's launching
- "{topic} y combinator latest batch" — surface what investors are betting on

Extract from results:
- **Painful workarounds** users describe (these are the gold)
- **Recently funded** companies (signal that investors believe)
- **Failed companies** in space (cautionary signals)
- **Adjacent markets** that came up unexpectedly

## Step 3 — Generate ideas (structured)

Produce 8-12 ideas across three buckets. Don't censor at this stage; the next step does the filtering.

### Bucket A: Sharp & narrow (4-5 ideas)
Solo-buildable, ships in 4-8 weeks, niche pain point.

### Bucket B: Adjacent to existing portfolio (3-4 ideas)
Leverages tools/skills the user already has. Lower risk, faster validation.

### Bucket C: Wild card (2-3 ideas)
Bigger swings. Worth listing for awareness even if not pursuing now.

For each idea, write:

```markdown
### {short name}
**One-liner:** {what it does, who it's for}
**Why now:** {what changed in market or tech that makes this possible/needed}
**MVP shape:** {smallest thing that delivers value}
**Time to MVP (solo):** {weeks}
**Strongest signal from research:** {citation from web research, if any}
```

## Step 4 — Triage

Don't leave the user with 12 ideas. Triage them.

```markdown
## 🔥 Worth pursuing (top 2-3)

### 1. {idea}
**Strongest reason:** {one sentence}
**Strongest doubt:** {one sentence — be honest}
**Validation step (this week):** {concrete action with pass/fail bar}

### 2. {idea}
{same}

## 🤔 Worth a deeper look later

- {idea} — {one-line reason it's interesting but not now}

## 🗑️ Can be dropped

- {idea} — {one-line reason}
```

## Step 5 — Optional: dispatch analyze-idea

If the user picks one of the top 2-3 to go deeper, dispatch the `analyze-idea` skill on it directly. Don't make them re-type it.

## Step 6 — Log to journal

If a project journal exists for the cwd, append:

```bash
cat >> "$JOURNAL_DIR/journal.md" <<EOF

## $(date +%Y-%m-%d) — Brainstorm

**Topic:** {topic}
**Top ideas:** {names of top 2-3}
**Validation step taken:** {if any chosen}
EOF
```

## Anti-patterns

- ❌ Listing generic ideas without market signal ("AI for X" with no source). Always cite.
- ❌ Generating 30 ideas. The user can't act on 30. Triage to 2-3.
- ❌ Skipping the "strongest doubt" — every idea has one. Surface it.
- ❌ Defaulting to "build something with AI" without specifying the wedge.
