tell application "Brave Browser"
	activate
	tell front window to make new tab at after (get active tab)
end tell