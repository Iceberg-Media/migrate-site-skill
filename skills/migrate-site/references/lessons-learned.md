# Lessons Learned

## 2026-06-23: Initial Setup and Test Migration

### What Worked
- USB drive had all API keys in `.env` file
- Install script handled most dependencies automatically
- Wrangler authenticated correctly with Iceberg Media account
- Migration runner successfully completed 14/15 steps on first real attempt

### What Failed and How We Fixed It

1. **npm missing** - Debian `nodejs` package doesn't include npm
   - Fix: `sudo apt install npm`

2. **Camofox VirtualDisplay async bug** - `get()` is async but called without await
   - Location: `node_modules/@askjo/camofox-browser/server.js:950`
   - Impact: Browser fails to launch, all capture operations fail
   - Fix: Add `await` before `localVirtualDisplay.get()`

3. **Playwright version mismatch** - v1.61.0 incompatible with Camoufox binary
   - Symptom: `/tabs` POST returns schema error about `isMobile`
   - Fix: `npm install playwright-core@1.58.0`

4. **DISPLAY not propagated** - Migration scripts spawn Camofox without DISPLAY
   - Location: `scripts/lib/visual-browser.js` spawn env
   - Fix: Add `DISPLAY: process.env.DISPLAY || ':99'` to env

5. **Missing build tools** - `better-sqlite3` needs C compiler
   - Fix: `sudo apt install build-essential`

6. **Memory threshold too high** - Default 1800MB, system had 1045MB
   - Fix: `export MIGRATION_MIN_AVAILABLE_MB=512`

### Optimization Notes
- Camofox binary download is 662MB - consider caching on USB
- GeoIP database is 66MB - also worth caching
- First migration takes ~12 minutes, subsequent runs should be faster
- `--fast` mode skips capture but fails on prepare-repo (missing source dir)
- Full mode is more reliable for testing

### Patches Applied
These patches survive npm installs but may need re-application after package updates:

1. `server.js:950` - await VirtualDisplay.get()
2. `visual-browser.js:86` - DISPLAY env var
3. `playwright-core` pinned to 1.58.0

### Environment Variables Required
```bash
CLOUDFLARE_API_TOKEN=<your-cloudflare-api-token>
CLOUDFLARE_ACCOUNT_ID=<your-cloudflare-account-id>
GITHUB_TOKEN=<your-github-personal-access-token>
GITHUB_ORG=Iceberg-Media
MIGRATION_MIN_AVAILABLE_MB=512
DISPLAY=:99
```

Store these in `/opt/migrate-site/.env` or `~/.env` (never commit). The USB drive's `.env` file has production values pre-configured.

### Migration Output
- Workdir: `/home/<user>/migrations/examplecom`
- Staging URL: `examplecom.<your-domain>.com`
- Steps passed: staging-dns, preflight, capture, classify, decide-stack, scaffold, setup-auth, prepare-repo, port-layout, port-pages, seo-agent, security-scan, staging-url, build+deploy
- Final failure: `Could not find zone for example.com` (expected - not a real domain)
