tell application "Firefox Nightly"
	activate
	tell application "System Events"
		tell process "firefox"
			click menu item "New Tab" of menu "File" of menu bar 1
		end tell
	end tell
end tell