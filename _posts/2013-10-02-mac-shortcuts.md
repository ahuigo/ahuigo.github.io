---
layout: page
title:  Mac shortcuts
category: blog
description:
---

# Preface
本文是mac 快捷键使用整理

# Karabiner + Seil
http://popozhu.github.io/2016/01/31/karabiner%E5%AE%9A%E5%88%B6%E5%85%A8%E9%94%AE%E7%9B%98/
一开始是左手手指有点酸，估计是尾指按键盘左边的Ctrl键次数有点多，为此把左边的Ctrl键盘跟CapsLock对换了一下，这样用了有一年，使用的软件是karabiner和它的一个组件Seil，之所以需要Seil，Karabiner说是CapsLock键的替换（重新映射）需要特殊处理，偶尔还会在 OSX 系统升级后出现映射失效，需要等待作者来做软件升级。

有这个工具，键盘的所有按键都可以重新定义功能，比方说没有用的eject（12前Pro款都拥有的退出光盘按键）键可以改成「往前删除」。
我用这个工具完成以下改造，习惯以后工作效率提升40%以上：
caps lock 被我换成了 backspace ，删除打错的字，右手不用离开键盘，左手小指动一动就好了，键程明显缩小，效率大大提升；
习惯 vi 的人还有个特别蛋疼的地方，就是退出编辑模式需要按esc，我把右边的 shift 改成了 esc，键程也明显缩小；
fn+j/k/h/l 全局仿 vim 模式，分别是上下左右，无论在哪里都可以用，即使我刚刚在回答知乎的这个问题也在用，不用右手挪到右下角去按方向键，方便很多；
另外一些 vim 模式的按键映射。

作者：王俊森
链接：https://www.zhihu.com/question/19550256/answer/47709159

# Off Screen Window
How to Move an Off Screen Window Back Onto the Active Mac Screen in OS X
http://osxdaily.com/2013/08/14/move-window-back-on-screen-mac-os-x/

1. Try to choose “Zoom"
2. Try ^+command+z

XQuartz windows lost off-screen in OSX, especially with multiple displays and spaces
http://blog.appsocial.ly/post/98167598243/xquartz-windows-lost-off-screen-in-osx-especially


# 按键符号

	⇞	Pageup (Fn + UP)	U+21DE (air下用Fn+Up代替)
	⇟	Pagedown(Fn + Down)	U+21DF (air下用Fn+Down代替)
	↑
	⇡	Up arrow	U+2191
	↓
	⇣	Down arrow	U+2193
	⇱
	↖
	↸	Home	U+21F1 (air 使用Fn+Left)
	⇲
	↘	End	U+21F2 U+2198 (air 下用Fn+Right 代替)
	←	Left arrow	U+2190
	→	Right arrow	U+2192

	⌧	Clear	U+2327
	⇭	Numberlock	U+21ED
	⌤	Enter	U+2324
	⏏	Eject	U+23CF
	⌽	Power 3	U+233D
	⎋	Escape	U+238B
		Apple symbol 1	U+F8FF
	⌃	Control key
	⌥	Option key
	⇧	Shift Key
	⇪	Caps Lock
	Fn	Function Key
	⇥	Tab forward	U+21E5
	⇤	Tab back	U+21E4
	⇪	Capslock	U+21EA
	⇧	Shift	U+21E7
	⌃	Control	U+2303
	⌥	Option (Alt, Alternative)	U+2325
	⌘	Command (Open Apple) 2	U+2318
	␣	Space	U+2423
	⏎
	↩	Return	U+23CE
	⌫	Delete back	U+232B
	⌦	Delete forward	U+2326
	﹖⃝	Help	U+003F & U+20DD

map:

	Insert: fn+return
	Alt+Insert: fn + alt/option + return

# Alfred2.0
如果需要以下功能
- 更方便快捷的打开任意程序，
- 更方便的计算器
- 更方便打开url
- 更方便的查单词
- 更方便的打开常用文件
- 定制自己的搜索
- 一键shell

那么，千万别错过alfred2.0, 看看池建强的[alfred2.0 使用](http://www.zhihu.com/question/20656680)

# BetterTouchTool
http://sspai.com/27094

# App
	⌘ +,	Setting
	⌘ +i	App Info
	⌘ +?	Help
	⌘ +n	New Tab
	⌘ +o	Open File
	⌘ +<num>	Switch Tab
	按住ctrl+单击 弹出右键菜单.
	<F5> get suggestions while typing.
	⌘ + click on a dock icon takes you to the respective app in /applications
	⌥ +<function> will bring up the System Preference panel for that key. Here's a list:

		⌥ +Brightness: Displays
		⌥ +Exposé/Dashboard: Exposé and Spaces
		⌥ +Mute/Volume: Sound
		⌥ +Keyboard Brightness: Keyboard (for Macs with backlit keyboards)

	Remember that if you have checked the option to use F1, F2, etc. keys as standard function keys, done in System Preferences>Keyboard, then you will need to add the fn to the afore mentioned sequences.


# Edit

	ctrl+p shell中上一个命令,或者 文本中移动到上一行
	ctrl+n shell中下一个命令,或者 文本中移动到下一行
	ctrl+r 往后搜索历史命令
	ctrl+s 往前搜索历史命令
	ctrl+f 光标前移
	ctrl+b 光标后退
	ctrl+a 到行首
	ctrl+e 到行尾
	ctrl+d 删除一个字符,删除一个字符，相当于通常的Delete键
	ctrl+h 退格删除一个字符,相当于通常的Backspace键
	ctrl+u 删除到行首
	ctrl+k 删除到行尾
	ctrl+l 类似 clear 命令效果
	ctrl+y 粘贴(粘贴的是ctrl+k ctrl+u所删除的字符串)
	Alt+Del Delete a word
	Alt+Left/Right Move cursor step by word
	Shift+Alt+Left/Right Select  by word
	Fn+Del	Backspace
	Ctrl+Left/Right Move cursor to Head/End of line

## Action
	⌘ +C/V		Copy/Paste
	⌘ +P		Print
	⌘ +S		Save
	⇧ +⌘ +S		Save As
	⌘ +Z		Undo/Redo
	⌘ +O		Open
	⌘ +Del		Selects "Don't Save" in dialogs that contain a Don't Save button, in OS X Lion and Mountain Lion
	⌥ +⌘ +F	Move to the search field control
	⌘ +G		Find The Next occurence of the Selection
	⇧ +⌘ +G		Find The Previous occurence of the Selection
	⌘ +Click		Right Button Menu
	⌘ +[/]		Backward/Forward
	⌘ +Left/Right		Backward/Forward(When Input Method Unactived )
	⌘ +Left/Right		Move Cursor To Line Head/End(When Input Method Actived )
	⌥ +Left/Right		Move Cursor By Word(Input Method)
	⌘ +F		Search
	⌘ +A		Select All (Alt+Cmd+A undo in Finder)

## Format

### Font
	⌘ +B 		Toggle Boldface the Selected Text
	⌘ +I	Italicize the selected text or toggle italic text on or off
	⌘ +T	Display the Fonts window
	⌘ +U	Underline the selected text or turn underlining on or off

### Style

	⌥ +⌘ +C/V Copy/Apply the Style of Selected Text
	⇧ +⌥ +⌘ +V	Apply the style of the surrounding text to the inserted object (Paste and Match Style)
	Ctrl-⌘ +C/V	Copy/Apply the formatting settings of the selected item and store on the Clipboard

### Color
	⇧ +⌘ +C	Display Color Window

## Cursor Move

### By Page
	⌘ +Up/Down	Home/End
	Control-V	Move Down one Page
	Fn-Up/Down	Move Up/Down one Page

### By Line
	Control-A/E 	Move to Beginning/End
	Control-P/N		Move to Previous/Next Line

### By Word
	⌥ +Left/Right

### By Character
	Left/Right
	Control-B/F		Move one character backward/forward

### By Area
	Control-L		Center the cursor

## Delete

### By Line
	Control-U/K Delete the Char Behind/In_front of the cursor.

### By Word

	Control-W	Delete One Word Behind the cursor
	⌥ +Del		Delete One Word Behind the cursor
### By Character

	Control-H/D	Delete one Char Backward/Forward
	Fn-Del		Forward delete

## Insert
	Control-O	Insert a new line after the cursor
	Control-T	Transpose the character behind the cursor and the character in front of the cursor

# Dictionary
	Ctrl-⌘ +D	Display the definition of the selected word in the Dictionary application


# Window & App

## Desktop
	Control-Left/Right	Switch between Full apps
	Control-Up/Down		Switch Mission Control(Also U could )
	⌥ +⌘ +D			Show/Hide Dock

## Window & Function
	⌘ +M		Minimize Windows
	⇧ +⌘ +F Full Screen
	⌥ +⌘ +M	Minimize All Windows
	⌘ +H		Hide Current Window
	⌘ +⌥ +H	Hide Other Window
	F11			Hidden All Windows
	F12			Show/Hidden Dashboard
	⌘ +N		New Window
	⌘ +T		New Tab
	⌘ +W		Close Tab or the frontmost Window
	⇧ +⌘ +W	Close a file and its associated Windows
	⌥ +⌘ +W	Close All Windows in the app without quit it
	⌘ +Q		Quit App
	⌘ +Tab		Move forward to next most recently application in a list open application
	⌘ +Tab(Then Press Opt)		Move forward to next most recently application in a list open application(maxmized application)
	⌘ +:		Display spelling Window
	⌘ +?		Open Help
	⌥ +⌘ +I	Display an inspector window

## Action

	⌘ +,		Preference
	⌘ +`		Acitvate the next open window in the frontmost application
	⌘ +Tab		Switch app-cycle forward
	⌘ +M		Minimize Window
	⌘ ++/-		Increase/Decrease the size of the selected item
	⌘ +0		Normal Size(in Chrome)
	⌘ +{/} 	Left/Right-align a selection
	⌥ +⌘ +Left/Right 	Left/Right-align a selection
	⌘ +| 		Center-align a selection

## Toolbar
	⌥ +⌘ +T	Show/Hide Toolbar

## Capture

	Shift+⌘ +3 Capture the screen to a file
	Ctrl-Shift+⌘ +3 Capture the screen to a Clipboard
	Shift+⌘ +4 Capture a selection to a file
	Ctrl-Shift+⌘ +4 Capture a selection to a Clipboard

With `space` to move region.

## dock

	⌥ +⌘ +D		Hide Dock Toggle

# Chrome

	⌘ + click  	在后台以新标签打开(Unactived)
	⇧ +⌘ +T 	Reopen last closed tab
	⇧ +⌘ +B 	Show Bookbar
	⌘ + Shift + click  以新标签打开(Actived)
	⌘ +L 		Highlight address bar
	⌘ +1/2/3/...9		Go to tab 1/2/3...9
	⌘ +0		Normal Size(in Chrome)
	⇧ +⌘ +N		Incognito(Chrome)
	⌘ +{/}		Previous/Next Tab
	⌥ +⌘ +Left/Right		Previous/Next Tab
	⌥ +⌘ +I 	Developer Tools
	⌥ +⌘ +U 	View Source
	⌥ +⌘ +J 	JS Console
	⌥ +⌘ +C 	Select an element to inspect it
	⌥ +⌘ +B 	Bookbar Manager

## Text

	⌥ +⌘ +C	Copy url to Clipboard
	⇧ +⌥ +⌘ +V	Paste without format

# Terminal

	⌘ +{/}		Previous/Next Tab
	⇧ +⌘ +Left/Right	Previous/Next Tab

# Finder

## copy path

	cmd+c in finder
	cmd+v in termial

## Action

	⌘ +T		Add to Sidebar(New Tab)
	⌥ +⌘ +While-dragging Make alias of dragged item
	⇧ +⌘ +N		New Folder(finder)
	⌘ +Del		Move to Trash
	⇧ +⌘ +Del		Empty Trash
	⇧ +⌥ +⌘ +Del		Empty Trash without confirmation dialog

## Goto
	⌘ +R		Show Original(Of alias)
	⇧ +⌘ +G		Go To Dirtory
	⌘ +Double_click Open a folder in separate window
	⌘ +Click_the_window_title	See ther folders that contain current window
	⌘ +Up		Open parent folder
	⌘ +Down		Open parent folder
	Control-⌘ +Up		Opend parent folder in new Window

	⌘ +[/]	Previous/Later Dirctory

	⌥ +⌘ +N		New Smart Folder
	⌥ +⌘ +F		Search File By FileName and Contents within Current Window
	⇧ +⌘ +T		Add to favorites
	⇧ +⌘ +H/A/U/D		Home/Applications/Uitilities/Desktop
	⇧ +⌘ +C		Computer
	⇧ +⌘ +O		Documents
	⇧ +⌘ +K		Network
	⇧ +⌘ +F		All Files
	⌥ +⌘ +L		Downloads

### Goto Server
	⌘ +K		Connect To Server(ftp)

## Select
	⌥ +⌘ +A		Undo Select in Finder

## Copy(Cut) & paste

	#copy file
	⌘ +C #copy
	⌘ +V #paste

	#cut file
	⌘ +C #cut
	⌥ +⌘ +V #paste

	⌘ +drag	copy file
	⌥ +drage	cut file
	⌘ +D		Create Copy
	⌥ +While-dragging Create Copy
	⌘ +L		Make alias of the selected item //

## View
	⌘ +1/2/3/4		View as icon/list/columns/CoverFlow
	Space or ⌘ +Y	Quick Look
	⌥ +⌘ +Y		Slideshow selected item
	⌘ +I		Show Info(focused)
	⌥ +⌘ +I		Show Info(unfocued)
	⌘ +J		Show View Options
	⌥ +⌘ +T		Hide/Show toolbar in window

## Open
	⌘ +O		Open file


# System

	⇧ +⌘ +Q		Log out
	⌥ +⌘ +⏏ /Power		Sleep
	Ctrl-⌘ +⏏ /Power		Restart
	ctrl + ⌥ + ⌘ + ⏏/Power 	Shuts the computer down
	⇧ + ctrl + ⏏/Power 		send display only to sleep (great for locking your computer instantly)
	⌥ + ⌘ + esc You kill not responding programs (including the Finder)

# QQ
	⌘ +1	Contact list
	⌘ +f	Find contact
	Ctrl+⌘ +s	Open latest unread message
	Ctrl+⌘ +x	Open latest unread message list
	Ctrl+⌘ +z	Open all unread messages
	⌘ +up/down	Select Pre/Next chat

# Input Symbols

	⌥ +K 
	⌥ +R ‰
	⌥ += ≠
	⌥ ++ ±
	⌥ +@ €
	⌥ +2 ™
	⌥ +3 £
	⌥ +5 ∞
	⌥ +6 §
	⌥ +( ·
	⌥ +z Ω
	⌥ +o ø
	⌥ +O Ø
	⌥ +p π
	⌥ +v √
	⌥ +w ∑
	⌥ +b ∫
	⌥ +r ®
	⌥ +g ©
	⌥ +, ≤
	⌥ +. ≥
	⌥ +j ∆
	⌥ +x ≈
	⌥ +m µ
	⌥ +f ƒ

	¶•ªº–≠
	`⁄€‹›ﬁﬂ‡°·‚—±

	œ∑®†¥øπ“‘«
	Œ„´‰ˇÁ¨ˆØ∏”’»

	åß∂ƒ©˙∆˚¬…æ
	ÅÍÎÏ˝ÓÔÒÚÆ

	Ω≈ç√∫∫µ≤≥÷
	¸˛Ç◊ı˜Â¯˘¿

For more details,refer to [Type Symbols](http://www.wikihow.com/Type-Symbols-Using-the-ALT-Key)

# keynote
[keynote](/p/doc-keynote)

# Reference
[The shortcuts on Mac]
[mac hide feature]

[The shortcuts on Mac]: http://support.apple.com/kb/ht1343
[mac hide feature]: http://apple.stackexchange.com/questions/400/please-share-your-hidden-os-x-features-or-tips-and-tricks
