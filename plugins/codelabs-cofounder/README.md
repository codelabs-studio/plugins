# codelabs-cofounder

Your virtual co-founder with **skin in the game**. Not a council of experts you summon — a persistent partner that remembers your project journey, challenges your thinking, and earns agreement through scrutiny.

> Default Claude is sycophantic by design (agrees ~60% of the time, softens correct positions when pushed). That's actively harmful for founder decisions. This plugin replaces that behavior inside its skills with a co-founder posture: brutally honest, evidence-based, with memory of what you've shipped and what you've avoided.

## What it does

- **`/cofounder`** (alias `/socio`) — Talk to your virtual co-founder. Reads your project journal, asks the right questions, and decides which specialist to dispatch (if any). You don't have to remember agent names.
- **`/analyze-idea`** — Full business + technical + product analysis of a new idea using CFO, CTO, and PM in parallel.
- **`/prioritize`** — Cross-portfolio prioritization: what to focus on, what to pause, what to kill.
- **`/brainstorm`** — Generative session with market research, trends, and idea generation.
- **`/retrospective`** — Honest weekly/monthly retrospective. Reads journal + git log + KPIs.

## Journal layer (project memory)

The plugin keeps a journal per project at:

```
~/.config/codelabs/cofounder/{project-slug}/
├── journal.md      ← append-only timeline of decisions
├── focus.md        ← the ONE thing you're working on now
├── hypothesis.md   ← what you're currently validating
├── kpis.md         ← metrics that actually matter for this project
└── retros/         ← weekly/monthly retrospectives
```

The session-start hook reads the journal when you open a project directory and surfaces what was happening last time. No more "where was I?" amnesia.

## Specialists (when needed)

Six focused advisors, dispatched automatically by the cofounder skill — not summoned by name:

- **CTO** — stack, architecture, performance, technical feasibility
- **CFO** — market, competition, pricing, unit economics
- **PM** — MVP scope, user journey, GTM, SEO, growth
- **QA** — testing strategy, quality gates, regression coverage
- **UX** — user flows, accessibility, design system
- **Security** — OWASP audits, threat modeling, secrets hygiene

You don't pick which one. The cofounder skill reads your question, your journal, and dispatches whichever specialists actually help. If it's a quick decision, it answers directly without dispatching anyone.

## Philosophy

1. **Singular, not plural** — One co-founder, six advisors. Not ten characters to remember.
2. **Memory over expertise** — A specialist who forgets your project every session isn't a co-founder. The journal is the differentiator.
3. **Skin in the game** — At session start: "What did you ship since last time? Did the X experiment work?" The cofounder tracks momentum and calls out drift.
4. **Brutal honesty over validation** — If your idea is bad, you'll hear it. With reasons.
5. **Auto-routing** — You speak naturally. The cofounder figures out who needs to weigh in.

## Install

This plugin is part of the codelabs marketplace.

```
/plugin marketplace add codelabs https://codelabs.studio/plugins/marketplace.json
/plugin install codelabs-cofounder@codelabs
```

## License

MIT
