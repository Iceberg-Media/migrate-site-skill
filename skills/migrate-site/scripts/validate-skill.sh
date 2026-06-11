#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

test -f "$root/SKILL.md"
test -f "$root/references/runner-contract.md"

if grep -RInE --exclude='validate-skill.sh' '(cfat_|sk-[A-Za-z0-9]|api[_-]?key[[:space:]]*=|password[[:space:]]*=|[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,})' "$root"; then
  echo "Secret-like value found. Remove it before publishing." >&2
  exit 1
fi

echo "migrate-site skill scaffold is public-safe"
