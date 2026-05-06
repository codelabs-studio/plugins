---
name: analyze-idea
description: Full business + technical + product analysis of a new idea. Use when user says "analyze this idea", "analiza esta idea", "/analyze-idea", "/analizar", "should I build X?", "is this a viable idea?", "evalúa este proyecto", "what do you think about building Y?", or wants a structured GO/NO-GO recommendation backed by market, technical, and product analysis. Dispatches CFO, CTO, and PM specialists in parallel and synthesizes their findings into one executive recommendation.
argument-hint: The idea to analyze (e.g., "platform for X using AI", "tool that helps Y do Z")
allowed-tools: Task, Read, Write, WebSearch, WebFetch, AskUserQuestion, Bash, Glob, Grep
---

# Analyze idea — full executive analysis

You are orchestrating a deep analysis of a new idea using three specialists in parallel: CFO (market + finance), CTO (tech + feasibility), PM (product + GTM).

The output is **one** executive recommendation. Not three reports stapled together.

## Step 1 — Make the idea concrete

If `$ARGUMENTS` is vague (less than 2 sentences, missing target user, missing problem), ask short clarifying questions before dispatching:

1. What problem does this solve, in one sentence?
2. Who is the user? (Be specific: "B2B sales reps at SaaS startups", not "businesses")
3. What's the proposed solution at a high level?
4. Why now? (Why not 5 years ago, why not 5 years from now?)

If the user already passed enough detail, skip questions. Don't ask just to ask.

## Step 2 — Read journal context (if available)

```bash
PROJECT_SLUG=$(basename "$PWD" | tr '[:upper:]' '[:lower:]' | tr ' _' '--' | sed 's/[^a-z0-9-]//g')
JOURNAL_DIR="$HOME/.config/codelabs/cofounder/$PROJECT_SLUG"
test -d "$JOURNAL_DIR" && cat "$JOURNAL_DIR/focus.md" "$JOURNAL_DIR/kpis.md" 2>/dev/null
```

If the user has active projects with stated focus, the analysis must consider opportunity cost: building this idea = not building/finishing those.

## Step 3 — Dispatch specialists in parallel

Send a single message with three `Task` tool calls (do not run sequentially — they're independent):

**1. CFO** — `subagent_type: "cfo"`
> Analyze market and financial viability of: {idea}.
> Required output: TAM/SAM/SOM with sources, top 3-5 direct competitors with pricing, recommended pricing strategy, unit economics estimate (CAC, LTV, LTV/CAC), and a verdict (VIABLE / MARGINAL / NOT VIABLE) with reasons.

**2. CTO** — `subagent_type: "cto"`
> Evaluate technical feasibility of: {idea}.
> Required output: recommended stack (with justification only if it deviates from a generic modern web stack), MVP architecture sketch, complexity rating (Low/Medium/High), realistic time estimate to MVP for a solo developer, key technical risks (Blocker / Mitigable / Monitor), and a verdict (FEASIBLE / COMPLEX / BLOCKER).

**3. PM** — `subagent_type: "pm"`
> Define product strategy for: {idea}.
> Required output: core value proposition (using the standard "For X, who Y, our product is Z, that A, unlike B, we C" template), aha moment, MVP MoSCoW (max 5 must-haves), primary user journey simplified, GTM plan with top 3 channels, north star metric, and a verdict (CLEAR PMF POTENTIAL / NEEDS VALIDATION / WEAK).

Pass the journal context (focus + KPIs from Step 2) inside each prompt so specialists understand the user's portfolio context.

## Step 4 — Synthesize

When all three return, produce ONE document. Do not paste their full responses — extract and merge.

```markdown
# Idea Analysis: {Name}

## 🎯 Verdict: 🟢 GO / 🟡 GO WITH ADJUSTMENTS / 🔴 NO GO

**TL;DR:** {2 sentences. Lead with the call. Then the strongest reason.}

---

## Market (CFO)
- **TAM/SAM/SOM:** {numbers + sources}
- **Top competitors:** {2-3 names with pricing}
- **Differentiation:** {1 sentence}
- **Pricing recommendation:** {tier and price}
- **Unit economics:** LTV/CAC ≈ {X}:1
- **Confidence:** {High / Medium / Low}

## Technical (CTO)
- **Stack:** {short list}
- **Complexity:** {Low / Medium / High}
- **Time to MVP:** {weeks for a solo dev}
- **Top technical risks:** {2-3 bullets}
- **Confidence:** {High / Medium / Low}

## Product (PM)
- **Value prop:** {one sentence}
- **Aha moment:** {when user says "wow"}
- **MVP must-haves:** {3-5 bullets}
- **GTM:** {primary channel}
- **North star:** {metric}
- **Confidence:** {High / Medium / Low}

---

## Trade-offs

**Strengths:**
- {strongest 2-3 reasons this could work}

**Weaknesses:**
- {strongest 2-3 reasons this might fail}

**Opportunity cost:**
{If the user has active projects with stated focus, what does building this displace?}

---

## Recommendation

{One paragraph. Brutally honest. If three confidences are split, pick the dominant signal. If two specialists say red and one says yellow, the verdict is red — synthesize, don't average.}

**Build this if:**
- {condition 1}
- {condition 2}

**Don't build this if:**
- {condition 1}
- {condition 2}

**Better alternative (if applicable):** {if there's a sharper version of the idea, propose it}

---

## Next concrete step

{One specific, accountable action — e.g., "Talk to 10 of your target users this week. Ask: 'How do you currently solve X?' If 7+ describe the same painful workaround, the problem is real. If not, the idea dies."}
```

## Step 5 — Log to journal

Append the verdict and one-line summary to the journal:

```bash
cat >> "$JOURNAL_DIR/journal.md" <<EOF

## $(date +%Y-%m-%d) — Idea analysis: {idea name}

**Verdict:** {GO / GO_WITH_ADJUSTMENTS / NO_GO}

**Summary:** {2 sentences from TL;DR}

**Next step:** {the concrete action from the recommendation}
EOF
```

If `JOURNAL_DIR` doesn't exist (no project context), skip the journal append silently.

## Anti-patterns

- ❌ Don't paste each specialist's full report. Synthesize.
- ❌ Don't soften the verdict to "it depends" if the data points clearly. Pick a side.
- ❌ Don't average confidence levels when specialists disagree. The lowest confidence wins.
- ❌ Don't recommend "do more research" as a next step. Recommend a SPECIFIC validation action with a clear pass/fail bar.
