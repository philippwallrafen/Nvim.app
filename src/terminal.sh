#!/bin/sh
set -eu

DOMAIN="io.github.philippwallrafen.nvim-app"

id() {
    case "$1" in
        ghostty) echo com.mitchellh.ghostty ;;
        iterm2) echo com.googlecode.iterm2 ;;
        warp) echo dev.warp.Warp-Stable ;;
        alacritty) echo org.alacritty ;;
        terminal) echo com.apple.Terminal ;;
    esac
}

name() {
    case "$1" in
        ghostty) echo Ghostty ;;
        iterm2) echo iTerm2 ;;
        warp) echo Warp ;;
        alacritty) echo Alacritty ;;
        terminal) echo Terminal.app ;;
    esac
}

installed() {
    [ "$1" = terminal ] ||
        /usr/bin/mdfind "kMDItemCFBundleIdentifier == '$(id "$1")'" | /usr/bin/grep -q .
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
        iTerm2) echo iterm2 ;;
        Warp) echo warp ;;
        Alacritty) echo alacritty ;;
        Terminal.app) echo terminal ;;
    esac
}

choose() {
    saved="$(/usr/bin/defaults read "$DOMAIN" terminal 2>/dev/null || true)"
    case "$saved" in
        ghostty|iterm2|warp|alacritty|terminal)
            if installed "$saved"; then
                echo "$saved"
                return
            fi
            ;;
    esac

    found=""
    for t in ghostty iterm2 warp alacritty; do
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

launch_warp() {
    dir="$(/usr/bin/mktemp -d "${TMPDIR:-/tmp}/nvim-app.XXXXXX")"
    printf '%s' "$1" > "$dir/command"

    cat > "$dir/run.command" <<'EOF_COMMAND'
#!/bin/zsh
dir="$(cd "$(dirname "$0")" && pwd)"
command="$(cat "$dir/command")"
rm -f -- "$dir/command" "$0"
rmdir "$dir" 2>/dev/null || true
exec /bin/zsh -lic "$command"
EOF_COMMAND

    /bin/chmod 700 "$dir/run.command"
    /usr/bin/open -b "$(id warp)" "$dir/run.command"
}

launch() {
    terminal="$(choose)"
    case "$terminal" in
        ghostty) /usr/bin/open -n -a Ghostty --args -e /bin/zsh -lic "$1" ;;
        alacritty) /usr/bin/open -n -a Alacritty --args -e /bin/zsh -lic "$1" ;;
        iterm2) launch_iterm2 "$1" ;;
        warp) launch_warp "$1" ;;
        terminal)
            NVIM_COMMAND="$1" /usr/bin/osascript <<'EOF_AS'
set nvimCommand to system attribute "NVIM_COMMAND"
tell application "Terminal"
    activate
    do script nvimCommand
end tell
EOF_AS
            ;;
    esac
}

preference() {
    case "${1:-show}" in
        show)
            value="$(/usr/bin/defaults read "$DOMAIN" terminal 2>/dev/null || echo auto)"
            echo "Terminal preference: $value"
            ;;
        choose)
            found=""
            for t in ghostty iterm2 warp alacritty terminal; do
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
        ghostty|iterm2|warp|alacritty|terminal)
            installed "$1" || { echo "$(name "$1") is not installed." >&2; exit 1; }
            /usr/bin/defaults write "$DOMAIN" terminal -string "$1" >/dev/null
            echo "Terminal preference set to $(name "$1")."
            ;;
        *)
            echo "Expected: show, choose, auto, ghostty, iterm2, warp, alacritty, terminal" >&2
            exit 2
            ;;
    esac
}

case "${1:-}" in
    launch) [ "$#" -eq 2 ] && launch "$2" || { echo "Usage: terminal.sh launch <command>" >&2; exit 2; } ;;
    preference) preference "${2:-show}" ;;
    *) echo "Usage: terminal.sh {launch <command>|preference [choice]}" >&2; exit 2 ;;
esac
