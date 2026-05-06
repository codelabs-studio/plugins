# Codelabs Advisors - Quick Reference

> Ultra-simple cheat sheet for all available skills

---

## 🔍 Technical Audits

| Command | Purpose | When to Use |
|---------|---------|-------------|
| `/pre-launch-audit` | Complete pre-production check | Before deploying to production |
| `/seo-audit` | SEO optimization | Before launch, after content changes |
| `/security-audit` | Security vulnerabilities | Before launch, after auth changes |
| `/performance-audit` | Speed & Core Web Vitals | Before launch, when site is slow |
| `/dns-email-setup` | Email deliverability | Setting up domain/email |
| `/db-config-check` | Database & migrations | Before launch, after schema changes |

---

## 💼 Strategic Consulting

| Command | Role | Use For |
|---------|------|---------|
| `/cto-review` | CTO | Tech architecture, infrastructure, hiring |
| `/ceo-strategy` | CEO | Product strategy, go-to-market, growth |
| `/cfo-analysis` | CFO | Pricing, metrics (MRR, CAC, LTV), fundraising |
| `/cofounder-session` | Co-Founder | Brainstorming, decisions, general discussion |

---

## 🚀 Before Every Launch

Standard checklist:
```bash
1. /pre-launch-audit       # Comprehensive check
2. Fix all P0 issues       # Critical problems
3. Fix P1 issues           # High priority
4. Document P2 for later   # Nice-to-have
```

---

## 💡 Quick Tips

- **All skills use Opus** for maximum quality
- **No installation needed** - available in every project
- **Changes are immediate** - edit skill files anytime
- **Combine audits** - `/pre-launch-audit` includes most checks

---

## 📝 Examples

**Before launch**:
```bash
/pre-launch-audit
```

**Email not working**:
```bash
/dns-email-setup
```

**Should we add feature X?**:
```bash
/ceo-strategy
```

**Is our architecture good?**:
```bash
/cto-review
```

**How should we price?**:
```bash
/cfo-analysis
```

**Let's brainstorm**:
```bash
/cofounder-session
```

---

## 📍 File Locations

- **Plugin**: `~/.claude/plugins/codelabs-advisors/`
- **Skills**: `~/.claude/plugins/codelabs-advisors/skills/*.md`
- **Docs**: `~/.claude/plugins/codelabs-advisors/README.md`

---

## 🔧 Quick Edit

To customize any skill:
```bash
code ~/.claude/plugins/codelabs-advisors/skills/[skill-name].md
```

No restart needed - save and use immediately.

---

**Full docs**: See [README.md](./README.md)
**Customization**: See [CUSTOMIZATION.md](./CUSTOMIZATION.md)
