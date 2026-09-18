#!/bin/sh
set -eu

ROOT="$(cd "$(dirname "$0")" && pwd)"
DIST="$ROOT/dist"
BUILT_APP="$DIST/Nvim.app"
INSTALLED_APP="/Applications/Nvim.app"
ZIP="$DIST/Nvim.app.zip"

VERSION="$(cat "$ROOT/VERSION")"
APP_ID="io.github.philippwallrafen.nvim-app"

set_string() {
    key="$1"
    value="$2"
    plist="$BUILT_APP/Contents/Info.plist"

    /usr/libexec/PlistBuddy \
        -c "Set :$key $value" \
        "$plist" 2>/dev/null ||
    /usr/libexec/PlistBuddy \
        -c "Add :$key string $value" \
        "$plist"
}

set_document_types() {
    plist="$BUILT_APP/Contents/Info.plist"

    /usr/libexec/PlistBuddy \
        -c "Delete :CFBundleDocumentTypes" \
        "$plist" 2>/dev/null || true

    /usr/libexec/PlistBuddy \
        -c "Add :CFBundleDocumentTypes array" \
        -c "Add :CFBundleDocumentTypes:0 dict" \
        -c "Add :CFBundleDocumentTypes:0:CFBundleTypeName string Text" \
        -c "Add :CFBundleDocumentTypes:0:CFBundleTypeRole string Editor" \
        -c "Add :CFBundleDocumentTypes:0:LSHandlerRank string Alternate" \
        -c "Add :CFBundleDocumentTypes:0:LSItemContentTypes array" \
        -c "Add :CFBundleDocumentTypes:0:LSItemContentTypes:0 string public.text" \
        "$plist"
}

build_app() {
    mkdir -p "$DIST"
    rm -rf "$BUILT_APP"

    osacompile \
        -o "$BUILT_APP" \
        "$ROOT/src/nvim.applescript"

    cp \
        "$ROOT/assets/Nvim.icns" \
        "$BUILT_APP/Contents/Resources/Nvim.icns"

    cp \
        "$ROOT/src/terminal.sh" \
        "$BUILT_APP/Contents/Resources/terminal.sh"

    rm -f \
        "$BUILT_APP/Contents/Resources/applet.icns" \
        "$BUILT_APP/Contents/Resources/Assets.car"

    set_string CFBundleIdentifier "$APP_ID"
    set_string CFBundleName "Nvim"
    set_string CFBundleDisplayName "Nvim"
    set_string CFBundleShortVersionString "$VERSION"
    set_string CFBundleVersion "$VERSION"
    set_string CFBundleIconFile "Nvim"
    set_string NSAppleEventsUsageDescription \
        "Nvim uses Apple Events to open Neovim in the selected terminal."

    set_document_types

    /usr/libexec/PlistBuddy \
        -c "Delete :CFBundleIconName" \
        "$BUILT_APP/Contents/Info.plist" 2>/dev/null || true

    plutil -lint "$BUILT_APP/Contents/Info.plist"

    codesign \
        --force \
        --deep \
        --sign - \
        "$BUILT_APP"

    codesign \
        --verify \
        --deep \
        --strict \
        "$BUILT_APP"

    echo
    echo "Built:"
    echo "  $BUILT_APP"
}

install_app() {
    build_app

    sudo rm -rf "$INSTALLED_APP"
    sudo ditto "$BUILT_APP" "$INSTALLED_APP"

    sudo codesign \
        --force \
        --deep \
        --sign - \
        "$INSTALLED_APP"

    sudo touch "$INSTALLED_APP"

    mdimport "$INSTALLED_APP"

    /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister \
        -f "$INSTALLED_APP"

    killall Finder 2>/dev/null || true
    killall Dock 2>/dev/null || true

    echo
    echo "Installed:"
    echo "  $INSTALLED_APP"
}

package_app() {
    build_app

    rm -f "$ZIP"

    ditto \
        -c \
        -k \
        --sequesterRsrc \
        --keepParent \
        "$BUILT_APP" \
        "$ZIP"

    echo
    echo "Packaged:"
    echo "  $ZIP"
}

terminal_preference() {
    /bin/sh "$ROOT/src/terminal.sh" preference "${1:-show}"
}

usage() {
    cat <<'EOF_USAGE'
Usage:
  ./nvim-app.sh build
  ./nvim-app.sh install
  ./nvim-app.sh package
  ./nvim-app.sh terminal [show|choose|auto|ghostty|alacritty|tabby|kitty|iterm2|wezterm|rio|terminal]

Commands:
  build     Build dist/Nvim.app
  install   Build and install Nvim.app to /Applications
  package   Build and create dist/Nvim.app.zip
  terminal  Show or change the preferred terminal
EOF_USAGE
}

case "${1:-}" in
    build)
        build_app
        ;;
    install)
        install_app
        ;;
    package)
        package_app
        ;;
    terminal)
        terminal_preference "${2:-show}"
        ;;
    help|-h|--help|"")
        usage
        ;;
    *)
        echo "Unknown command: $1" >&2
        echo >&2
        usage >&2
        exit 1
        ;;
esac
