---
name: web-crawling-workflow
description: Plan and implement a web crawling/scraping task safely, legally, and efficiently.
---

# Web Crawling Workflow Skill

Use before writing any crawler/scraper code, not just when editing an existing one.

## Workflow
1. **Check for a legit alternative and permission first**
   - Apply `~/.claude/rules/web-crawling-conventions.md`'s legal/ethical and politeness rules: official API check, robots.txt, ToS, identifiable User-Agent, and rate limits.
   - Stop and flag the task if scraping looks disallowed or legally ambiguous.
2. **Choose the right tool for the scale**
   - Per `~/.claude/rules/web-crawling-conventions.md`'s tool-selection rule, choose `requests`/`httpx` + parser, `scrapy`, or `playwright` (JS-only, last resort) for the actual scale and JS requirement.
3. **Implement incrementally**
   - Build the fetch layer first (timeouts, TLS verify, retries) and verify it against a couple of real pages.
   - Add parsing/extraction next, verified against saved sample HTML rather than live re-fetching in tests.
   - Add dedup/visited-set and storage last.
4. **Verify**
   - Confirm robots.txt rules are enforced (unit test against a fixture robots.txt).
   - Confirm rate limiting/backoff under a mocked 429/503 response.
5. **Report**
   - Summarize targets, politeness settings, and any legal/ethical caveats.

## Guardrails
- Never scrape credentials, payment data, or other sensitive PII.
- Never bypass paywalls, auth, or CAPTCHA protections.
- Never disable TLS verification or drop timeouts for "speed."
- Store only the fields the task actually needs.

## Completion checklist
- [ ] robots.txt checked and honored.
- [ ] Tool choice matches scale/JS requirement (no default headless browser).
- [ ] Rate limiting, timeouts, and bounded retries are in place.
- [ ] No sensitive or unnecessary data is persisted.
