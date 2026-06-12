# Codelabs Advisors Plugin

> Expert advisors and technical audits for web projects

This plugin provides specialized skills for **technical audits** and **strategic consulting** as if you had expert team members available 24/7.

---

## 🚀 Quick Start

All skills are available in **every project automatically**. Just use the slash commands:

### Technical Audits (Pre-Production)

```bash
/pre-launch-audit    # Complete pre-production checklist
/seo-audit           # SEO optimization audit
/security-audit      # Security vulnerabilities (OWASP Top 10)
/performance-audit   # Performance & Core Web Vitals
/dns-email-setup     # DNS, SPF, DKIM, DMARC, email config
/db-config-check     # Database configuration & migrations
```

### Project Documentation

```bash
/readme              # Generate polished README.md with docs links and badges
/email-audit         # Email deliverability audit for Mailcow domains
```

### Strategic Consulting (Roles)

```bash
/cto-review          # Technical architecture review
/ceo-strategy        # Product & business strategy
/cfo-analysis        # Financial metrics & SaaS economics
/cofounder-session   # Brainstorming & decision making
```

---

## 📋 Technical Audits

### `/pre-launch-audit`
**Complete pre-production audit** covering:
- DNS & Email (SPF, DKIM, DMARC, MX records)
- Database (PostgreSQL, migrations, indexes)
- SEO (meta tags, Open Graph, structured data, sitemaps)
- Security (OWASP Top 10, HTTPS, headers, authentication)
- Performance (Core Web Vitals, bundle size, caching)
- Monitoring (error tracking, logging, uptime)

**When to use**: Before deploying to production, after major changes

**Example output**:
- Status report (Pass/Fail per section)
- Critical issues (must fix before launch)
- Warnings (should fix soon)
- Recommendations (nice-to-have)
- Action items with priorities (P0, P1, P2)

---

### `/seo-audit`
**Comprehensive SEO audit** covering:
- On-Page SEO (meta tags, headings, content structure)
- Open Graph & Social Media tags
- Structured Data (JSON-LD, schema.org)
- Technical SEO (robots.txt, sitemap, canonicals, page speed)
- Mobile optimization
- Core Web Vitals (LCP, FID, CLS)

**When to use**: Before launch, after content changes, periodic checks

**Target**: SEO Health Score 90+/100

---

### `/security-audit`
**Security vulnerability audit** covering:
- OWASP Top 10 (2021)
- SQL/NoSQL/Command Injection
- XSS (Cross-Site Scripting)
- CSRF (Cross-Site Request Forgery)
- Authentication & Authorization
- API security
- Environment variables & secrets management

**When to use**: Before launch, after adding authentication, periodic security reviews

**Output**: Severity ratings (Critical/High/Medium/Low) with specific fixes

---

### `/performance-audit`
**Performance optimization audit** covering:
- Core Web Vitals (LCP <2.5s, FID <100ms, CLS <0.1)
- Bundle optimization (code splitting, tree shaking)
- Image optimization (WebP, lazy loading, responsive)
- Network optimization (caching, CDN, HTTP/2)
- Database query optimization

**When to use**: Before launch, when experiencing slow performance, periodic checks

**Target**: Lighthouse score 90+ on all metrics

---

### `/dns-email-setup`
**DNS and email configuration audit** covering:
- DNS records (A, AAAA, CNAME, NS, MX)
- SPF (Sender Policy Framework)
- DKIM (DomainKeys Identified Mail)
- DMARC (Domain-based Message Authentication)
- PTR (Reverse DNS)
- Mailcow configuration (mail.codelabs.studio)
- Resend transactional email setup

**When to use**: Setting up new domain, email deliverability issues, before launch

**Target**: Mail-Tester score 10/10

---

### `/db-config-check`
**Database configuration audit** covering:
- Connection strings & SSL configuration
- Connection pooling (PgBouncer)
- Migrations status (Prisma or custom)
- Index analysis (missing, unused)
- Query performance (slow queries)
- Security (user permissions, SQL injection prevention)
- Backup strategy

**When to use**: Before launch, after schema changes, performance issues

**Target**: All migrations applied, proper indexes, <100ms query times

---

## 📄 Project Documentation

### `/readme`
**Generate a polished, attractive README.md** for any git repository.

**What it does**:
- Analyzes the project (package.json, tech stack, docs/, structure)
- Generates shields.io badges with accurate versions
- Creates a documentation index linking ALL .md files in docs/
- Includes Getting Started, Tech Stack table, Project Structure, and Scripts
- Detects `.claude/servers.json` for development setup section
- Verifies all documentation links point to existing files

**Styles available**:
- `full` (default): Comprehensive with all sections, badges, and structure diagram
- `minimal`: Clean and concise, just the essentials
- `landing`: Marketing-oriented with hero, value props, and screenshots

**Language support**: `en`, `es`, `bilingual`, or `auto` (detects from project)

**When to use**: New project setup, before open-sourcing, after major restructuring

**Example**:
```bash
/readme                    # Full README in auto-detected language
/readme --style minimal    # Concise version
/readme --lang es          # Spanish
/readme --style landing    # Marketing landing page
```

**Safety**:
- Never includes API keys or secrets (even as examples)
- Never fabricates features - only documents what exists
- Asks before overwriting an existing README
- Uses relative links for all documentation references

---

## 🎯 Strategic Consulting

### `/cto-review`
**Technical architecture consultation** as your CTO partner.

**Use for**:
- Architecture reviews (microservices, serverless, monolith)
- Technology stack selection
- Engineering team and hiring strategy
- Technical debt management
- Scalability planning
- DevOps and infrastructure decisions

**Mindset**: Direct, strategic, risk-aware, pragmatic

**Example**: "Should we refactor to microservices or stay monolithic?"

---

### `/ceo-strategy`
**Product and business strategy** as your CEO partner.

**Use for**:
- Product-market fit validation
- Feature prioritization
- Go-to-market strategy
- User acquisition and retention
- Competitive positioning
- Team building and hiring

**Mindset**: Vision-focused, user-centric, data-driven, strategic

**Example**: "Should we focus on feature X or growth?"

---

### `/cfo-analysis`
**Financial analysis and SaaS metrics** as your CFO partner.

**Use for**:
- SaaS metrics (MRR, ARR, CAC, LTV, churn)
- Unit economics optimization
- Pricing strategy
- Financial modeling
- Fundraising preparation
- Budget allocation

**Mindset**: Numbers-focused, risk-aware, long-term thinking

**Example**: "How should we price our product?"

---

### `/cofounder-session`
**Brainstorming and strategic decisions** as your co-founder.

**Use for**:
- Strategic brainstorming
- Problem-solving (product, tech, business)
- Decision-making (with frameworks like ICE/RICE)
- Launch planning
- General discussion and support

**Mindset**: Collaborative, honest, action-oriented, supportive

**Example**: "Let's brainstorm growth tactics for next month"

---

## 💡 Usage Tips

### Combining Audits
Run multiple audits together:
```bash
/pre-launch-audit
```
This already includes SEO, security, performance, DNS, and database checks.

Or run specific audits:
```bash
/seo-audit
/security-audit
```

### Before Every Launch
Standard checklist:
1. `/pre-launch-audit` - comprehensive check
2. Fix all P0 (critical) issues
3. Fix P1 (high priority) issues
4. Document P2 (nice-to-have) for later

### Consulting Sessions
Start with the right role:
- **Technical question** → `/cto-review`
- **Product/business question** → `/ceo-strategy`
- **Financial/metrics question** → `/cfo-analysis`
- **Open discussion** → `/cofounder-session`

### Model Usage
All skills use **Opus model** for maximum quality analysis.

---

## 🔧 Customization

Want to customize the skills? See [CUSTOMIZATION.md](./CUSTOMIZATION.md) for details on:
- Modifying existing skills
- Adding new skills
- Changing model preferences
- Customizing output formats

---

## 📦 Plugin Structure

```
~/.claude/plugins/codelabs-advisors/
├── plugin.json                     # Plugin configuration
├── README.md                       # This file
├── CUSTOMIZATION.md                # How to customize
├── commands/
│   ├── email-audit.md              # /email-audit command
│   └── readme.md                   # /readme command
└── skills/
    ├── pre-launch-audit.md         # Complete pre-production audit
    ├── seo-audit.md                # SEO optimization
    ├── security-audit.md           # Security vulnerabilities
    ├── performance-audit.md        # Performance optimization
    ├── dns-email-setup.md          # DNS & email configuration
    ├── db-config-check.md          # Database configuration
    ├── cto-review.md               # CTO consultation
    ├── ceo-strategy.md             # CEO consultation
    ├── cfo-analysis.md             # CFO consultation
    └── cofounder-session.md        # Co-founder brainstorming
```

---

## 🎓 Best Practices

### For Technical Audits
1. **Run before launch**: Catch issues early
2. **Fix by priority**: P0 → P1 → P2
3. **Re-run after fixes**: Validate improvements
4. **Automate**: Add to CI/CD pipeline (Lighthouse, security scans)

### For Consulting Sessions
1. **Be specific**: Better results with specific questions
2. **Provide context**: Share relevant background
3. **Challenge ideas**: Use advisors to stress-test decisions
4. **Take notes**: Document insights and action items

---

## 🆘 Support

- **Plugin issues**: Check [CUSTOMIZATION.md](./CUSTOMIZATION.md)
- **Skill not working**: Ensure plugin is in `~/.claude/plugins/`
- **Command not found**: Plugin should auto-load, try restarting Claude Code

---

**Version**: 1.0.0
**Author**: José Díaz
**Last Updated**: 2026-02-02
