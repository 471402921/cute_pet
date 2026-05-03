#!/usr/bin/env bash
# check_arch.sh — Mechanically enforce the 4 architectural rules
# from doc/architecture.md ("4 条铁律").
#
# Rules:
#   RULE-1  features/A/ MUST NOT import from features/B/ (any other feature).
#   RULE-2  Cross-module sharing only via core/ or shared/ (no feature imported
#           by another feature). Overlaps RULE-1; checked together.
#   RULE-3  Single direction: features/* → core/* + shared/* → external.
#           core/ and shared/ MUST NOT import from features/.
#   RULE-4  Files directly under features/{module}/ MUST follow {module}_*.dart.
#           The widgets/ subdir is exempt (free names allowed inside it).
#
# Generated files are skipped: *.freezed.dart, *.g.dart,
#   lib/l10n/app_localizations*.dart.
#
# Exit code: 0 clean, 1 if any violation found.

set -u

# Resolve repo root (parent of tools/).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LIB_DIR="$REPO_ROOT/lib"
FEATURES_DIR="$LIB_DIR/features"

if [ ! -d "$LIB_DIR" ]; then
  echo "check_arch: lib/ not found at $LIB_DIR" >&2
  exit 2
fi

VIOLATIONS=0

# is_generated <path>  — return 0 if file is a generated/excluded file.
is_generated() {
  case "$1" in
    *.freezed.dart) return 0 ;;
    *.g.dart) return 0 ;;
    */lib/l10n/app_localizations*.dart) return 0 ;;
    *) return 1 ;;
  esac
}

# Strip leading whitespace then test for an active import line.
# An import line is recognised only if it's not a // line comment.
# We grep `^[[:space:]]*import[[:space:]]` and rely on grep -n for line numbers.
# Block comments (/* ... */) are not handled — they're vanishingly rare for
# imports; false positives there are acceptable per the brief
# ("over-strict if needed; false positives are OK if they're informative").

# ---- RULE-1 / RULE-2: features/A imports features/B -------------------------
# Walk every .dart file under lib/features/{A}/ and look for
#   import 'package:cute_pixel/features/B/...'
# where B != A.
if [ -d "$FEATURES_DIR" ]; then
  while IFS= read -r -d '' file; do
    is_generated "$file" && continue

    # Owning module = first path segment under features/.
    rel="${file#"$FEATURES_DIR"/}"
    own_module="${rel%%/*}"

    # Find import lines referencing some features/<X>/ path.
    while IFS= read -r line; do
      [ -z "$line" ] && continue
      lineno="${line%%:*}"
      content="${line#*:}"

      # Skip line comments.
      trimmed="$(printf '%s' "$content" | sed -E 's/^[[:space:]]+//')"
      case "$trimmed" in
        //*) continue ;;
      esac

      # Extract the imported module name from
      #   package:cute_pixel/features/<MOD>/...
      imported="$(printf '%s' "$content" \
        | sed -nE "s|.*package:cute_pixel/features/([A-Za-z0-9_]+)/.*|\1|p" \
        | head -n1)"
      [ -z "$imported" ] && continue

      if [ "$imported" != "$own_module" ]; then
        rel_path="${file#"$REPO_ROOT"/}"
        echo "[RULE-1] $rel_path:$lineno — features/$own_module/ imports features/$imported/ (cross-feature import forbidden; use core/ or shared/ per architecture rule 1 & 2)"
        VIOLATIONS=$((VIOLATIONS + 1))
      fi
    done < <(grep -nE "^[[:space:]]*import[[:space:]].*package:cute_pixel/features/" "$file" 2>/dev/null || true)
  done < <(find "$FEATURES_DIR" -type f -name '*.dart' -print0)
fi

# ---- RULE-3: core/ or shared/ imports features/ -----------------------------
for layer in core shared; do
  layer_dir="$LIB_DIR/$layer"
  [ -d "$layer_dir" ] || continue

  while IFS= read -r -d '' file; do
    is_generated "$file" && continue

    while IFS= read -r line; do
      [ -z "$line" ] && continue
      lineno="${line%%:*}"
      content="${line#*:}"

      trimmed="$(printf '%s' "$content" | sed -E 's/^[[:space:]]+//')"
      case "$trimmed" in
        //*) continue ;;
      esac

      rel_path="${file#"$REPO_ROOT"/}"
      echo "[RULE-3] $rel_path:$lineno — $layer/ imports features/ (single-direction rule: features/* → core/* + shared/* → external; reverse forbidden)"
      VIOLATIONS=$((VIOLATIONS + 1))
    done < <(grep -nE "^[[:space:]]*import[[:space:]].*package:cute_pixel/features/" "$file" 2>/dev/null || true)
  done < <(find "$layer_dir" -type f -name '*.dart' -print0)
done

# ---- RULE-4: file naming under features/{module}/ ---------------------------
# Files DIRECTLY in features/{module}/ must be named {module}_*.dart.
# Subdirectories (e.g. widgets/, components/) are exempt.
# Generated files (*.freezed.dart, *.g.dart) are exempt — their basename
# already starts with {module}_ via the source they're generated from
# (e.g. pet_models.freezed.dart matches pet_*).
if [ -d "$FEATURES_DIR" ]; then
  for module_dir in "$FEATURES_DIR"/*/; do
    [ -d "$module_dir" ] || continue
    module_name="$(basename "$module_dir")"
    expected_prefix="${module_name}_"

    # Only files at depth 1 (direct children); subdirs are skipped.
    while IFS= read -r -d '' file; do
      is_generated "$file" && continue
      base="$(basename "$file")"

      case "$base" in
        "${expected_prefix}"*.dart)
          # OK — matches {module}_*.dart
          ;;
        *)
          rel_path="${file#"$REPO_ROOT"/}"
          echo "[RULE-4] $rel_path:1 — file in features/$module_name/ must be named ${expected_prefix}*.dart (got '$base')"
          VIOLATIONS=$((VIOLATIONS + 1))
          ;;
      esac
    done < <(find "$module_dir" -maxdepth 1 -type f -name '*.dart' -print0)
  done
fi

# ---- Summary -----------------------------------------------------------------
if [ "$VIOLATIONS" -gt 0 ]; then
  echo ""
  echo "check_arch: $VIOLATIONS violation(s) found." >&2
  exit 1
fi

echo "check_arch: OK (4 rules, 0 violations)"
exit 0
