#!/bin/sh
set -eu

ROOT="$(cd "$(dirname "$0")" && pwd)"

"$ROOT/build.sh"

sudo rm -rf /Applications/Nvim.app
sudo ditto "$ROOT/dist/Nvim.app" /Applications/Nvim.app

sudo codesign --force --deep --sign - /Applications/Nvim.app
sudo touch /Applications/Nvim.app

mdimport /Applications/Nvim.app

/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister \
  -f /Applications/Nvim.app

killall Finder 2>/dev/null || true
killall Dock 2>/dev/null || true

echo "Installed /Applications/Nvim.app"
