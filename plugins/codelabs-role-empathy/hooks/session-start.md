---
name: role-empathy-session-start
description: Detects if the current project has a role empathy analysis and reminds the AI to consider roles when building features
event: SessionStart
---

Check if the file `docs/ROLE_EMPATHY_ANALYSIS.md` exists in the current project directory.

If it exists:
- Output: "Role empathy analysis found. Roles defined in this project will be considered when building features."

If it does NOT exist:
- Output: "No role empathy analysis found for this project. Use /role-empathy to create one if this project has multiple user roles."
