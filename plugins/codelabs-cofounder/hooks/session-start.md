---
event: SessionStart
description: On session start, if the cwd matches a project with an existing journal, surface the current focus and last journal entry. Otherwise stay silent.
---

# Cofounder — session start

Lightweight context loader. Avoid token-heavy automatic loads; only surface info when there's a journal for this project.

## Logic

```bash
# Resolve project slug from cwd
PROJECT_SLUG=$(basename "$PWD" | tr '[:upper:]' '[:lower:]' | tr ' _' '--' | sed 's/[^a-z0-9-]//g')
JOURNAL_DIR="$HOME/.config/codelabs/cofounder/$PROJECT_SLUG"

# If there's no journal, exit silently
test -d "$JOURNAL_DIR" || exit 0
```

## What to surface (when journal exists)

Read these files and produce a compact context line:

1. `focus.md` → first non-blank, non-heading line.
2. `journal.md` → last entry (find by `^## YYYY-` heading and tail).
3. `hypothesis.md` → count of `## H` sections that don't have `Status: Closed` or `Status: Validated`.

Output something like this at the start of the session (not as Claude's response — as ambient context):

```
📓 Cofounder context — {project_slug}
🎯 Focus: {focus first line}
🕓 Last journal entry: {date} — {entry type and one-line summary}
🧪 Open hypotheses: {count}
```

If `focus.md` is older than 14 days (mtime), add a soft warning:
```
⚠️  Focus statement is {N} days old. Consider running /retrospective.
```

If `kpis.md` is older than 14 days, similar warning:
```
⚠️  KPIs last updated {N} days ago.
```

## What NOT to do

- Don't dump the full journal into context.
- Don't re-list every hypothesis or KPI.
- Don't load anything if there's no journal.
- Don't interrupt the user's actual question. The banner is informational, not blocking.

## When the user explicitly invokes a cofounder skill

The skill itself will do its own deeper read of the journal. The hook just provides ambient awareness so the user doesn't have to ask "where was I?" before getting started.

## Privacy

The journal is local. Don't echo its contents to anything outside the user's terminal/Claude Code session.
