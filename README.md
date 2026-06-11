# migrate-site skill

Public-safe skill scaffold for deterministic website-to-Astro/EmDash migrations.

This repo intentionally does not include API keys, account IDs, private emails, generated sites, migration logs, screenshots, or local secrets.

## Install

Copy `skills/migrate-site` into the skill directory used by your agent harness.

## Contract

The local environment must provide a migration runner that accepts:

```bash
node /absolute/path/to/scripts/run-migration.js "<source-url> to emdash client-email=<client-email>"
```

The runner must stop on first hard failure and write exact log paths.

