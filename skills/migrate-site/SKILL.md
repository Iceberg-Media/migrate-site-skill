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

## Success Gates
The final report may claim success only when all gates pass:
- Staging URL is reachable.
- Source routes and target routes match.
- Visual and content parity pass.
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

## References
- Read `references/runner-contract.md` when configuring a new local runner or adapting this skill to a new agent harness.

