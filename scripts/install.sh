#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="${MOTE_APP_DESTINATION:-/Applications/Mote.app}"
WORKSPACE="${MOTE_WORKSPACE_DESTINATION:-$HOME/.mote/workspaces/ax}"
BUN="${MOTE_BUN:-$(command -v bun || true)}"

if [[ -z "$BUN" ]]; then
  echo "Bun is required for the editable Svelte runtime: https://bun.sh" >&2
  exit 1
fi

cd "$ROOT/app"
swift build -c release
BIN="$(swift build -c release --show-bin-path)/Mote"

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN" "$APP/Contents/MacOS/Mote"
cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleName</key><string>Mote</string>
  <key>CFBundleDisplayName</key><string>Mote</string>
  <key>CFBundleIdentifier</key><string>dev.coey.mote</string>
  <key>CFBundleExecutable</key><string>Mote</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>0.1.0</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>LSMinimumSystemVersion</key><string>14.0</string>
  <key>LSUIElement</key><true/>
  <key>NSHighResolutionCapable</key><true/>
</dict></plist>
PLIST

mkdir -p "$WORKSPACE"
rsync -a --delete --exclude node_modules --exclude dist "$ROOT/workspace/" "$WORKSPACE/"
cd "$WORKSPACE"
"$BUN" install --frozen-lockfile

codesign --force --deep --sign - "$APP" >/dev/null
xattr -dr com.apple.quarantine "$APP" 2>/dev/null || true

echo "Installed Mote.app at $APP"
echo "Editable surface: $WORKSPACE"
echo "Open with: open '$APP'"
