# Runner Contract

## Environment
The runner should receive credentials and account-specific settings through environment variables or the agent harness secret store. Do not hardcode them in the skill.

Required capabilities:
- Cloudflare Workers deployment.
- Cloudflare D1 database per migrated site.
- Cloudflare KV namespace per migrated site.
- Email sending for PIN-code authentication.
- Browser capture backend for screenshots and DOM capture.
- Astro build.
- EmDash CMS seed/import.

## Naming
Use a normalized site key derived from the source hostname:

```text
examplecouk
```

Use the same key for:
- workdir prefix
- staging hostname
- worker name
- D1 database name
- KV namespace name
- generated package name

Keep Cloudflare worker names under DNS label limits.

## Isolation
Each migrated site must have its own:
- workdir
- target app
- D1 database
- KV namespace
- staging route
- EmDash seed

Only shared mail sender infrastructure may be reused, and only when explicitly configured outside this skill.

## Verification
The runner should fail hard when:
- staging is unreachable
- source logo/public assets are missing in target
- source routes are missing
- CMS seed has no pages
- CMS live-view permalinks produce 404
- sitemap is missing or incomplete
- login/auth setup is incomplete
- build or deployment fails

The runner should write a private review page at:

```text
/_emdash/admin/migration-review
```

The review page should require authentication and link to:
- staging home
- sitemap
- pages
- menus
- media
- SEO settings
- social settings
- allowed domains
- API tokens

## Reporting
Final reports must not contain secrets. For API tokens, report only the admin URL where an operator can create or rotate a token.

