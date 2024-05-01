on count_windows_on_current_space(process_name)
    tell application "System Events"
        tell process process_name
            return count of windows
        end tell
    end tell
end count_windows_on_current_space

if application "Alacritty" is running and count_windows_on_current_space("Alacritty") = 0 then
    do shell script "/Applications/Alacritty.app/Contents/MacOS/alacritty msg create-window"
end if
activate application "Alacritty"
