---
name: feature-compare
description: Compares how the same feature (or similar features) is implemented in two different projects. Shows a side-by-side analysis of architecture, data model, UI patterns, business logic, and conventions. Useful after porting a feature or to understand implementation differences.
argument-hint: "[feature] in [project-a] vs [project-b]"
model: sonnet
---

# Feature Compare - Cross-Project Feature Comparison

## When to Use

- After `/feature-port` to verify the adaptation was done correctly
- To understand how two projects solve the same problem differently
- To decide WHICH project's implementation is better before porting
- To learn from different approaches to the same feature
- To find gaps or improvements in one implementation vs another

## Input

The user will provide:
1. **Feature name/description** - what to compare
2. **Two projects** - which projects to compare

All projects are located under `/Users/josediaz/Dev/code/`.

Example invocations:
- `/feature-compare chatbot in almasuite.coach vs fittrack-pro`
- `/feature-compare auth in project-a vs project-b`
- "Compare how notifications work in X vs Y"
- "Compare the audit system between project-a and project-b"

If any information is missing, ask the user.

## Process

### Step 1: Validate Both Projects Exist

Check that both `/Users/josediaz/Dev/code/[project-a]` and `/Users/josediaz/Dev/code/[project-b]` exist.

### Step 2: Analyze Feature in Both Projects (Parallel)

For EACH project, analyze the feature by scanning:

1. **Entry points**: Routes, pages, API endpoints related to the feature
2. **Data model**: Tables, schemas, types, validation related to the feature
3. **Business logic**: Services, utilities, helpers implementing the feature
4. **UI components**: Feature-specific components, layouts, patterns
5. **Integrations**: External services, libraries used by the feature
6. **Configuration**: Env vars, feature flags, settings
7. **Tests**: Test coverage for this feature

**Run both analyses in parallel** using the `feature-scanner` agent or direct scanning, targeting only the specific feature (not the whole project).

### Step 3: Build Comparison Matrix

Organize findings into a structured comparison across these dimensions:

#### A. Architecture Comparison
- File structure and organization
- Separation of concerns
- Design patterns used
- Code modularity

#### B. Data Model Comparison
- Tables/entities and their fields
- Relationships and constraints
- Naming conventions
- Migrations approach

#### C. Business Logic Comparison
- Operations/flows implemented
- Validation rules
- Error handling
- Permission model

#### D. UI/UX Comparison
- Pages and routes
- Component structure
- States (empty, loading, error, success)
- Responsive behavior
- Role-based UI differences

#### E. Integration Comparison
- External services used
- Internal dependencies
- Configuration requirements

#### F. Quality Comparison
- Test coverage
- Type safety
- Error handling depth
- Documentation

### Step 4: Present Comparison

Use this format:

```
FEATURE COMPARISON
═══════════════════════════════════════════════════════════════

Feature: [name]
Project A: [name] ([tech stack summary])
Project B: [name] ([tech stack summary])

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Overview

┌─────────────────┬──────────────────────┬──────────────────────┐
│ Aspect          │ Project A            │ Project B            │
├─────────────────┼──────────────────────┼──────────────────────┤
│ Tech Stack      │ [framework, db, etc] │ [framework, db, etc] │
│ Feature Maturity│ [Basic/Mature/Advanced] │ [Basic/Mature/Advanced] │
│ Files Count     │ [N files]            │ [N files]            │
│ Tables/Entities │ [N]                  │ [N]                  │
│ API Endpoints   │ [N]                  │ [N]                  │
│ UI Pages        │ [N]                  │ [N]                  │
│ Test Coverage   │ [None/Partial/Full]  │ [None/Partial/Full]  │
└─────────────────┴──────────────────────┴──────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Architecture

### Project A
- Pattern: [e.g., "tRPC router + React components + Drizzle schema"]
- File structure:
  [tree of relevant files]

### Project B
- Pattern: [e.g., "REST controllers + Vue pages + Prisma models"]
- File structure:
  [tree of relevant files]

### Verdict
[Which approach is cleaner/better and why, or if both are valid]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Data Model

### Project A
[Table/entity definitions with fields]

### Project B
[Table/entity definitions with fields]

### Differences
- [Field X exists in A but not B - purpose: ...]
- [B has [extra table] that A doesn't - purpose: ...]
- [Naming: A uses camelCase, B uses snake_case]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Business Logic

### Operations Comparison
┌─────────────────────┬─────────┬─────────┬──────────────────┐
│ Operation           │ A       │ B       │ Difference       │
├─────────────────────┼─────────┼─────────┼──────────────────┤
│ [e.g., Create]      │ ✅      │ ✅      │ [or "A has X"]   │
│ [e.g., Bulk delete]  │ ✅      │ ❌      │ Missing in B     │
│ [e.g., Export]       │ ❌      │ ✅      │ Missing in A     │
└─────────────────────┴─────────┴─────────┴──────────────────┘

### Logic Differences
- [Specific difference in validation, flow, behavior]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## UI/UX

### Project A
- Pages: [list]
- Key patterns: [cards, tables, modals, etc.]
- Role adaptations: [role-specific views]

### Project B
- Pages: [list]
- Key patterns: [cards, tables, modals, etc.]
- Role adaptations: [role-specific views]

### UX Differences
- [Specific difference: A uses modals, B uses full pages]
- [Specific difference: A has empty states, B doesn't]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## External Dependencies

┌──────────────────┬──────────────────┬──────────────────┐
│ Purpose          │ Project A        │ Project B        │
├──────────────────┼──────────────────┼──────────────────┤
│ [e.g., AI]       │ [OpenAI]         │ [Claude]         │
│ [e.g., Email]    │ [Resend]         │ [SendGrid]       │
│ [e.g., Storage]  │ [S3]             │ [Cloudflare R2]  │
└──────────────────┴──────────────────┴──────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Scorecard

┌─────────────────────┬──────┬──────┐
│ Dimension           │ A    │ B    │
├─────────────────────┼──────┼──────┤
│ Feature Completeness│ X/10 │ X/10 │
│ Code Quality        │ X/10 │ X/10 │
│ UX Polish           │ X/10 │ X/10 │
│ Test Coverage       │ X/10 │ X/10 │
│ Error Handling      │ X/10 │ X/10 │
│ Role Adaptation     │ X/10 │ X/10 │
│ Portability         │ X/10 │ X/10 │
├─────────────────────┼──────┼──────┤
│ OVERALL             │ X/10 │ X/10 │
└─────────────────────┴──────┴──────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Recommendations

### What A Does Better
1. [Specific thing with explanation]
2. [Specific thing with explanation]

### What B Does Better
1. [Specific thing with explanation]
2. [Specific thing with explanation]

### Best of Both Worlds
[If you could combine the best of both implementations, what would the ideal version look like?]

### Migration Opportunities
- [Suggestion: "Port X from A to B because..."]
- [Suggestion: "Port Y from B to A because..."]
```

### Step 5: Offer Next Steps

After presenting the comparison:
1. "Want to port any specific aspect from one to the other? Use `/feature-port`"
2. "Want to save this comparison? I'll create `docs/FEATURE_COMPARISON_[feature]_[date].md`"
3. "Want a deeper dive into any specific dimension?"

## Important Rules

- **READ-ONLY** - Never modify either project
- **Fair comparison** - Don't bias toward either project. Be honest about strengths and weaknesses of both
- **Context matters** - A simpler implementation isn't always worse; it might be appropriate for that project's needs
- **Role-aware** - If projects have different role systems, note how the feature adapts to each
- **Tech-aware** - Don't penalize for tech stack differences; compare the APPROACH, not the syntax
- **Actionable** - Every finding should be useful for decision-making, not just trivia
