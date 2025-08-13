#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"
[ -f docs/index.html ] || { echo "❌ docs/index.html not found"; exit 1; }

mkdir -p docs/_backup_layout && rsync -a docs/ docs/_backup_layout/

# 1) Derive HEADER (before <main>), MAIN_OPEN line, and FOOTER (from </main> onward) from homepage
L_OPEN=$(grep -inm1 '<main' docs/index.html | cut -d: -f1 || true)
L_CLOSE=$(grep -inm1 '</main>' docs/index.html | cut -d: -f1 || true)

if [ -z "${L_OPEN:-}" ] || [ -z "${L_CLOSE:-}" ]; then
  echo "❌ Cannot find <main> or </main> in docs/index.html — aborting"
  exit 1
fi

HEADER_FILE="$(mktemp)"; MAIN_OPEN_FILE="$(mktemp)"; FOOTER_FILE="$(mktemp)"
sed -n "1,$((L_OPEN-1))p" docs/index.html > "$HEADER_FILE"
sed -n "${L_OPEN}p" docs/index.html > "$MAIN_OPEN_FILE"
sed -n "${L_CLOSE},\$p" docs/index.html > "$FOOTER_FILE"

# 2) Clean cross-site links & images across all pages
#    - remove <base> tags (they can send you to another site)
#    - rewrite links like https://otiseduncan.github.io/OLDREPO/... to site-local (/...)
#    - drop <img> tags for now (we'll add new images later)
find docs -type f -name '*.html' -print0 | xargs -0 sed -i -E \
  -e 's#<base[^>]*>##g' \
  -e 's#https?://otiseduncan\.github\.io/[^/]+/#/#g' \
  -e 's#<img[^>]*>#<!-- image removed for demo -->#g'

# 3) For each page, keep its content but wrap it with homepage header/nav and footer
while IFS= read -r -d '' f; do
  # Skip the homepage itself; it’s already the template
  [ "$f" = "docs/index.html" ] && continue

  TMP_CONTENT="$(mktemp)"
  # Prefer the content inside this page's <main>...</main>, else fallback to body content, else entire file
  if grep -qi '</main>' "$f" && grep -qi '<main' "$f"; then
    awk 'BEGIN{IGNORECASE=1; s=0} /<main/{s=1; next} /<\/main>/{s=0; exit} s{print}' "$f" > "$TMP_CONTENT"
  elif grep -qi '<body' "$f"; then
    awk 'BEGIN{IGNORECASE=1; s=0} /<body/{s=1; next} /<\/body>/{s=0; exit} s{print}' "$f" > "$TMP_CONTENT"
  else
    cat "$f" > "$TMP_CONTENT"
  fi

  NEW_FILE="$(mktemp)"
  cat "$HEADER_FILE"          >  "$NEW_FILE"
  cat "$MAIN_OPEN_FILE"       >> "$NEW_FILE"
  cat "$TMP_CONTENT"          >> "$NEW_FILE"
  cat "$FOOTER_FILE"          >> "$NEW_FILE"

  # Ensure stylesheet + shim exist (in case homepage footer changes later)
  grep -qi '_assets/css/global.css' "$NEW_FILE" || \
    sed -i 's#</head>#<link rel="stylesheet" href="/_assets/css/global.css"></head>#i' "$NEW_FILE"
  grep -qi 'gh-pages-shim.js' "$NEW_FILE" || \
    sed -i 's#</body>#  <script src="_assets/js/gh-pages-shim.js"></script>\n</body>#i' "$NEW_FILE"

  # Overwrite the page
  mv "$NEW_FILE" "$f"
  rm -f "$TMP_CONTENT"
done < <(find docs -type f -name '*.html' -print0)

# 4) Normalize church → restaurant nav labels/paths just in case
find docs -type f -name '*.html' -print0 | xargs -0 sed -i -E \
  -e 's#>Teachings<#>Menu<#g;  s#/teachings/#/menu/#g' \
  -e 's#>Speaking<#>Reservations<#g; s#/speaking/#/reservations/#g' \
  -e 's#>Media<#>Gallery<#g; s#/media/#/gallery/#g' \
  -e 's#>Prayer<#>Location<#g; s#/prayer/#/location/#g' \
  -e 's#>Support<#>Hours<#g; s#/support/#/hours/#g'

# 5) Commit
git add -A
git commit -m "Unify layout: use homepage header/nav/footer on all pages; remove images; fix links"
echo "✅ Layout unified. Pushing next..."
