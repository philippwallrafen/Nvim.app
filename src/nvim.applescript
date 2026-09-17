tell application "System Events"
    set wasRunning to exists process "iTerm2"
end tell

tell application "iTerm2"
    launch

    if wasRunning then
        create window with default profile command "/bin/zsh -lic 'exec nvim'"
    else
        delay 0.5

        if (count of windows) > 0 then
            tell current session of current window
                write text "exec nvim"
            end tell
        else
            create window with default profile command "/bin/zsh -lic 'exec nvim'"
        end if
    end if

    activate
end tell
