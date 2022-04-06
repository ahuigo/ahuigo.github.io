---
title:	shell iterm
priority:
---

# iTerm2
zsh号称终极shell, 配合iTerm2(terminal)会更加的方便. 本小节参考了池建强的[终极shell]

## 导入导出配置

1. If you have a look at `Preferences -> General->Perferences`
2. There is a setting `Load preferences from a custom folder or URL:`. 
3. There is a button next to it `Save settings to Folder`.

## 完美支持readline快捷键
mac 原生应用支持部分主要的readline 快捷键。

如果想全局完美支持readline, 参考 mac/keyboard.md, 可以实现各种app(包括iterm2, chrome, 其它系统应用，原生应用）**全局的readline 快捷键**:
1. `Ctrl+U` 删除光标到行首的所有字符
1. `Ctrl+w` 删除光标后一个word
1. `Ctrl+d` 删除光标前一个char

## 新建tab时默认打开当前的工作区
打开配置项，然后按以下路径操作：

    profiles -> General -> Working Directory


## window(tabs/panes) 快捷键
一个window 由多个tab 组成，一个tab 由多个pane 组成

	Cmd-W close current tab
	cmd-Num	Goto tab No. as Num.
	cmd-shift-[/] switch tab
	Cmd-Shift-Left/Right Reorder current tab.

	Cmd-Alt-E View all tab
    Cmd+enter Full Screen

## Pane

	Cmd-D opens a new vertical pane with the default bookmark.
	cmd-opt-left/right switch panes
	Cmd-Shift-D opens a new horizonal pane with the default bookmark.(横向)

## Navigation Shortcuts
Navigation Shortcuts 可用激活 window,tab, pane

    window
        Alt+Cmd+Number      
    tab
        Cmd+Number      
    pane
        Ctrl+Number

Note: `Ctrl+Number` 会与系统keyboard/shortcuts 中Mission Control 的Switch to Desktop 冲突，所以要删除系统的`Ctrl+1/2/3`或替换成为

## Find & Paste

	查找和粘贴：command+f，呼出查找功能，tab 键选中找到的文本，option+enter 粘贴
	粘贴历史：shift+command+h
	光标去哪了？command+/

## 自动完成

    自动完成：command+; 根据上下文呼出自动完成窗口，上下键选择
    回放功能：option+command+b
    Expose Tabs：Option+Command+E

## 链接

	在链接上按住cmd+单击 直接打开url

## Click打开app关联的file:linenum 和 url
这个特性可以帮助，我们点击`filename:linenum` 打开vscode, goland等app

配置路径：
1. `Profiles` - `Advanced` - `semantic history`
2. 选择`Open with default app`或其它

# vscode
## copy on select
1. Go to settings (⌘,)
2. Search for `terminal.integrated.copyOnSelection`
2. Check the checkmark

