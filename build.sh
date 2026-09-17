#!/bin/sh
set -eu

ROOT="$(cd "$(dirname "$0")" && pwd)"
DIST="$ROOT/dist"
APP="$DIST/Nvim.app"

rm -rf "$DIST"
mkdir -p "$DIST"

osacompile \
  -o "$APP" \
  "$ROOT/src/nvim.applescript"

cp "$ROOT/assets/Nvim.icns" \
  "$APP/Contents/Resources/Nvim.icns"

rm -f \
  "$APP/Contents/Resources/applet.icns" \
  "$APP/Contents/Resources/Assets.car"

/usr/libexec/PlistBuddy \
  -c "Delete :CFBundleIconFile" \
  "$APP/Contents/Info.plist" 2>/dev/null || true

/usr/libexec/PlistBuddy \
  -c "Add :CFBundleIconFile string Nvim" \
  "$APP/Contents/Info.plist"

codesign --force --deep --sign - "$APP"

ditto \
  -c -k \
  --sequesterRsrc \
  --keepParent \
  "$APP" \
  "$DIST/Nvim.app.zip"

echo "Built:"
echo "  $APP"
echo "  $DIST/Nvim.app.zip"
