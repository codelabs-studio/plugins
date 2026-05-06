---
name: retrospective
description: Honest weekly or monthly retrospective for the current project. Use when user says "retrospective", "/retrospective", "/retro", "weekly retro", "monthly retro", "how did this week go", "balance de la semana", "qué hice esta semana", "review last sprint", "what shipped", or wants an honest assessment of progress. Reads project journal, git log, and KPI deltas to produce a brutally honest retro.
argument-hint: Optional period — "week", "month", "since last retro" (default: week)
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, Task
---

# Retrospective — what actually happened

A retro is not a vibe check. It's an evidence-based assessment of the gap between what you said you'd do and what actually happened.

## Step 1 — Resolve scope

```bash
PROJECT_SLUG=$(basename "$PWD" | tr '[:upper:]' '[:lower:]' | tr ' _' '--' | sed 's/[^a-z0-9-]//g')
JOURNAL_DIR="$HOME/.config/codelabs/cofounder/$PROJECT_SLUG"
```

Determine the period from `$ARGUMENTS`:
- `week` (default) — last 7 days
- `month` — last 30 days
- `since last retro` — find the most recent file in `$JOURNAL_DIR/retros/` and use that date

If `JOURNAL_DIR` doesn't exist, surface that this is the first retro and proceed with git data only.

## Step 2 — Gather evidence (in parallel where possible)

### A. Journal entries in period
```bash
# Read last entries from journal.md, filter by date
test -f "$JOURNAL_DIR/journal.md" && cat "$JOURNAL_DIR/journal.md"
```

Extract decisions, hypotheses, ships, learnings, blocks from the period.

### B. Git activity in period
```bash
SINCE_DATE="{period start}"
git log --since="$SINCE_DATE" --oneline 2>/dev/null
git log --since="$SINCE_DATE" --shortstat --no-merges 2>/dev/null
git log --since="$SINCE_DATE" --pretty=format:"%h %s" --name-only 2>/dev/null | head -100
```

Identify:
- **Ships** — commits that look like releases/features (deploy, release, feat)
- **Fixes vs features ratio** — too many fixes = stuck firefighting
- **Files touched most** — where the work actually went
- **Quiet days** — gaps suggest distraction or block

### C. Stated focus vs. actual work
```bash
test -f "$JOURNAL_DIR/focus.md" && cat "$JOURNAL_DIR/focus.md"
```

Compare focus.md content against the actual git log. Major gap = drift.

### D. KPI deltas (if KPIs are kept up to date)
```bash
test -f "$JOURNAL_DIR/kpis.md" && cat "$JOURNAL_DIR/kpis.md"
```

If KPIs are >7 days stale, that's itself a finding (KPI rot).

### E. Hypothesis status
```bash
test -f "$JOURNAL_DIR/hypothesis.md" && cat "$JOURNAL_DIR/hypothesis.md"
```

Are open hypotheses closer to validated or invalidated? Are there hypotheses that have been "active" for >14 days with no signal updates?

## Step 3 — Produce the retro

The format below is mandatory — these sections force honesty:

```markdown
# Retro — {project} — {period_label}
*{date_range}*

## 📦 What shipped

- {concrete deliverables that reached users / production / external visibility}

If nothing reached users: **say so.** Don't list "started X" or "drafted Y" — that's not shipping.

## 🎯 Stated focus this period

> {focus.md content}

## 🚧 What actually happened

{paragraph comparing the stated focus against the work — where time actually went}

## ✅ Wins

- {real wins backed by evidence — not vanity}

## 😬 Gaps & drift

- {honest list of things that didn't go as planned}
- {drift between focus and actual work, if any}
- {hypotheses that aged out without signal}
- {KPI rot if KPIs went stale}

## 📊 Numbers

- **Ships:** {count}
- **Fixes vs features:** {ratio} → {what this signals}
- **Quiet days:** {count of days with zero commits}
- **KPI delta — {north star metric}:** {previous} → {current} ({direction + magnitude})
- {other relevant metric deltas}

## 🧠 Learnings

The 1-3 most important things you now know that you didn't a week/month ago. **Add these to the journal as `Learning` entries.**

## 🪞 Honest assessment

{One paragraph. What's the trajectory? Is the user actually closer to the goal stated in focus.md, or further from it? Be specific — "you spent the week on X, which is not what focus.md says, because Y."}

## 🎯 Reset for next period

- **New focus:** {what should focus.md say going into next period?}
- **One thing to stop:** {something to deliberately drop}
- **One thing to start:** {something concrete to add}
- **Validation deadline:** {if there's an active hypothesis, when's the call to validate or kill it?}
```

## Step 4 — Write the retro to disk

```bash
RETRO_FILE="$JOURNAL_DIR/retros/$(date +%Y-W%V).md"
mkdir -p "$JOURNAL_DIR/retros"
# Write the retro content to RETRO_FILE
```

For monthly retros, use `$(date +%Y-%m).md` instead.

## Step 5 — Update focus.md if needed

If the retro produced a new focus, overwrite `focus.md` with the new one-liner. The cofounder skill will pick it up next session.

## Step 6 — Update hypothesis.md and KPIs if needed

- Move stale hypotheses (older than 14 days with no movement) to a "Closed" section in `hypothesis.md` with a verdict (validated / invalidated / abandoned).
- If the user gave updated KPI numbers during the retro, update `kpis.md`.

## Step 7 — Append a `Learning` entry to journal.md

```bash
cat >> "$JOURNAL_DIR/journal.md" <<EOF

## $(date +%Y-%m-%d) — Retrospective ({period})

**Top learning:** {the single most important thing learned}
**Reset focus:** {new focus.md content}
**Stop:** {what to drop}
**Start:** {what to add}
EOF
```

## Anti-patterns

- ❌ Don't soften the retro to make the user feel good. The whole point is the gap analysis.
- ❌ Don't accept "I was busy" as a reason. Show the data: where did the time go?
- ❌ Don't skip the "honest assessment" paragraph — that's where the real value is.
- ❌ Don't recommend "do better next week" — recommend a specific stop/start with a deadline.
