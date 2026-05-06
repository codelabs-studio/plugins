---
name: feature-analyze
description: Scans a project and identifies all its features, categorizing them as killer features, core features, enhancements, utilities, or infrastructure. Shows portability ratings and recommends best candidates for porting to other projects.
argument-hint: "[project-name]"
model: sonnet
---

# Feature Analyze - Cross-Project Feature Discovery

## When to Use

- When you want to know what features a project has
- Before deciding which feature to port to another project
- When evaluating a project's feature landscape
- When you need a quick inventory of what's been built

## Input

The user will provide a project name. All projects are located under `/Users/josediaz/Dev/code/`.

Example invocations:
- `/feature-analyze almasuite.coach`
- `/feature-analyze fittrack-pro`
- "Analyze the features of project-x"

If no project name is provided, ask the user which project to analyze.

## Process

### Step 1: Validate Project Exists

Check that `/Users/josediaz/Dev/code/[project-name]` exists and is a valid project (has package.json, pyproject.toml, Cargo.toml, go.mod, or similar).

### Step 2: Quick Context Gathering

Read these files (if they exist) to understand the project BEFORE deep scanning:
1. `README.md` - what the project is about
2. `package.json` or equivalent - tech stack
3. `docs/FEATURE_TRACKING.md` - existing feature documentation
4. `docs/ROLE_EMPATHY_ANALYSIS.md` - role system
5. `.claude/CLAUDE.md` or `CLAUDE.md` - project instructions

### Step 3: Launch Feature Scanner Agent

Use the `feature-scanner` agent to perform a comprehensive scan of the project.

Provide the agent with:
- Project name and path
- Tech stack info gathered in Step 2
- Any existing feature docs found
- Role information if available

### Step 4: Present Results

Present the scanner's findings in a clean, actionable format.

**If `docs/FEATURE_TRACKING.md` exists**, cross-reference the scanner's findings with the documented features. Note any discrepancies (features in code but not documented, or documented but not implemented).

### Step 5: Offer Next Steps

After presenting the analysis, offer:
1. "Want me to deep-dive into any specific feature?"
2. "Want to port any of these features to another project? Use `/feature-port`"
3. "Want me to save this analysis to the project's docs?"

## Output Options

### Console Output (default)
Display the full analysis in the terminal with clear formatting.

### Save to File (if user requests)
Save to `docs/FEATURE_ANALYSIS_[DATE].md` in the analyzed project's directory.

## Important Notes

- This is a READ-ONLY operation - it never modifies the source project
- For large projects, focus on USER-FACING features, not every utility function
- Group related functionality into features (don't list every CRUD endpoint separately)
- Be honest about portability - some features are deeply coupled and that's okay
- If the project uses a framework you don't recognize, note that in the output
