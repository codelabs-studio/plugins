---
name: tmux-projects
description: List active tmux sessions tied to development projects. Use when user says "tmux projects", "tmux dev", "qué sesiones tmux tengo", "list dev sessions", "what tmux sessions are active for development".
allowed-tools: Bash
---

# Tmux dev sessions

Quick view of active tmux sessions and which project each one corresponds to.

## Step 1 — List sessions

```bash
tmux list-sessions 2>/dev/null
```

If tmux isn't installed or no sessions exist, say so directly.

## Step 2 — Inspect each session

For each session, show its panes' working directories:

```bash
tmux list-sessions -F '#{session_name}' 2>/dev/null | while read sess; do
    echo "## Session: $sess"
    tmux list-panes -t "$sess" -F '#{pane_id} #{pane_current_path} #{pane_current_command}' 2>/dev/null | while read line; do
        echo "  $line"
    done
done
```

## Step 3 — Cross-reference with .claude/servers.json

For each session's working directory, check if there's a `.claude/servers.json`:

```bash
test -f "$path/.claude/servers.json" && jq -r '.project' "$path/.claude/servers.json"
```

If yes, surface the project name next to the session.

## Step 4 — Output

```markdown
# Tmux dev sessions

## {session_name} → {project_name}
- Pane 1: {cwd} ({running command})
- Pane 2: {cwd} ({running command})

## {session_name} (no project detected)
- Pane 1: {cwd}
```

If a session has no `.claude/servers.json` in any of its panes' cwd, it's likely a non-project session (research, system admin, etc.).

## Anti-patterns

- ❌ Killing sessions. This skill only lists.
- ❌ Showing every tmux env var. Focus on what's useful for project identification.
