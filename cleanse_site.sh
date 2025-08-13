#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"
[ -d docs ] || { echo "❌ docs/ missing"; exit 1; }

echo "==> Cleaning images"
mkdir -p docs/_assets/img
find docs/_assets/img -type f -print -delete

echo "==> Removing <img> tags (avoid broken images)"
find docs -type f -name '*.html' -print0 | xargs -0 sed -i -E \
  -e 's#<img[^>]*>#<!-- image removed for demo -->#g'

echo "==> Removing <base> tags (can cause cross-site jumps)"
find docs -type f -name '*.html' -print0 | xargs -0 sed -i -E \
  -e 's#<base[^>]*>##g'

echo "==> Rewriting links that pointed to other repos on your GitHub Pages"
# e.g. https://otiseduncan.github.io/old-repo/whatever  ->  /whatever
find docs -type f -name '*.html' -print0 | xargs -0 sed -i -E \
  -e 's#https?://otiseduncan\.github\.io/[^/]+/#/#g'

echo "==> Converting church sections -> restaurant sections (paths + labels)"
find docs -type f -name '*.html' -print0 | xargs -0 sed -i -E \
  -e 's#/teachings/#/menu/#g; s#>Teachings<#>Menu<#g' \
  -e 's#/speaking/#/reservations/#g; s#>Speaking<#>Reservations<#g' \
  -e 's#/media/#/gallery/#g; s#>Media<#>Gallery<#g' \
  -e 's#/prayer/#/location/#g; s#>Prayer<#>Location<#g' \
  -e 's#/support/#/hours/#g; s#>Support<#>Hours<#g'

echo "==> Ensuring shim + CSS present everywhere and basic layout wraps"
# Create shim if missing
if [ ! -f docs/_assets/js/gh-pages-shim.js ]; then
  mkdir -p docs/_assets/js
  cat > docs/_assets/js/gh-pages-shim.js <<'JS'
(function(){if(!/\.github\.io$/.test(location.hostname))return;var p=location.pathname.split('/').filter(Boolean),prefix=p.length?'/'+p[0]+'/':'/';function fix(attr){document.querySelectorAll('['+attr+'^="/"]').forEach(function(el){var v=el.getAttribute(attr);if(!v||/^\/\//.test(v))return;el.setAttribute(attr,prefix+v.replace(/^\//,''));});}fix('href');fix('src');})();
JS
fi

# For each HTML: ensure <head> has CSS, add <main class="container"> wrapper if missing, ensure shim before </body>
while IFS= read -r -d '' f; do
  # Add minimal head/body wrapper if file lacks <head>
  if ! grep -qi '<head>' "$f"; then
    sed -i '1s|^|<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><link rel="stylesheet" href="/_assets/css/global.css"><title>Page</title></head><body>|' "$f"
    echo "</body></html>" >> "$f"
  fi
  # Ensure stylesheet link
  grep -qi '_assets/css/global.css' "$f" || \
    sed -i 's#</head>#<link rel="stylesheet" href="/_assets/css/global.css"></head>#i' "$f"
  # Ensure main wrapper for basic formatting
  if ! grep -qi '<main' "$f"; then
    sed -i 's#<body[^>]*>#&\n<main class="container">#i' "$f"
  fi
  grep -qi '</main>' "$f" || \
    sed -i 's#</body>#</main>\n</body>#i' "$f"
  # Ensure shim
  grep -qi 'gh-pages-shim.js' "$f" || \
    sed -i 's#</body>#  <script src="_assets/js/gh-pages-shim.js"></script>\n</body>#i' "$f"
done < <(find docs -type f -name '*.html' -print0)

echo "==> Removing inline background URLs (neutralize hero backgrounds)"
find docs -type f -name '*.html' -print0 | xargs -0 sed -i -E \
  -e 's#background:url\([^)]+\)#background:#g'

echo "==> Commit & push"
git add -A
git commit -m "Cleanup: remove images, fix links local-only, normalize layout"
git push
echo "✅ Cleanup complete."
