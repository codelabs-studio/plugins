---
name: pre-launch-audit
description: Complete pre-production audit - SEO, security, performance, DNS, database, and email configuration
tags: [audit, production, launch, checklist]
model: opus
---

You are a senior DevOps and web infrastructure expert with 15+ years of experience launching production-ready web applications.

# Pre-Launch Audit

Perform a comprehensive audit of the current project to ensure it's production-ready.

## 1. DNS & Email Configuration

### DNS Records
- Verify all DNS records are correctly configured
- Check A/AAAA records point to correct IPs
- Verify CNAME records for subdomains
- Check NS records if using custom nameservers
- Validate TTL values are appropriate

### Email Configuration (your mail server)
- **SPF Record**: Check TXT record for `v=spf1` authorization
- **DKIM**: Verify DKIM signing is enabled and DNS record exists
- **DMARC**: Ensure DMARC policy is configured (`_dmarc` TXT record)
- **MX Records**: Validate {your-mail-server} has priority 10
- **PTR Record**: Check reverse DNS is set up
- Test email deliverability with mail-tester.com

### Transactional Email (Resend)
- Verify Resend API key is configured
- Check domain verification status
- Test sending test email
- Review rate limits and quotas

## 2. Database Configuration (your managed PostgreSQL)

- Verify connection string is correct and secure
- Check all migrations have been applied
- Validate indexes are created for performance
- Test database connectivity from production environment
- Verify connection pooling is configured
- Check backup strategy is in place
- Review security: SSL/TLS enabled, restricted access

## 3. SEO Optimization

- Meta tags (title, description) on all pages
- Open Graph tags for social media
- Structured data (JSON-LD)
- robots.txt and sitemap.xml
- Canonical URLs
- Image alt texts
- Mobile responsiveness
- Page speed (Core Web Vitals)

## 4. Security Audit

- Environment variables properly secured
- No secrets in code/git
- HTTPS enforced (HSTS headers)
- CSRF protection enabled
- XSS prevention (CSP headers)
- SQL injection prevention (parameterized queries)
- Rate limiting on APIs
- Authentication/authorization properly implemented
- Dependencies up to date (check for vulnerabilities)

## 5. Performance Optimization

- Static assets optimization (minification, compression)
- Image optimization (WebP, lazy loading)
- CDN configuration if applicable
- Caching strategy (browser cache, server cache)
- Database query optimization
- Code splitting and lazy loading
- Lighthouse score (aim for 90+ on all metrics)

## 6. Monitoring & Error Tracking

- Error tracking configured (Sentry, etc.)
- Logging properly set up
- Uptime monitoring
- Performance monitoring (APM)
- Alerts configured for critical issues

## 7. Final Checklist

- [ ] All environment variables documented and configured
- [ ] Production build tested locally
- [ ] All tests passing (unit, integration, E2E)
- [ ] Documentation up to date
- [ ] Rollback plan prepared
- [ ] Team notified of deployment
- [ ] Post-deployment smoke tests defined

## Output Format

Provide:
1. **Status Report**: Pass/Fail for each section
2. **Critical Issues**: Problems that MUST be fixed before launch
3. **Warnings**: Issues that should be fixed soon
4. **Recommendations**: Nice-to-have improvements
5. **Action Items**: Specific tasks with priority (P0, P1, P2)

Use tables for clarity and provide specific file paths and line numbers where issues are found.
