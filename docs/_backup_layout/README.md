# Master Template (Static, GitHub Pages safe)

This template avoids broken images and nav links by using **relative URLs** everywhere. It works locally (with VS Code Live Server) and when deployed to GitHub Pages — whether your site is at the **root** (username.github.io) or a **subpath** (username.github.io/repo).

## Folder structure
```
/
  index.html
  /about/index.html
  /teachings/index.html
  /speaking/index.html
  /media/index.html
  /prayer/index.html
  /support/index.html
  /policies/privacy.html
  /_assets/css/global.css
  /_assets/js/site.js
  /_assets/img/hero.svg
```

## Why things used to break
- **Root-relative paths** like `/images/hero.jpg` only work at a domain **root**. On GitHub Pages subpaths they point to the wrong place.
- **Copying between repos** changed the GitHub Pages base URL, so absolute links broke.
- **Smart quotes** and Word/Writer formatting mangled HTML/JS.
- **Case-sensitive filenames** on Linux caused 404s (`Hero.jpg` vs `hero.jpg`).

## How this fixes it
- Uses **relative paths** (`./_assets/...` or `../_assets/...`) that survive moves and subpaths.
- Each subpage is in its own folder with an `index.html` and links that step back with `..` once.
- Minimal CSS/JS and no build step; copy-paste to start a new site.

## Local preview
1. Open folder in VS Code.
2. Install the "Live Server" extension.
3. Open `index.html` and click "Go Live".

## Deploy to GitHub Pages (subpath-safe)
1. Create a new repo on GitHub (e.g., `church-website`).
2. Initialize and push:
   ```bash
   git init
   git add .
   git commit -m "Initial commit from master template"
   git branch -M main
   git remote add origin https://github.com/<you>/<repo>.git
   git push -u origin main
   ```
3. In GitHub → Settings → Pages → **Build and deployment**: Source: **Deploy from a branch**, Branch: **main / root**.
4. Wait for Pages to publish; your URL will be `https://<you>.github.io/<repo>/`.

## Creating a new site from the master
- Duplicate the folder on disk and rename.
- Replace titles and content.
- Keep the same folder structure and relative links.

## Common pitfalls checklist
- [ ] Filenames exactly match in case: `hero.svg` vs `Hero.svg`.
- [ ] All links/images are relative: `./`, `../` (no leading `/`).
- [ ] `index.html` present in each section folder.
- [ ] Tested locally with Live Server before pushing.
- [ ] After publish, verify nav highlights and open devtools console for any missing asset warnings.

## Swapping the hero image
Replace `_assets/img/hero.svg` with your own image and keep the same filename **or** update the `<img>` paths accordingly.
