on run
    my launchNvim({})
end run

on open openedItems
    my launchNvim(openedItems)
end open

on launchNvim(openedItems)
    set nvimCommand to "exec nvim"

    if (count of openedItems) > 0 then
        set args to {}

        repeat with openedItem in openedItems
            set end of args to quoted form of POSIX path of openedItem
        end repeat

        set oldDelimiters to AppleScript's text item delimiters
        set AppleScript's text item delimiters to " "
        set argString to args as text
        set AppleScript's text item delimiters to oldDelimiters

        set nvimCommand to nvimCommand & " -- " & argString
    end if

    set launcher to POSIX path of (path to resource "terminal.sh")
    do shell script "/bin/sh " & quoted form of launcher & " launch " & quoted form of nvimCommand
end launchNvim
