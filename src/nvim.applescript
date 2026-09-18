on run
    my launchNvim({})
end run

on open openedItems
    my launchNvim(openedItems)
end open

on launchNvim(openedItems)
    set nvimCommand to "exec nvim"

    if (count of openedItems) > 0 then
        set quotedArgs to {}

        repeat with openedItem in openedItems
            set filePath to POSIX path of openedItem
            set end of quotedArgs to quoted form of filePath
        end repeat

        set oldDelimiters to AppleScript's text item delimiters
        set AppleScript's text item delimiters to " "
        set argString to quotedArgs as text
        set AppleScript's text item delimiters to oldDelimiters

        set nvimCommand to nvimCommand & " -- " & argString
    end if

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
end launchNvim
