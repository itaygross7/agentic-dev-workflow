---
paths:
  - "**/harvesting_task_manager/**/*.py"
  - "**/*crawl*.py"
  - "**/*scrap*.py"
  - "**/*spider*.py"
  - "**/*harvest*.py"
---

# Web crawling / scraping rules (scoped)

Apply when writing or editing crawler/scraper code.

## Legal and ethical first
- Prefer an official API over scraping when one exists for the target site.
- Check and honor `robots.txt` (RFC 9309) for the target host before fetching; do not fetch paths it disallows for your user agent.
- Set an identifiable `User-Agent` (include a contact/URL) rather than spoofing a browser to evade blocking.
- Respect the target site's Terms of Service; do not scrape content behind auth/paywalls or scrape PII/credentials.

## Politeness and rate limiting
- Throttle requests per host (e.g. 1 req/sec default, configurable) and cap concurrency per host — do not fire unbounded parallel requests.
- Honor `Retry-After` on `429`/`503` responses; back off and stop escalating retries after a small bounded number of attempts.
- Respect an informal `Crawl-delay` directive in `robots.txt` when present.

## Tool selection
- Use `requests`/`httpx` + a parser (e.g. `bs4`, `selectolax`) for simple, low-volume, non-JS pages.
- Use `scrapy` for larger, multi-page crawls needing built-in scheduling, dedup, and politeness controls (`ROBOTSTXT_OBEY`, `DOWNLOAD_DELAY`, `CONCURRENT_REQUESTS`).
- Use a headless browser (`playwright`) only when the target requires JS rendering; it is heavier and slower — do not default to it.

## Reliability and safety
- Set explicit timeouts on every fetch and verify TLS (see `networking-security`).
- Deduplicate URLs before fetching (visited-set/queue) to avoid redundant load.
- Store only the data actually needed; do not persist unrelated PII or full raw HTML unless the task requires it.

## Done conditions
- robots.txt is checked and respected for the target host.
- Requests are rate-limited/bounded and use explicit timeouts.
- The chosen tool matches the scale/JS-requirement of the task (no unnecessary headless browser use).

Source: RFC 9309 (Robots Exclusion Protocol), Scrapy documentation — `docs.scrapy.org/en/latest/topics/broad-crawls.html` and `topics/settings.html` (`best-practices.html` is no longer a valid path).
