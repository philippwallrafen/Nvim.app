#!/bin/sh
set -eu

DOMAIN="io.github.philippwallrafen.nvim-app"
TERMINALS="ghostty alacritty tabby kitty iterm2 wezterm rio"

bundle_id() {
    case "$1" in
        ghostty) echo com.mitchellh.ghostty ;;
        alacritty) echo org.alacritty ;;
        tabby) echo org.tabby ;;
        kitty) echo net.kovidgoyal.kitty ;;
        iterm2) echo com.googlecode.iterm2 ;;
        wezterm) echo com.github.wez.wezterm ;;
        rio) echo com.raphaelamorim.rio ;;
        terminal) echo com.apple.Terminal ;;
    esac
}

name() {
    case "$1" in
        ghostty) echo Ghostty ;;
        alacritty) echo Alacritty ;;
        tabby) echo Tabby ;;
        kitty) echo Kitty ;;
        iterm2) echo iTerm2 ;;
        wezterm) echo WezTerm ;;
        rio) echo Rio ;;
        terminal) echo Terminal.app ;;
    esac
}

app_path() {
    /usr/bin/mdfind "kMDItemCFBundleIdentifier == '$(bundle_id "$1")'" |
        /usr/bin/head -n 1
}

installed() {
    [ "$1" = terminal ] || [ -n "$(app_path "$1")" ]
}

app_bin() {
    app="$(app_path "$1")"
    case "$1" in
        ghostty) echo "$app/Contents/MacOS/ghostty" ;;
        alacritty) echo "$app/Contents/MacOS/alacritty" ;;
        tabby) echo "$app/Contents/MacOS/Tabby" ;;
        kitty) echo "$app/Contents/MacOS/kitty" ;;
        wezterm) echo "$app/Contents/MacOS/wezterm" ;;
        rio) echo "$app/Contents/MacOS/rio" ;;
    esac
}

prompt() {
    labels=""
    for t in "$@"; do
        labels="${labels}${labels:+|}$(name "$t")"
    done

    picked="$(NVIM_TERMINALS="$labels" /usr/bin/osascript <<'EOF_AS'
set oldDelimiters to AppleScript's text item delimiters
set AppleScript's text item delimiters to "|"
set choices to text items of (system attribute "NVIM_TERMINALS")
set AppleScript's text item delimiters to oldDelimiters

set picked to choose from list choices with title "Nvim.app" with prompt "Choose a terminal for Nvim.app:" OK button name "Use"
if picked is false then return ""
return item 1 of picked
EOF_AS
)"

    case "$picked" in
        Ghostty) echo ghostty ;;
        Alacritty) echo alacritty ;;
        Tabby) echo tabby ;;
        Kitty) echo kitty ;;
        iTerm2) echo iterm2 ;;
        WezTerm) echo wezterm ;;
        Rio) echo rio ;;
        Terminal.app) echo terminal ;;
    esac
}

choose() {
    saved="$(/usr/bin/defaults read "$DOMAIN" terminal 2>/dev/null || true)"
    case "$saved" in
        ghostty|alacritty|tabby|kitty|iterm2|wezterm|rio|terminal)
            if installed "$saved"; then
                echo "$saved"
                return
            fi
            ;;
    esac

    found=""
    for t in $TERMINALS; do
        installed "$t" && found="${found}${found:+ }$t"
    done

    set -- $found
    case "$#" in
        0) echo terminal ;;
        1) echo "$1" ;;
        *)
            picked="$(prompt "$@" terminal)"
            if [ -n "$picked" ]; then
                /usr/bin/defaults write "$DOMAIN" terminal -string "$picked" >/dev/null
                echo "$picked"
            else
                echo terminal
            fi
            ;;
    esac
}

launch_cli() {
    terminal="$1"
    shift
    exe="$(app_bin "$terminal")"
    /usr/bin/nohup "$exe" "$@" >/dev/null 2>&1 &
}

launch_iterm2() {
    NVIM_COMMAND="$1" /usr/bin/osascript <<'EOF_AS'
set nvimCommand to system attribute "NVIM_COMMAND"
set shellCommand to "/bin/zsh -lic " & quoted form of nvimCommand
set wasRunning to application "iTerm2" is running

tell application "iTerm2"
    launch
    if wasRunning then
        create window with default profile command shellCommand
    else
        delay 0.5
        if (count of windows) > 0 then
            tell current session of current window to write text nvimCommand
        else
            create window with default profile command shellCommand
        end if
    end if
    activate
end tell
EOF_AS
}

launch_terminal() {
    NVIM_COMMAND="$1" /usr/bin/osascript <<'EOF_AS'
set nvimCommand to system attribute "NVIM_COMMAND"
tell application "Terminal"
    activate
    do script nvimCommand
end tell
EOF_AS
}

launch() {
    terminal="$(choose)"
    case "$terminal" in
        ghostty|alacritty|rio)
            launch_cli "$terminal" -e /bin/zsh -lic "$1"
            ;;
        tabby)
            launch_cli tabby run "$1"
            ;;
        kitty)
            launch_cli kitty /bin/zsh -lic "$1"
            ;;
        wezterm)
            launch_cli wezterm start -- /bin/zsh -lic "$1"
            ;;
        iterm2)
            launch_iterm2 "$1"
            ;;
        terminal)
            launch_terminal "$1"
            ;;
    esac
}

preference() {
    case "${1:-show}" in
        show)
            value="$(/usr/bin/defaults read "$DOMAIN" terminal 2>/dev/null || true)"
            case "$value" in
                ghostty|alacritty|tabby|kitty|iterm2|wezterm|rio|terminal) ;;
                *) value=auto ;;
            esac
            echo "Terminal preference: $value"
            ;;
        choose)
            found=""
            for t in $TERMINALS terminal; do
                installed "$t" && found="${found}${found:+ }$t"
            done
            set -- $found
            picked="$(prompt "$@")"
            if [ -n "$picked" ]; then
                /usr/bin/defaults write "$DOMAIN" terminal -string "$picked" >/dev/null
                echo "Terminal preference set to $(name "$picked")."
            fi
            ;;
        auto)
            /usr/bin/defaults delete "$DOMAIN" terminal >/dev/null 2>&1 || true
            echo "Terminal preference set to Auto."
            ;;
        ghostty|alacritty|tabby|kitty|iterm2|wezterm|rio|terminal)
            installed "$1" || { echo "$(name "$1") is not installed." >&2; exit 1; }
            /usr/bin/defaults write "$DOMAIN" terminal -string "$1" >/dev/null
            echo "Terminal preference set to $(name "$1")."
            ;;
        *)
            echo "Expected: show, choose, auto, ghostty, alacritty, tabby, kitty, iterm2, wezterm, rio, terminal" >&2
            exit 2
            ;;
    esac
}

case "${1:-}" in
    launch)
        [ "$#" -eq 2 ] && launch "$2" || {
            echo "Usage: terminal.sh launch <command>" >&2
            exit 2
        }
        ;;
    preference)
        preference "${2:-show}"
        ;;
    *)
        echo "Usage: terminal.sh {launch <command>|preference [choice]}" >&2
        exit 2
        ;;
esac
