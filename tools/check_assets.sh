#!/usr/bin/env bash
# check_assets.sh — Mechanical guards for the assets/ type-first directory.
#
# Rules (covers what conventions / each _template/README warns about, but only
# in prose; this script makes them mechanical):
#   ASSET-1  pubspec.yaml's active flutter.assets: list MUST NOT reference any
#            `_template/` path. Templates are ground truth, never bundled.
#   ASSET-2  Each assets/{type}/_template/ directory MUST contain only README.md
#            (and optionally manifest.json / slice.json). Real binary artifacts
#            (PNG, JPG, OGG, WAV, MP3, TTF, FNT) inside a _template/ would mean
#            someone confused "edit template" with "cp from template" — refuse.
#
# Exit code: 0 clean, 1 if any violation found.

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PUBSPEC="$REPO_ROOT/pubspec.yaml"
ASSETS_DIR="$REPO_ROOT/assets"

VIOLATIONS=0

# ---- ASSET-1: pubspec.yaml MUST NOT enable any _template/ path -------------
# We look at active (non-comment) `- assets/.../_template/...` lines under the
# flutter: section. Lines starting with optional whitespace then `#` are
# comments and ignored.
if [ -f "$PUBSPEC" ]; then
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    lineno="${line%%:*}"
    content="${line#*:}"
    # Strip leading whitespace.
    trimmed="$(printf '%s' "$content" | sed -E 's/^[[:space:]]+//')"
    case "$trimmed" in
      \#*) continue ;;  # comment
    esac
    # Match `- assets/.../_template/...` in active YAML.
    case "$trimmed" in
      -[[:space:]]*assets/*_template*)
        echo "[ASSET-1] pubspec.yaml:$lineno — \`$trimmed\` enables a _template/ path; templates must never enter the build bundle (cp the template to a real namespace first)"
        VIOLATIONS=$((VIOLATIONS + 1))
        ;;
    esac
  done < <(grep -nE "_template" "$PUBSPEC" 2>/dev/null || true)
fi

# ---- ASSET-2: no real binary artifacts inside any assets/**/_template/ -----
if [ -d "$ASSETS_DIR" ]; then
  while IFS= read -r -d '' file; do
    base="$(basename "$file")"
    case "$base" in
      README.md|manifest.json|slice.json) continue ;;
      *.md|*.json) continue ;;  # any future textual config is OK
    esac
    rel_path="${file#"$REPO_ROOT"/}"
    echo "[ASSET-2] $rel_path:1 — non-text artifact inside a _template/; templates are skeletons (README + optional manifest only). Real PNG/audio/font belongs under assets/{type}/{namespace}/{id}/, NOT inside _template/"
    VIOLATIONS=$((VIOLATIONS + 1))
  done < <(find "$ASSETS_DIR" -type d -name '_template' -print0 | xargs -0 -I{} find {} -type f -print0)
fi

# ---- Summary ---------------------------------------------------------------
if [ "$VIOLATIONS" -gt 0 ]; then
  echo ""
  echo "check_assets: $VIOLATIONS violation(s) found." >&2
  exit 1
fi

echo "check_assets: OK (2 rules, 0 violations)"
exit 0
