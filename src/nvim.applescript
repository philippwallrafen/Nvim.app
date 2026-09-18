on run
    my launchNvim({})
end run

on open openedItems
    my launchNvim(openedItems)
end open

on launchNvim(openedItems)
    set nvimCommand to my buildNvimCommand(openedItems)

    if my isItermInstalled() then
        my runBackend("iterm.applescript", nvimCommand)
    else
        my runBackend("terminal.applescript", nvimCommand)
    end if
end launchNvim

on buildNvimCommand(openedItems)
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

    return nvimCommand
end buildNvimCommand

on isItermInstalled()
    try
        set itermPath to do shell script "/usr/bin/mdfind 'kMDItemCFBundleIdentifier == \"com.googlecode.iterm2\"' | /usr/bin/head -n 1"
        return itermPath is not ""
    on error
        return false
    end try
end isItermInstalled

on runBackend(resourceName, nvimCommand)
    set backendFile to path to resource resourceName
    set backendSource to read backendFile
    run script backendSource with parameters {nvimCommand}
end runBackend
