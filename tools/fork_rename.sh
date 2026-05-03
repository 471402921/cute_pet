#!/usr/bin/env bash
# fork_rename.sh — Bootstrap a new pixel app forked from cute_pixel.
#
# What this does (mechanical, derived from concrete pain points found while
# building this foundation):
#   1. pubspec.yaml `name: cute_pixel` → `name: <new>`
#   2. Find/replace `package:cute_pixel/` → `package:<new>/` in lib/ and test/
#   3. Rename `CutePixelApp` class (lib/main.dart + test/widget_test.dart)
#   4. Reset ARB `appTitle` in zh/en to placeholder (forces fork author to fill in)
#   5. Optionally delete features/pet/ + its tests + route registration (--strip-pet)
#   6. Reset _manifest.yaml's project: + features: list to empty starter
#   7. Run check-arch + check-assets + check-arb-sync + flutter analyze + tests
#
# What this does NOT do (would need first-fork experience to encode safely):
#   - Pick the fork's actual app name semantics (you fill ARB appTitle)
#   - Delete the cute_pixel git history (use `git checkout --orphan` or fresh clone)
#   - Update doc/decisions/ to reflect fork-specific decisions (manual)
#   - Reset assets/ namespaces under sprites/items/etc (manual; fork-dependent)
#
# This is a STARTER. After your first fork, when you hit a step this script
# missed, add it here and update tools/fork_rename.sh in the upstream foundation
# (PR back). Treat this as a living doc of fork-time pain.
#
# Usage:
#   bash tools/fork_rename.sh NEW_NAME=tomato_garden [STRIP_PET=1]
#
# Run from a CLEAN working tree (no uncommitted changes) so you can `git diff`
# the result before committing. The script aborts if working tree is dirty.

set -eu

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

# ---- Parse args (KEY=VAL form, simple & explicit) --------------------------
NEW_NAME=""
STRIP_PET=0
for arg in "$@"; do
  case "$arg" in
    NEW_NAME=*) NEW_NAME="${arg#NEW_NAME=}" ;;
    STRIP_PET=*) STRIP_PET="${arg#STRIP_PET=}" ;;
    -h|--help)
      awk 'NR==1{next} /^set -eu/{exit} /^#/{sub(/^# ?/,""); print}' "$0"
      exit 0
      ;;
    *) echo "fork_rename: unknown arg '$arg'" >&2; exit 2 ;;
  esac
done

if [ -z "$NEW_NAME" ]; then
  echo "fork_rename: NEW_NAME=<snake_case> is required" >&2
  echo "Example: bash tools/fork_rename.sh NEW_NAME=tomato_garden STRIP_PET=1" >&2
  exit 2
fi

# Validate NEW_NAME: snake_case, lowercase, must be a valid Dart package name.
if ! printf '%s' "$NEW_NAME" | grep -qE '^[a-z][a-z0-9_]*$'; then
  echo "fork_rename: NEW_NAME must be lowercase snake_case (got '$NEW_NAME')" >&2
  exit 2
fi
if [ "$NEW_NAME" = "cute_pixel" ]; then
  echo "fork_rename: NEW_NAME cannot be cute_pixel (you're already there)" >&2
  exit 2
fi

# ---- Safety: clean working tree --------------------------------------------
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "fork_rename: working tree is dirty. Commit or stash first so you can review the diff." >&2
  exit 2
fi

# Detect platform for sed -i.
case "$(uname)" in
  Darwin) SED_INPLACE=(sed -i '') ;;
  *)      SED_INPLACE=(sed -i)    ;;
esac

# Derive PascalCase variant for class rename.
# cute_pixel → CutePixel; tomato_garden → TomatoGarden
to_pascal() {
  printf '%s' "$1" | awk -F'_' '{
    out=""
    for (i = 1; i <= NF; i++) {
      out = out toupper(substr($i, 1, 1)) substr($i, 2)
    }
    print out
  }'
}
NEW_PASCAL="$(to_pascal "$NEW_NAME")"
OLD_NAME="cute_pixel"
OLD_PASCAL="CutePixel"

echo "fork_rename: $OLD_NAME → $NEW_NAME ($OLD_PASCAL""App → $NEW_PASCAL""App)"

# ---- Step 1: pubspec.yaml name --------------------------------------------
"${SED_INPLACE[@]}" -E "s/^name:[[:space:]]+$OLD_NAME$/name: $NEW_NAME/" pubspec.yaml
echo "  [1/7] pubspec.yaml name: $NEW_NAME"

# ---- Step 2: package: imports in lib/ + test/ -----------------------------
find lib test -type f -name '*.dart' \
  -exec "${SED_INPLACE[@]}" "s|package:$OLD_NAME/|package:$NEW_NAME/|g" {} \;
echo "  [2/7] package:$OLD_NAME/ → package:$NEW_NAME/"

# ---- Step 3: rename CutePixelApp class -------------------------------------
"${SED_INPLACE[@]}" "s/${OLD_PASCAL}App/${NEW_PASCAL}App/g" \
  lib/main.dart test/widget_test.dart
echo "  [3/7] ${OLD_PASCAL}App → ${NEW_PASCAL}App"

# ---- Step 4: reset ARB appTitle to placeholder ------------------------------
# Force fork author to consciously fill in the demo's display name.
"${SED_INPLACE[@]}" "s/\"appTitle\": .*/\"appTitle\": \"TODO_${NEW_NAME}_app_title\",/" \
  lib/l10n/app_zh.arb lib/l10n/app_en.arb
echo "  [4/7] ARB appTitle reset to TODO_${NEW_NAME}_app_title (fill in zh/en separately)"

# ---- Step 5: optionally strip features/pet/ --------------------------------
if [ "$STRIP_PET" = "1" ]; then
  rm -rf lib/features/pet test/features/pet lib/shared/route_args/pet_route_args.dart
  # Best-effort sed: catches direct token references (AppRoutes.pet, PetBinding,
  # PetPage) AND import lines pointing at features/pet/ (sed pattern won't
  # match the symbol on the import line itself). Two passes keep things explicit.
  "${SED_INPLACE[@]}" '/AppRoutes\.pet/d;/PetBinding/d;/PetPage/d' \
    lib/app/app_routes.dart lib/app/app_pages.dart
  "${SED_INPLACE[@]}" '/import.*features\/pet\//d' \
    lib/app/app_pages.dart lib/app/app_routes.dart
  # Trim ARB pet* keys (zh + en together to keep check-arb-sync passing).
  # Covers petTitle (no uppercase suffix), petAction* family (with uppercase),
  # and the home → pet entry text key homeMeetThePet.
  for arb in lib/l10n/app_zh.arb lib/l10n/app_en.arb; do
    "${SED_INPLACE[@]}" '/"petTitle"/d;/"petAction[A-Z]/d;/"homeMeetThePet"/d' "$arb"
  done
  echo "  [5/7] Stripped features/pet/ + route registration + pet* ARB keys"
  echo "        ⚠️  home_page.dart 里的 'Meet the pet' 按钮(跨多行 widget)未被自动改"
  echo "            grep -n 'pet\\|Pet' lib/features/home/ 二次手动清理"
else
  echo "  [5/7] Kept features/pet/ as reference (pass STRIP_PET=1 to remove)"
fi

# ---- Step 6: reset _manifest.yaml ------------------------------------------
"${SED_INPLACE[@]}" -E \
  -e "s/^project:.*/project: $NEW_NAME/" \
  -e "s/^generated_at:.*/generated_at: $(date +%Y-%m-%d)/" \
  lib/_manifest.yaml
echo "  [6/7] _manifest.yaml: project=$NEW_NAME, generated_at=$(date +%Y-%m-%d)"
echo "        (manually trim features:/decisions: lists for the fresh fork)"

# ---- Step 7: verify --------------------------------------------------------
echo "  [7/7] Running guards + analyze + tests..."
make check-all || { echo "fork_rename: check-all failed; review diff and fix before committing" >&2; exit 1; }
make analyze   || { echo "fork_rename: analyze failed; review diff and fix" >&2; exit 1; }
make test      || { echo "fork_rename: tests failed; widget_test likely needs the new appTitle filled in" >&2; exit 1; }

echo ""
echo "fork_rename: done. Review with \`git diff\`. Recommended next steps:"
echo "  1. Fill in lib/l10n/app_{zh,en}.arb appTitle (currently TODO_${NEW_NAME}_app_title)"
echo "  2. Trim _manifest.yaml features:/decisions: list for fresh fork"
echo "  3. Decide: keep cute_pixel git history or 'git checkout --orphan main'"
echo "  4. Update README.md + CLAUDE.md project intro line"
echo "  5. /cute-pixel-doc-prd <first_module> to start your fork's first feature"
exit 0
