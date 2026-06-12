# Customization Guide

This guide explains how to customize the Codelabs Advisors plugin skills to fit your specific needs.

---

## 📁 File Structure

Each skill is a Markdown file with YAML frontmatter:

```markdown
---
name: skill-name
description: Brief description for the skill picker
tags: [tag1, tag2, tag3]
model: opus  # or sonnet, haiku
---

# Skill Content

Your prompt instructions here...
```

---

## 🛠️ Editing Existing Skills

### Location
All skills are in: `~/.claude/plugins/codelabs-advisors/skills/`

### How to Edit

1. **Open the skill file** you want to modify:
   ```bash
   code ~/.claude/plugins/codelabs-advisors/skills/seo-audit.md
   ```

2. **Edit the content** (below the `---` frontmatter)

3. **Save the file**

4. **No restart needed** - changes take effect immediately

### What You Can Change

#### Frontmatter
```yaml
---
name: seo-audit                    # Command name (/seo-audit)
description: Comprehensive SEO...  # Description shown in picker
tags: [seo, audit, optimization]   # For organization/search
model: opus                        # opus (best), sonnet (balanced), haiku (fast)
---
```

#### Prompt Content
- Add/remove checklist items
- Change output format
- Add specific tools or frameworks you use
- Adjust severity levels or scoring
- Add project-specific requirements

### Example: Add Custom SEO Check

Open `skills/seo-audit.md` and add:

```markdown
## 8. Custom Requirements for Codelabs Projects

### Brand Consistency
- [ ] Uses Codelabs brand colors (#123456, #789ABC)
- [ ] Includes Codelabs logo in OG image
- [ ] Footer contains required links (Privacy, Terms, Contact)

### Analytics Integration
- [ ] Google Analytics 4 installed (GA4-XXXXXXXXXX)
- [ ] Hotjar tracking configured
- [ ] Sentry error tracking enabled
```

---

## ➕ Adding New Skills

### Step 1: Create New Skill File

```bash
touch ~/.claude/plugins/codelabs-advisors/skills/my-new-skill.md
```

### Step 2: Add Frontmatter and Content

```markdown
---
name: my-new-skill
description: Brief description of what this skill does
tags: [custom, audit]
model: opus
---

You are an expert in [domain].

# My New Skill

## Instructions

[Your detailed prompt instructions here...]

## Output Format

[How you want the output structured...]
```

### Step 3: Test the Skill

```bash
/my-new-skill
```

No restart needed - it's automatically discovered!

---

## 🎨 Skill Templates

### Template: Audit/Review Skill

```markdown
---
name: [audit-name]
description: [What this audits]
tags: [audit, [category]]
model: opus
---

You are a senior [role] with [X]+ years of experience in [domain].

# [Audit Name]

Perform a comprehensive audit of [subject].

## 1. [Category 1]

### [Subcategory]
- [ ] Check [thing 1]
- [ ] Validate [thing 2]
- [ ] Verify [thing 3]

**Check:**
```bash
# Command to verify
```

## 2. [Category 2]

[More checks...]

## Output Format

Provide a detailed report:

### Status Summary

| Component | Status | Score |
|-----------|--------|-------|
| [Item 1] | ✅/❌ | X/10 |

### Issues Found

For each issue:
- **Severity**: Critical / High / Medium / Low
- **Issue**: Description
- **Fix**: Specific solution
- **Priority**: P0 / P1 / P2

### Next Steps
1. [Action item 1]
2. [Action item 2]
```

### Template: Consulting/Advisory Skill

```markdown
---
name: [role-name]
description: [What this role advises on]
tags: [consulting, [domain]]
model: opus
---

You are José Díaz's [role] partner with [X]+ years of experience in [domain].

# [Role] Consultation Mode

You bring expertise in:
- [Area 1]
- [Area 2]
- [Area 3]

## Your Role

Act as a trusted advisor who:
- [Behavior 1]
- [Behavior 2]
- [Behavior 3]

## Communication Style

- **[Style 1]**: [Description]
- **[Style 2]**: [Description]

## Areas of Expertise

### 1. [Area 1]
[Details...]

### 2. [Area 2]
[Details...]

## Decision Framework

When evaluating decisions, consider:
1. **[Factor 1]**: [Description]
2. **[Factor 2]**: [Description]

## Response Format

Structure your response as:

### [Section 1]
[Content]

### [Section 2]
[Content]

---

Now, as your [role], I'm ready to discuss [topics]. What would you like to explore?
```

---

## 🎯 Common Customizations

### Change Model Preference

**Current**: All skills use `model: opus` for maximum quality

**To change to Sonnet** (faster, cheaper):
```yaml
model: sonnet
```

**To change to Haiku** (fastest, cheapest):
```yaml
model: haiku
```

### Adjust Output Format

Find the "Output Format" section in any skill and modify:

```markdown
## Output Format

### Custom Format

1. **Summary**: One-paragraph overview
2. **Findings**: Bullet list of issues
3. **Priority Actions**: Top 3 things to fix immediately
4. **Code Examples**: Ready-to-use code snippets
```

### Add Project-Specific Checks

Add a section to relevant skills:

```markdown
## 99. Codelabs.studio Standards

### Required Services
- [ ] Uses Mailcow at mail.codelabs.studio
- [ ] Database hosted on self-hosted PostgreSQL (db.codelabs.studio)
- [ ] DNS managed via Spaceship.dev
- [ ] Authentication via Keycloak at auth.codelabs.studio

### Deployment
- [ ] Deployed to [your preferred host]
- [ ] Uses Docker containers
- [ ] Environment variables in `.env` (not committed)
```

### Customize Severity Levels

Change how issues are categorized:

```markdown
### Severity Definitions

- **P0 (Critical)**: [Your definition]
- **P1 (High)**: [Your definition]
- **P2 (Medium)**: [Your definition]
- **P3 (Low)**: [Your definition]
```

---

## 🔗 Skill Dependencies

### Referencing Other Skills

You can mention other skills in your custom skill:

```markdown
**Note**: For a complete security audit, also run `/security-audit`.
**See also**: `/performance-audit` for optimization recommendations.
```

### Chaining Skills

In your prompt, you can suggest running multiple skills:

```markdown
After reviewing the architecture, I recommend:
1. Run `/security-audit` to check for vulnerabilities
2. Run `/performance-audit` to optimize bottlenecks
3. Run `/seo-audit` before launch
```

---

## 📊 Advanced Customization

### Add Context from Config Expert

Reference credentials from your central config:

```markdown
## 1. Service Configuration Check

Check that services are configured correctly:

**Mailcow (mail.codelabs.studio)**:
- Use `/config-expert` to retrieve credentials
- Verify SMTP settings match stored configuration

**PostgreSQL Database (db.codelabs.studio)**:
- Use `/config-expert` to check connection string
- Validate against environment variables
```

### Integration with Hooks

You can create hooks that automatically run skills:

**Example**: Run security audit before commits

```bash
# In ~/.claude/hooks/pre-commit.sh
claude /security-audit --quiet
```

(See Claude Code hooks documentation for details)

---

## 🧪 Testing Your Changes

After modifying a skill:

1. **Test immediately**: `/your-skill-name`
2. **Check output format**: Ensure it's what you expect
3. **Verify model**: Check if using correct model (opus/sonnet/haiku)
4. **Test edge cases**: Try with different project types

---

## 🐛 Troubleshooting

### Skill Not Found

**Problem**: `/my-skill` says "skill not found"

**Solution**:
1. Check filename matches frontmatter `name:` field
2. Ensure file is in `~/.claude/plugins/codelabs-advisors/skills/`
3. Check YAML frontmatter is valid (proper `---` delimiters)

### Skill Not Using Opus

**Problem**: Skill seems to use Sonnet instead of Opus

**Solution**:
- Check `model:` field in frontmatter is set to `opus`
- Ensure no typos in frontmatter

### Changes Not Reflected

**Problem**: Edited skill but changes don't appear

**Solution**:
- Save the file (Cmd+S / Ctrl+S)
- Changes are immediate, no restart needed
- Check you edited the right file

### Formatting Issues

**Problem**: Skill output is poorly formatted

**Solution**:
- Use markdown properly (headings, lists, code blocks)
- Use tables for structured data
- Use code blocks with language tags:
  ````markdown
  ```bash
  command here
  ```
  ````

---

## 💡 Best Practices

### Writing Effective Skills

1. **Be specific**: Clear, detailed instructions
2. **Use examples**: Show what good output looks like
3. **Structure output**: Tables, headings, bullet points
4. **Provide context**: Explain the "why" not just "what"
5. **Include commands**: Give copy-paste ready commands

### Organizing Skills

- **Keep related skills together**: Use consistent naming (e.g., `*-audit`, `*-review`)
- **Use descriptive names**: `seo-audit` not `seo`
- **Tag appropriately**: Helps with searching and organization
- **Document assumptions**: Note any prerequisites or requirements

### Maintenance

- **Review periodically**: Update skills as best practices evolve
- **Version control**: Commit changes to git (optional)
- **Backup**: Keep copies of custom skills before major changes

---

## 📚 Resources

- **Plugin structure**: See `plugin.json` for configuration
- **Skill discovery**: Auto-discovery via `skills/**/*.md` pattern
- **Claude Code docs**: [Claude Code documentation](https://docs.anthropic.com/claude/docs/claude-code)

---

## 🤝 Sharing Skills

Want to share your custom skills?

1. Copy skill file to another machine:
   ```bash
   cp ~/.claude/plugins/codelabs-advisors/skills/my-skill.md /path/to/backup/
   ```

2. Or create a git repository:
   ```bash
   cd ~/.claude/plugins/codelabs-advisors
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin <your-repo-url>
   git push
   ```

---

**Need help?** The skills are just Markdown files - experiment freely! You can always restore from the original plugin installation.

**Version**: 1.0.0
**Last Updated**: 2026-02-02
