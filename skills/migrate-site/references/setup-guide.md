# Local Machine Setup Guide

Tested on: Debian Bookworm (antiX), 1.7GB RAM, x86_64

## Quick Setup (from USB)

Copy `.env` from USB to home directory and install all dependencies:

```bash
cp /media/*/migrate-setup/.env ~/.env
sudo bash /media/*/migrate-setup/install.sh
```

## Manual Setup

### 1. System Packages
```bash
sudo apt install -y build-essential xvfb
```

### 2. Node.js + npm
```bash
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo bash -
sudo apt install -y nodejs
```

### 3. Wrangler (Cloudflare Workers CLI)
```bash
sudo npm install -g wrangler@latest
```

### 4. Camofox Browser Binaries
```bash
cd /opt/migrate-site
npx camoufox-js fetch
```

### 5. Environment Variables
Copy `.env` to project root and source it:
```bash
cp /path/to/.env /opt/migrate-site/.env
export $(grep -v '^#' ~/.env | grep -v '^$' | xargs)
```

### 6. Cloudflare Authentication
Verify wrangler is authenticated:
```bash
wrangler whoami
```

### 7. GitHub CLI Authentication
```bash
gh auth status
```

## Known Issues and Fixes

### Issue: Camofox VirtualDisplay.get() is async but called without await

**Symptom:** Browser fails to launch with "cannot open display" error.

**Fix:** Patch `/opt/migrate-site/node_modules/@askjo/camofox-browser/server.js`:

Find line ~950:
```javascript
localVirtualDisplay = pluginCtx.createVirtualDisplay();
vdDisplay = localVirtualDisplay.get();
```

Change to:
```javascript
localVirtualDisplay = pluginCtx.createVirtualDisplay();
vdDisplay = await localVirtualDisplay.get();
```

### Issue: Playwright 1.61.0 incompatible with Camoufox binary

**Symptom:** `/tabs` POST returns error about `isMobile` not in schema.

**Fix:** Downgrade playwright-core:
```bash
cd /opt/migrate-site
npm install playwright-core@1.58.0
```

### Issue: DISPLAY not set when Camofox spawns from migration scripts

**Symptom:** Camofox server starts but browser can't connect to display.

**Fix:** Patch `/opt/migrate-site/scripts/lib/visual-browser.js`:

Find the spawn env block and add DISPLAY:
```javascript
env: {
  ...process.env,
  DISPLAY: process.env.DISPLAY || ':99',
  CAMOFOX_PORT: String((new URL(getCamofoxBaseUrl(options))).port || '9377'),
  CAMOFOX_WS_PATH: '/camoufox',
  CAMOFOX_BASE_URL: getCamofoxBaseUrl(options)
}
```

### Issue: Low RAM on small machines

**Symptom:** Migration fails with "Available RAM is X MB; migration requires at least 1800 MB".

**Fix:** Override the minimum:
```bash
export MIGRATION_MIN_AVAILABLE_MB=512
```

### Issue: Missing C compiler for native modules

**Symptom:** `npm rebuild better-sqlite3` fails with "cc: No such file or directory".

**Fix:**
```bash
sudo apt install -y build-essential
```

## Starting Camofox Manually

If the migration script can't auto-start Camofox:

```bash
export DISPLAY=:99
nohup node /opt/migrate-site/scripts/start-camofox-headless.mjs > /tmp/camofox.log 2>&1 &
sleep 10
curl -s http://127.0.0.1:9377/health
```

## Running a Migration

```bash
export $(grep -v '^#' ~/.env | grep -v '^$' | xargs)
export MIGRATION_MIN_AVAILABLE_MB=512
export DISPLAY=:99

node /opt/migrate-site/scripts/run-migration.js \
  "https://example.com client-email=client@example.com"
```

Use `--fast` for smoke tests (skips capture step).

## Verification Checklist

After setup, verify all systems:
```bash
# Node.js
node --version  # Should be v22.x

# Wrangler
wrangler --version  # Should be 4.x
wrangler whoami  # Should show Iceberg Media

# GitHub CLI
gh auth status  # Should show your GitHub account

# Camofox
curl -s http://127.0.0.1:9377/health  # Should show browserConnected: true

# API Keys
echo $CLOUDFLARE_API_TOKEN  # Should not be empty
echo $GITHUB_TOKEN  # Should not be empty
```

## Path Configuration

The migration runner expects paths under a specific home directory. Create symlinks:

```bash
sudo mkdir -p /home/<user>/migrations
sudo chown <user>:<user> /home/<user>
ln -sf /opt/migrate-site/scripts /home/<user>/scripts
ln -sf /opt/migrate-site/docs/AGENTS.md /home/<user>/AGENTS.md
ln -sf /opt/migrate-site/docs/MIGRATION_RUNBOOK.md /home/<user>/MIGRATION_RUNBOOK.md
ln -sf /opt/migrate-site/docs/MIGRATION_TASTE.md /home/<user>/MIGRATION_TASTE.md
```
