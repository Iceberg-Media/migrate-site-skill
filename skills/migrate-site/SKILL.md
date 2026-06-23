---
name: migrate-site
description: Deterministic website-to-Astro/EmDash migration workflow for agent harnesses. Use when an agent is asked to run, resume, validate, or diagnose a /migrate-site job that captures a source website, ports it to Astro plus EmDash CMS, deploys staging on Cloudflare, and verifies pixel/content/CMS fidelity.
---

# Migrate Site

## Purpose
Run one migration job with minimal agent reasoning. The runner owns the workflow; the agent only launches it, monitors logs, and reports blockers.

## Required Input
- Source URL.
- Target stack: `emdash`.
- Optional client-email value supplied by the operator.

## Command Contract
Run the local runner only:

```bash
node /absolute/path/to/scripts/run-migration.js "<source-url> to emdash client-email=<client-email>"
```

If the harness supports slash commands, `/migrate-site` must map to the same runner.

## Agent Rules
- Do not invent steps.
- Do not edit generated pages by hand to hide runner failures.
- Stop on the first hard failure.
- Report the exact workdir and log path.
- Do not print secrets, API keys, raw API tokens, account IDs, or private emails.
- Do not change DNS, MX, email routing, or production records without explicit operator approval.

## Vision / Screenshot Comparison
**Always take screenshots to compare source vs target before reporting visual parity.** The agent MUST NOT claim pages look the same without visual verification.

### Camofox Screenshot API
Camofox runs at `http://127.0.0.1:9377`. Use it to take full-page screenshots of both source and target pages.

**Quick screenshot script** (copy-paste into node -e):

```javascript
const { execFileSync } = require('child_process');
const fs = require('fs');
const BASE = 'http://127.0.0.1:9377';
const userId = 'screen-' + process.pid;
const sessionKey = 'sess-' + Date.now();

function curl(method, urlPath, body) {
  const args = ['-sS', '--fail', '-X', method, BASE + urlPath, '-H', 'Content-Type: application/json'];
  if (body) args.push('--data', JSON.stringify(body));
  return JSON.parse(execFileSync('curl', args, { encoding: 'utf-8', maxBuffer: 10*1024*1024, timeout: 60000 }));
}

function curlToFile(method, urlPath, filePath) {
  const args = ['-sS', '--fail', '-X', method, BASE + urlPath, '-o', filePath];
  execFileSync('curl', args, { maxBuffer: 10*1024*1024, timeout: 60000 });
}

function sleep(ms) { return new Promise(r => setTimeout(r, ms)); }

async function waitForLoad(tabId, timeoutMs = 10000) {
  const start = Date.now();
  while (Date.now() - start < timeoutMs) {
    try {
      const result = curl('GET', `/tabs/${tabId}/readyState?userId=${encodeURIComponent(userId)}`);
      if (result.readyState === 'complete') return true;
    } catch {}
    await sleep(500);
  }
  return false;
}

async function takeScreenshot(url, filename) {
  const tab = curl('POST', '/tabs', { userId, sessionKey, url });
  const tabId = tab.tabId;
  curl('POST', `/tabs/${tabId}/viewport`, { userId, width: 1440, height: 900 });
  
  // Wait for page load instead of fixed delay
  const loaded = await waitForLoad(tabId, 15000);
  if (!loaded) await sleep(3000); // fallback for slow connections
  
  curlToFile('GET', `/tabs/${tabId}/screenshot?userId=${encodeURIComponent(userId)}`, filename);
  console.log('OK: ' + filename);
  
  try { curl('DELETE', `/tabs/${tabId}?userId=${encodeURIComponent(userId)}`); } catch {}
}

// Usage:
// await takeScreenshot('https://source.com/page', 'src_page.png');
// await takeScreenshot('https://target.com/page', 'tgt_page.png');
```

### If camofox is not running, start it:
```bash
CAMOFOX_PORT=9377 node /opt/migrate-site/scripts/start-camofox-headless.mjs &
```

### Comparison workflow:
1. Take screenshot of source page → `screenshots/src_<page>.png`
2. Take screenshot of target page → `screenshots/tgt_<page>.png`
3. Use the `Read` tool to view both images
4. Identify specific differences (header, hero, layout, colors, content)
5. Fix the target page to match
6. Re-screenshot and verify

### Key differences to check:
- Header: nav items, buttons, logo position
- Hero: text alignment, background, CTA buttons
- Content: layout (single vs multi-column), section order
- Footer: columns, links, social icons
- Colors: background gradients, text colors, accent colors

## Success Gates
The final report may claim success only when all gates pass:
- Staging URL is reachable.
- Source routes and target routes match.
- **Visual parity verified via screenshots** (not just text comparison).
- Logo and public assets are served if present on the source.
- Source permalinks are preserved.
- CMS live-view `/pages/<slug>` redirects to the source permalink.
- `/sitemap.xml` exists and lists renderable source routes.
- EmDash CMS is initialized with pages, menus, media/settings, SEO/social settings, and content.
- Allowed login domains include the migrated source domain.
- PIN-code auth works; no passkey/biometric login.
- A private review URL exists at `/_emdash/admin/migration-review`.
- The report links to API token settings but never includes raw token values.

## Output
Report only:
- PASS or FAIL.
- Workdir.
- Failed step and log path if blocked.
- Staging URL.
- Private review URL.
- Sitemap URL.
- CMS links for content, pages, menus, media, SEO, social, allowed domains, and API tokens.
- **Screenshot comparison results** (which pages matched, what was different).

## References
- Read `references/runner-contract.md` when configuring a new local runner or adapting this skill to a new agent harness.
