on run argv
    if (count of argv) is 0 then error "Missing Neovim command"

    set nvimCommand to item 1 of argv

    tell application "Terminal"
        activate
        do script nvimCommand
    end tell
end run
