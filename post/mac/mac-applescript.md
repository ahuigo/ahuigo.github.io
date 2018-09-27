---
title: AppleScript
date: 2018-09-27
---
# AppleScript

## shutdown
打开Apple Script Editor，写一个关机命令：

    beep 3

    display dialog "Shut Down Your System?" buttons {"OK", "Cancel"} default button {"OK"} with icon stop

    set dialogResult to result
    set ButtonHit to button returned of dialogResult

    if ButtonHit = "OK" then
    	say "System will be shut down immediately"
    	tell application "System Events"
    		shut down
    	end tell
    end if

然后File-> Export成为Application，这样spotlight就会建立索引，搜索该文件名，系统直接关机！

## Create a launcher app
1. Open AppleScript
Write the following text in editor window:

	tell application "Terminal"
	 do script "`which octave`; exit"
	end tell

2. Select "Save as ..." from the "File" menu
In the menu that appears, select "Application" from the "File format" menu,
then navigate to the "Applications" folder and save your script there as "Octave.app"