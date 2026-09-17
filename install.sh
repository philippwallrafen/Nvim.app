#!/bin/sh
set -eu

ROOT="$(cd "$(dirname "$0")" && pwd)"
APP="/Applications/Nvim.app"

"$ROOT/build.sh"

sudo rm -rf "$APP"
sudo ditto "$ROOT/dist/Nvim.app" "$APP"

sudo codesign \
  --force \
  --deep \
  --sign - \
  "$APP"

sudo touch "$APP"

mdimport "$APP"

/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister \
  -f "$APP"

killall Finder 2>/dev/null || true
killall Dock 2>/dev/null || true

echo
echo "Installed:"
echo "  $APP"
