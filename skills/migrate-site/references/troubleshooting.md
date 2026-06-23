# Troubleshooting Guide

## Migration Failures

### Capture Step Fails

**Check logs:**
```bash
cat /home/<user>/migrations/<site>/logs/03-capture.log
```

**Common causes:**
1. Camofox not running → start it manually, see setup-guide.md
2. Playwright version mismatch → downgrade to 1.58.0
3. DISPLAY not set → export DISPLAY=:99
4. Port 9377 in use → kill with `sudo fuser -k 9377/tcp`

### Deploy Step Fails

**Check logs:**
```bash
cat /home/<user>/migrations/<site>/logs/deploy-*.log
```

**Common causes:**
1. `cc: No such file or directory` → install build-essential
2. `Could not find zone for domain` → domain not on Cloudflare
3. Wrangler not authenticated → run `wrangler login` or set CLOUDFLARE_API_TOKEN

### Memory Check Fails

**Symptom:** `Available RAM is X MB; migration requires at least 1800 MB`

**Fix:**
```bash
export MIGRATION_MIN_AVAILABLE_MB=512
```

Or close other applications to free RAM.

### Camofox Server Crashes Immediately

**Check server log:**
```bash
cat /tmp/camofox.log
```

**Common causes:**
1. Xvfb not installed → `sudo apt install xvfb`
2. Camoufox binaries not fetched → `npx camoufox-js fetch`
3. Port already in use → `sudo fuser -k 9377/tcp`

### DNS Provisioning Fails

**Symptom:** Worker deploys but route doesn't work

**Check:**
```bash
wrangler route list --env staging
```

**Fix:** Ensure domain is proxied by Cloudflare and zone exists.

## Performance Issues

### Slow Capture

- Reduce browser concurrency: set `CAMOFOX_CONCURRENCY=1`
- Use `--fast` mode for smoke tests
- Ensure Xvfb is running (avoids display negotiation overhead)

### Slow Build

- Clear node_modules and reinstall: `rm -rf node_modules && npm install`
- Check for native module rebuild issues

## Logs Location

All migration logs are at:
```bash
/home/<user>/migrations/<site>/logs/
```

Key logs:
- `03-capture.log` - Browser capture step
- `06-scaffold.log` - Project scaffolding
- `10-port-pages.log` - Page porting
- `14-staging-url.log` - DNS staging
- Deploy logs are inline in the migration output
