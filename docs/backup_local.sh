#!/usr/bin/env bash
set -euo pipefail

# --- config ---
SRC="$PWD"                               # current repo (run from repo root)
DEST_DIR="$HOME/LocalBackups"            # where backups live
MIRROR="$DEST_DIR/goldenmaster2.git"     # bare mirror repo path
KEEP_BUNDLES=10                          # how many bundles to retain
REPO_NAME="$(basename "$SRC")"
TS="$(date +%Y%m%d-%H%M%S)"
BUNDLE="$DEST_DIR/${REPO_NAME}-${TS}.bundle"
CHECKSUM="$BUNDLE.sha256"

echo "==> Backing up: $SRC"
mkdir -p "$DEST_DIR"

# 1) Ensure this is a git repo
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "❌ Not inside a git repo. Run this from the repo root."
  exit 1
fi

# 2) Update mirror (or create it if missing)
if [ -d "$MIRROR" ]; then
  echo "=> Updating mirror at $MIRROR"
  git fetch --all --prune
  git push --mirror "$MIRROR"
else
  echo "=> Creating mirror at $MIRROR"
  git clone --mirror "$SRC" "$MIRROR"
fi

# 3) Create a portable bundle of all refs
echo "=> Creating bundle $BUNDLE"
git bundle create "$BUNDLE" --all

# 4) Write checksum for integrity
echo "=> Writing checksum $CHECKSUM"
sha256sum "$BUNDLE" > "$CHECKSUM"

# 5) Prune old bundles (keep latest $KEEP_BUNDLES)
echo "=> Pruning old bundles (keeping $KEEP_BUNDLES)"
ls -1t "$DEST_DIR"/${REPO_NAME}-*.bundle 2>/dev/null | tail -n +$((KEEP_BUNDLES+1)) | while read -r old; do
  [ -f "$old" ] && rm -f "$old" "$old.sha256"
done

echo "✅ Backup complete."
echo "   Mirror:   $MIRROR"
echo "   Bundle:   $BUNDLE"
echo "   Checksum: $CHECKSUM"
