on run argv
    if (count of argv) is 0 then error "Missing Neovim command"

    set nvimCommand to item 1 of argv
    set shellCommand to "/bin/zsh -lic " & quoted form of nvimCommand
    set wasRunning to application "iTerm2" is running

    tell application "iTerm2"
        launch

        if wasRunning then
            create window with default profile command shellCommand
        else
            delay 0.5

            if (count of windows) > 0 then
                tell current session of current window
                    write text nvimCommand
                end tell
            else
                create window with default profile command shellCommand
            end if
        end if

        activate
    end tell
end run
