#!/usr/bin/env bash
# check_arb_sync.sh — Mechanically enforce conventions §4 双语同步.
#
# Rule:
#   ARB-1  lib/l10n/app_zh.arb and lib/l10n/app_en.arb MUST have the exact
#          same set of translation keys. Adding a key to one file without the
#          other is a runtime hazard (null at lookup time on the other locale).
#
# Strategy: extract top-level JSON keys (excluding `@@locale` and `@*`
# metadata keys) from both files via python3, diff. If either file is missing
# or invalid JSON, fail loudly.
#
# Exit code: 0 clean, 1 if any violation found.

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
L10N="$REPO_ROOT/lib/l10n"
ZH="$L10N/app_zh.arb"
EN="$L10N/app_en.arb"

if [ ! -f "$ZH" ] || [ ! -f "$EN" ]; then
  echo "check_arb_sync: missing ARB files (zh=$ZH, en=$EN)" >&2
  exit 2
fi

# Extract sorted user keys (skip @@locale and any @-prefixed metadata).
extract_keys() {
  python3 -c "
import json, sys
with open('$1') as f:
    d = json.load(f)
keys = sorted(k for k in d if not k.startswith('@'))
for k in keys:
    print(k)
"
}

ZH_KEYS="$(extract_keys "$ZH")" || { echo "check_arb_sync: failed to parse $ZH" >&2; exit 2; }
EN_KEYS="$(extract_keys "$EN")" || { echo "check_arb_sync: failed to parse $EN" >&2; exit 2; }

ONLY_IN_ZH="$(comm -23 <(printf '%s\n' "$ZH_KEYS") <(printf '%s\n' "$EN_KEYS"))"
ONLY_IN_EN="$(comm -13 <(printf '%s\n' "$ZH_KEYS") <(printf '%s\n' "$EN_KEYS"))"

VIOLATIONS=0

if [ -n "$ONLY_IN_ZH" ]; then
  while IFS= read -r k; do
    echo "[ARB-1] lib/l10n/app_zh.arb:1 — key '$k' present in zh but missing from en (conventions §4: never add a key to one ARB without the other)"
    VIOLATIONS=$((VIOLATIONS + 1))
  done <<< "$ONLY_IN_ZH"
fi

if [ -n "$ONLY_IN_EN" ]; then
  while IFS= read -r k; do
    echo "[ARB-1] lib/l10n/app_en.arb:1 — key '$k' present in en but missing from zh (conventions §4: never add a key to one ARB without the other)"
    VIOLATIONS=$((VIOLATIONS + 1))
  done <<< "$ONLY_IN_EN"
fi

if [ "$VIOLATIONS" -gt 0 ]; then
  echo ""
  echo "check_arb_sync: $VIOLATIONS violation(s) found." >&2
  exit 1
fi

ZH_COUNT="$(printf '%s\n' "$ZH_KEYS" | wc -l | tr -d ' ')"
echo "check_arb_sync: OK (zh=en=$ZH_COUNT keys)"
exit 0
