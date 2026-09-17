#!/bin/sh
set -eu

ROOT="$(cd "$(dirname "$0")" && pwd)"
DIST="$ROOT/dist"
APP="$DIST/Nvim.app"
VERSION="$(cat "$ROOT/VERSION")"
APP_ID="io.github.philippwallrafen.nvim-iterm2-app"

set_string() {
  key="$1"
  value="$2"
  plist="$APP/Contents/Info.plist"

  /usr/libexec/PlistBuddy \
    -c "Set :$key $value" \
    "$plist" 2>/dev/null ||
  /usr/libexec/PlistBuddy \
    -c "Add :$key string $value" \
    "$plist"
}

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

set_string CFBundleIdentifier "$APP_ID"
set_string CFBundleName "Nvim"
set_string CFBundleDisplayName "Nvim"
set_string CFBundleShortVersionString "$VERSION"
set_string CFBundleVersion "$VERSION"
set_string CFBundleIconFile "Nvim"
set_string NSAppleEventsUsageDescription \
  "Nvim uses Apple Events to open Neovim in iTerm2."

/usr/libexec/PlistBuddy \
  -c "Delete :CFBundleIconName" \
  "$APP/Contents/Info.plist" 2>/dev/null || true

plutil -lint "$APP/Contents/Info.plist"

codesign \
  --force \
  --deep \
  --sign - \
  "$APP"

codesign \
  --verify \
  --deep \
  --strict \
  "$APP"

ditto \
  -c \
  -k \
  --sequesterRsrc \
  --keepParent \
  "$APP" \
  "$DIST/Nvim.app.zip"

echo
echo "Built:"
echo "  $APP"
echo "  $DIST/Nvim.app.zip"
