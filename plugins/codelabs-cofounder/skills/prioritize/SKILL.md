---
name: prioritize
description: Cross-portfolio prioritization. Use when user says "prioritize my projects", "prioritize", "/priorizar", "/prioritize", "what should I focus on", "qué proyecto priorizo", "which project deserves my time", "help me decide where to focus", or wants to decide what to keep, pause, or kill across multiple projects. Reads journals across all projects and applies a brutally honest portfolio framework.
argument-hint: Optional — specific concern (e.g., "I have 5 projects and burning out", "should I kill X?")
allowed-tools: Read, Write, Bash, Glob, Grep, Task, AskUserQuestion, WebSearch
---

# Prioritize — portfolio decisions

Help the user decide where to spend time across their projects. The output is a ranked recommendation: focus, pause, kill.

## Step 1 — Discover the portfolio

Look for project journals across the cofounder config:

```bash
JOURNAL_ROOT="$HOME/.config/codelabs/cofounder"
ls -1 "$JOURNAL_ROOT" 2>/dev/null | grep -v templates
```

Also check if the user has a portfolio file at `~/.config/codelabs/projects.json` and read it if present. Otherwise, ask the user to list their active projects (one line each, with stage).

For each project found, read:
- `focus.md` (current focus)
- last 5 entries from `journal.md`
- `kpis.md` (north star + current numbers)

If a project is in the portfolio file but has no journal, it's a flag: **stale or unstarted**. Note it.

## Step 2 — Score each project

For each project, score on five dimensions (1-5):

| Dimension | What it measures |
|-----------|------------------|
| **Revenue potential** | Realistic revenue in 12 months at MVP |
| **Time to revenue** | Weeks until paying users (lower = higher score) |
| **Momentum** | Recent journal activity, ships, learnings |
| **Stack fit** | How well it leverages existing infra/code |
| **Founder energy** | Subjective — does the user actually want to work on this? |

Ask the user for the **founder energy** scores (it's the only one you can't infer). For the other four, infer from journal + KPIs and explain your reasoning.

## Step 3 — Apply the portfolio framework

Three buckets, never more than 2 in the top bucket:

### 🟢 Focus (max 2 projects)

Highest combined score. These get 80% of the user's time.

### 🟡 Maintain (1-2 projects)

Generating value (revenue / users / learnings) but not the highest priority. Keep them running with minimal investment. Define explicitly: "minimum viable maintenance" — what's the smallest thing to keep them alive?

### 🔴 Pause or kill

Everything else. Be decisive:
- **Pause** if there's a credible scenario in <90 days that flips the priority
- **Kill** if there isn't. Don't keep zombies — they steal mental bandwidth even when you're not working on them.

## Step 4 — Watch for traps

Apply these checks honestly. Surface any that fire:

- **Sunk cost** — "I've invested 6 months" is NOT a reason to continue. Look forward, not back.
- **Vanity activity** — projects with lots of journal entries but no shipping or revenue signals.
- **Identity attachment** — "this is the project I tell people about" is a personal-brand reason, not a business reason. Call it out.
- **Drift** — if the user's stated focus contradicts their actual time allocation (visible from cwd switching frequency or commit recency), name it.
- **One-more-feature trap** — projects stuck in "almost ready to launch" for >30 days. These need a launch deadline or a kill date.

## Step 5 — Output

```markdown
# Portfolio Decision

## 🟢 Focus (next 4 weeks)

### 1. {Project name}
**Why:** {one sentence}
**Next milestone:** {concrete deliverable + date}
**KPI to watch:** {one metric + target}

### 2. {Project name}
{same structure}

## 🟡 Maintain

### {Project name}
**Minimum viable maintenance:** {smallest thing to keep alive — e.g., "respond to support emails, deploy security patches"}
**Revisit on:** {date or signal — e.g., "if MRR > €X" or "in 90 days"}

## 🔴 Pause / Kill

### {Project name} — KILL
**Why:** {brutal reason}
**What to preserve:** {tag final commit / archive landing page / etc.}

### {Project name} — PAUSE until {date / condition}
**Why:** {reason}
**Trigger to revive:** {specific signal that would un-pause}

---

## Traps fired

{list any of: sunk cost / vanity / identity / drift / one-more-feature}

If none fired: "No portfolio traps detected this round."

## Recommendation

{One paragraph. Honest. The user's projects are not your projects, but you're paid to tell the truth — even when uncomfortable.}

## Next concrete step

{What to do today, not in a week.}
```

## Step 6 — Log decisions

For each project where the bucket changed (e.g., a project moved from focus to pause), append to that project's journal:

```bash
cat >> "$JOURNAL_DIR/journal.md" <<EOF

## $(date +%Y-%m-%d) — Portfolio decision

**Bucket:** {focus | maintain | pause | kill}
**Rationale:** {one sentence}
EOF
```

## Anti-patterns

- ❌ Don't recommend "focus on all of them, just better." That's not prioritization.
- ❌ Don't kill the user's pet project without naming the identity-attachment trap explicitly.
- ❌ Don't propose 5+ focus projects. The point is to cut.
