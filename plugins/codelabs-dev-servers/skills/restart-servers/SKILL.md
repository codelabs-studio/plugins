---
name: restart-servers
description: Restart all dev servers for the current project. Equivalent to running stop then start. Use when user says "restart servers", "reinicia servidores", "restart dev", "reinicia el dev", "restart the project".
argument-hint: Optional service name (e.g., "web") to restart only that service.
allowed-tools: Bash, Read, Write, Edit
---

# Restart servers

## Step 1 — Run the stop skill logic

Execute the `stop-servers` skill behavior with the same `$ARGUMENTS`. Make sure all targeted ports are free before continuing.

## Step 2 — Wait briefly

```bash
sleep 1
```

This avoids race conditions with TCP `TIME_WAIT` state on the ports just freed.

## Step 3 — Run the start skill logic

Execute the `start-servers` skill behavior with the same `$ARGUMENTS`. The mode (ports/domains) comes from `.claude/servers.json` if present, otherwise ask.

## Notes

- This is essentially a convenience skill — internally it's stop + start.
- If you only want to restart ONE service, pass its name: `/restart-servers web`.
- The Caddy routes are NOT touched (they remain registered between stop and start).
