#!/usr/bin/env bash
set -euo pipefail

TITLE="${1:-Brick Oven Grill}"
CITY="${2:-Macon, GA}"
PHONE="${3:-+1-478-555-0123}"

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"
[ -d docs ] || { echo "❌ docs/ missing"; exit 1; }

# A) Update homepage title/H1 (best-effort; won’t fail if not found)
sed -i -E "s|<title>.*</title>|<title>${TITLE}</title>|" docs/index.html || true
sed -i -E "s|<h1[^>]*>.*</h1>|<h1>${TITLE}</h1>|" docs/index.html || true

# B) Create restaurant sections
mkdir -p docs/{menu,reservations,hours,location,gallery,about,contact}

cat > docs/menu/index.html <<'HTML'
<!doctype html><html lang="en"><head><meta charset="utf-8"><title>Menu</title><meta name="viewport" content="width=device-width,initial-scale=1"><link rel="stylesheet" href="/_assets/css/global.css"></head><body>
<header><h1>Menu</h1></header>
<main class="container">
  <section><h2>Starters</h2><ul><li>Garlic Knots</li><li>Bruschetta</li></ul></section>
  <section><h2>Mains</h2><ul><li>Margherita Pizza</li><li>Spaghetti Pomodoro</li></ul></section>
  <section><h2>Desserts</h2><ul><li>Tiramisu</li><li>Gelato</li></ul></section>
</main>
<script src="/_assets/js/gh-pages-shim.js"></script></body></html>
HTML

cat > docs/reservations/index.html <<'HTML'
<!doctype html><html lang="en"><head><meta charset="utf-8"><title>Reservations</title><meta name="viewport" content="width=device-width,initial-scale=1"><link rel="stylesheet" href="/_assets/css/global.css"></head><body>
<header><h1>Reservations</h1></header>
<main class="container">
  <p>Call us or email to reserve a table.</p>
  <ul>
    <li>Phone: <a href="tel:+15555550123">+1 (555) 555-0123</a></li>
    <li>Email: <a href="mailto:reservations@example.com">reservations@example.com</a></li>
  </ul>
</main>
<script src="/_assets/js/gh-pages-shim.js"></script></body></html>
HTML

cat > docs/hours/index.html <<'HTML'
<!doctype html><html lang="en"><head><meta charset="utf-8"><title>Hours</title><meta name="viewport" content="width=device-width,initial-scale=1"><link rel="stylesheet" href="/_assets/css/global.css"></head><body>
<header><h1>Hours</h1></header>
<main class="container"><p>Mon–Thu 11:00–21:00 · Fri–Sat 11:00–22:00 · Sun 12:00–20:00</p></main>
<script src="/_assets/js/gh-pages-shim.js"></script></body></html>
HTML

cat > docs/location/index.html <<'HTML'
<!doctype html><html lang="en"><head><meta charset="utf-8"><title>Location</title><meta name="viewport" content="width=device-width,initial-scale=1"><link rel="stylesheet" href="/_assets/css/global.css"></head><body>
<header><h1>Location</h1></header>
<main class="container">
  <p>123 Main St, Macon, GA</p>
  <p><a href="https://maps.google.com/?q=123 Main St, Macon, GA" target="_blank" rel="noopener">Open in Google Maps</a></p>
</main>
<script src="/_assets/js/gh-pages-shim.js"></script></body></html>
HTML

cat > docs/gallery/index.html <<'HTML'
<!doctype html><html lang="en"><head><meta charset="utf-8"><title>Gallery</title><meta name="viewport" content="width=device-width,initial-scale=1"><link rel="stylesheet" href="/_assets/css/global.css"></head><body>
<header><h1>Gallery</h1></header>
<main class="container"><p>Photos coming soon.</p></main>
<script src="/_assets/js/gh-pages-shim.js"></script></body></html>
HTML

cat > docs/about/index.html <<'HTML'
<!doctype html><html lang="en"><head><meta charset="utf-8"><title>About</title><meta name="viewport" content="width=device-width,initial-scale=1"><link rel="stylesheet" href="/_assets/css/global.css"></head><body>
<header><h1>About</h1></header>
<main class="container"><p>Family-run kitchen serving wood-fired classics with fresh, local ingredients.</p></main>
<script src="/_assets/js/gh-pages-shim.js"></script></body></html>
HTML

cat > docs/contact/index.html <<'HTML'
<!doctype html><html lang="en"><head><meta charset="utf-8"><title>Contact</title><meta name="viewport" content="width=device-width,initial-scale=1"><link rel="stylesheet" href="/_assets/css/global.css"></head><body>
<header><h1>Contact</h1></header>
<main class="container">
  <ul>
    <li>Phone: <a href="tel:+15555550123">+1 (555) 555-0123</a></li>
    <li>Email: <a href="mailto:hello@example.com">hello@example.com</a></li>
  </ul>
</main>
<script src="/_assets/js/gh-pages-shim.js"></script></body></html>
HTML

# C) Update nav text/links across all pages (best-effort)
find docs -type f -name "*.html" -print0 | xargs -0 sed -i -E \
 -e 's|>Teachings<|>Menu<|g; s|/teachings/|/menu/|g' \
 -e 's|>Speaking<|>Reservations<|g; s|/speaking/|/reservations/|g' \
 -e 's|>Media<|>Gallery<|g; s|/media/|/gallery/|g' \
 -e 's|>Prayer<|>Location<|g; s|/prayer/|/location/|g' \
 -e 's|>Support<|>Hours<|g; s|/support/|/hours/|g' \
 -e 's|>About Us<|>About<|g'

# D) Warmer color palette (only if CSS vars exist)
if grep -q -- '--brand' docs/_assets/css/global.css 2>/dev/null; then
  sed -i -E 's|(--brand:\s*)#[0-9a-fA-F]{3,6};|\1#c0392b;|; s|(--brand-2:\s*)#[0-9a-fA-F]{3,6};|\1#f39c12;|' docs/_assets/css/global.css || true
fi

# E) Add Restaurant schema to homepage (once)
if ! grep -q '"@type": "Restaurant"' docs/index.html 2>/dev/null; then
cat >> docs/index.html <<JSONLD

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Restaurant",
  "name": "${TITLE}",
  "address": { "@type": "PostalAddress", "addressLocality": "${CITY}" },
  "telephone": "${PHONE}",
  "servesCuisine": ["Pizza","Italian","Grill"]
}
</script>
JSONLD
fi

# F) Commit & push
git add -A
git commit -m "Rebrand to restaurant: pages, nav, theme, schema"
git push
