set wasRunning to application "iTerm2" is running

tell application "iTerm2"
    launch

    if wasRunning then
        set nvimWindow to (create window with default profile)
    else
        delay 0.5

        if (count of windows) > 0 then
            set nvimWindow to current window
        else
            set nvimWindow to (create window with default profile)
        end if
    end if

    tell current session of nvimWindow
        write text "nvim"
    end tell

    activate
end tell
