---
layout: page
title:	shell 终端使用技巧
category: blog
description:
---
# Preface
本文总结了shell 终端的使用技术: 主要包括Readline 使用，以及zsh 与iTerm2 的使用

# Shortcuts
下面列出的快捷键大部分是通用的，有一小部分快捷键局限于使用环境.

## Readline

    Emacs keys  Action  Scope   Direction/Place
    # Moving around
    Ctrl-b  Move the cursor one character   ⇦ to the left
    Ctrl-f  Move the cursor one character   ⇨ to the right
    Alt-b   Move the cursor one word    ⇦ to the left
    Alt-f   Move the cursor one word    ⇨ to the right
    Ctrl-a  Move the cursor     ⇤ to the start of the line
    Ctrl-e  Move the cursor     ⇥ to the end of the line
    Ctrl-x-x[1] Move the cursor      ⇤⇥ to the start, and to the end again

    # Cut, copy and paste
    Backspace   Delete  the character   ⇦ to the left of the cursor
    DEL
    Ctrl-d  Delete  the character   underneath the cursor
    Ctrl-u  Delete  everything  ⇤ from the cursor back to the line start
    Ctrl-k  Delete  everything  ⇥ from the cursor to the end of the line
    Ctrl-w/Alt-Backspace  Delete  word    ⇦ untill after the previous word boundary
    Alt-d   Delete  word    ⇨ untill before the next word boundary
    Ctrl-y  Yank/Paste  prev. killed text   at the cursor position
    Alt-y   Yank/Paste  prev. prev. killed text at the cursor position

    # History
    Ctrl-p  Move in history one line    ⇧ before this line
    Ctrl-n  Move in history one line    ⇩ after this line
    Alt->   Move in history all the lines   ⇩ to the line currently being entered
    Ctrl-r  Incrementally search the line history   ⇧ backwardly
    Ctrl-s[2]   Incrementally search the line history   ⇩ forwardly
    Ctrl-J  End an incremental search
    Ctrl-G  Abort an incremental search and restore the original line (In zsh: abort current search or current input)
    Ctrl-C  Abort current input (In zsh: abort current search or current input)
    Alt-Ctrl-y  Yank/Paste  arg. 1 of prev. cmnd    at the cursor position
    Alt-.
    Alt-_   Yank/Paste  last arg of prev. cmnd  at the cursor position

    # Undo
    Ctrl-_		Undo the last editing command; you can undo all the way back to an empty line
    Ctrl-x Ctrl-u  Undo the last editing command; you can undo all the way back to an empty line
    Alt-r   Undo all changes made to this line
    Ctrl-l  Clear the screen, reprinting the current line at the top

    # Completion
    TAB Auto-complete a name
    Ctrl-t  Transpose/drag  char. before the cursor ↷ over the character at the cursor

### comment
Comment your command

	alt+#
	ctrl+a # <enter>

### 定位

#### 窗口定位(gnome)

	ALT+NUM #tab 切换(会占用[readline])
	ALT-CTRL-T #新建terminal window

#### 光标定位

	ALT-B/F #按单词移动光标左/右 默认的mata为ESC，所以ESC-B/F也生效的
	CTRL-LEFT/RIGHT #按单词移动光标左/右
	CTRL-B/F #光标左移/右移
	Alt-Mouse Click #通过鼠标点击(iTerminal)

### 编辑

	CTRL-U/K #删除光标前/后所有字符
	CTRL-W(ALT-Backspace)/ALT-D #删除光标前/后一个词　（alt-d　等效esc-d）
	CTRL-H/D #删除光标前/后的一个字符

	CTRL-T #光标所在字符与前面的字符作交换

#### Edit  Cmd Batched

	<Ctrl-x><Ctrl-e> # Open a temporary editor, which is sepeciafied by $EDITOR


### 复制/粘贴(copy & paste)

	CTRL-Y #粘贴所删除内容
	CTRL-_ #撤消动作
	ALT-. #使用上一条命令的最后一个参数

#### gnome-terminal下的复制粘贴:

	SHIFT-CTRL-C/V #复制/粘贴gnome系统剪切板
	SHIFT-CTRL-T #新建tab

### 历史记录

	CTRL-R/S 搜索历史
	ALT-N/P 输入要查找的字符串，然后按上下，或者ALT-N/P

	CTRL-G #退出历史搜索
	CTRL-C #退出历史搜索 并清空当前命令


### 控制命令

	CTRL-L #清屏
	CTRL-O #执行当前命令并选择上一条命令
	CTRL-S/Q #阻止屏幕输出／允许屏幕输出
	CTRL-C #终止命令
	CTRL-Z #挂起命令

### 重复

#### 重复操作
在shell中也有类似vim的num {motion}功能--[readline].也就是用数字指定操作次数.
用法为:

	`MetaKey` + `Count`  Command

其中:

	MetaKey :一般默认的Meta Key是`Alt`,或`Esc`.
	Count:repeat的次数,如果是负数,则是相反的意思
	Command: 可以是字符/快捷键.(如果是数字,以CTRL+V与Count相分隔)

以下是例子:

	`MetaKey`+`12` a #输出12个a
	`MetaKey`+`3` ALT+B #光标左移三个单词
	`MetaKey`+`-3` ALT+B #光标右移三个单词(-负数时,动作取反)
	`MetaKey`+`13` CTRL+V 0 #输出13个0

# History
History 会将`!`(exclamation mark)作为 Expand.

	echo "abc!ls" #会将`!ls` expand

建议使用单引号：

	echo 'abc!'

Or turn off history expandsion

	set +H
	//or
	set +o histexpand

## 事件指示器(Event Designators)


	!!
	echo !!
		The Last command
	!-4
	echo !-4
		The Last 4'th command
	!4
	echo !-4
		The First 4'th command
	!cp
	echo !cp
		Lastly command that start from 'cp'
	!?str
		Lastly command that contains string 'str'

	cd -
	-
		cd into last directory


## 单词指示器(Word Designators)
Usage:

	Event-Designator:Word-Designator

Here is a word designators list:

	0
		The command
	n
		The n'th parameter
	$
		The last parameter
	*
		all parameters(exclude cmd)

For Example:

	!!*
		All parameters(exclude cmd self)
	!$
	!!:$
		Last command's last parameter(seems like `alt-.`, ` $_` )
	!^
	!!:^
		Last command's first parameter
	!!:4
		Last command's 4'th parameters(start from 0)
	!!:-4
		Last command's parameters start from 0 to 4
	!-8:3-4
		Last 8'th command's parameters start from 3 to 4
	!cp:3-4

### Save clipboard to file

	alias save 'pbpaste > \!^ '

And now if you select some text in a window, copy it, and want to save it into a file, type `save file` and there it is. The !^ is a bit of history substitution that means "take the first argument from the last command." In this case, the last command was save and the first argument was the file path entered after.

Also, you can do as the following in case you input bad `save ` command.

	pbpaste > file

## 修饰符(Modifiers)
Modifiers:

	p
		Print
	s/old/new/
		Replace `old` with `new` (only one time)
	g
		Replace all word
		!!:gs/old/new
	&
		Replace last replace
		!!:& (once)
		!!:g& (all)


For example:

	!!:p
	echo !!
		打印上一条命令
	!wget:p
	echo !wget
		打印最近一条以wget打头的命令

Only the cmd start from `!` could be printed, here are some bad usages:

	^old^new:p
	echo ^old^new

## Refer to current cmd

	!#
		Current cmd
	echo ab !#
		same as `echo ab echo`

## Disable history

	export HISTSIZE=0

## Clear history
	history -c

# iTerm2
zsh号称终极shell, 配合iTerm2(terminal)会更加的方便. 本小节参考了池建强的[终极shell]

## open tab
profiles -> General -> Working Directory

## readline
iterm2 下默认option + f/b 不是指向esc+f/b 的，导致这两个快捷键不能按单词移动光标。

所以需要按`Cmd+,`, 然后在keys 中将这两个快捷键绑定到 `esc+f/b`

## window(tabs)

	Cmd-W close current tab
	cmd-Num	Goto tab No. as Num.
	cmd-shift-[/] switch tab
	Cmd-Shift-Left/Right Reorder current tab.

	Cmd-Alt-E View all tab
	 cmd+enter Full Screen

### Pane

	Cmd-D opens a new vertical pane with the default bookmark.
	cmd-opt-left/right switch panes
	Cmd-Shift-D opens a new horizonal pane with the default bookmark.(横向)

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

# zsh


## nocorrect

	unsetopt correct

## Hotkey
If u like for Ctrl+U to be bound to backward-kill-line rather than kill-whole-line, so add this to your `.zshrc`:

    bindkey \^U backward-kill-line

Go back one word in iTerm2?

	bindkey -e
	bindkey '^[[1;9C' forward-word
	bindkey '^[[1;9D' backward-word

Also you can add a shortcuts in `preference -> keys`:

	shortcuts: alt+f
	action: send escape sequence
	ESC+: f

## 光标移动

	Alt+鼠标点点击, 移动到命令行其它位置
    Ctrl+f/b
    Ctrl+u/k
    Ctrl+a/e
    Ctrl+Left/Right: 按单词移动光标
    Ctrl+y #Revert
    Ctrl-Shift-A 选中从光标开始，到一行开头的所有文字
    Ctrl-Shift-E 选中从光标开始，到一行结尾的所有文字

## Globbing

	** recursive

Search file recursively

	* any characters
		rm */*/*.txt

	** recursive
		ls **/*b.md

(Modifiers)

	(@)	Symbolic file
		ls *(@)
	(str1|str2)
		ls **/*.(txt|php)
	(/^F)	empty directory
		rm -d **/*(/^F)
	(Lk+20)
		# Let’s use a modifier again to recursivly find files over 20kb.
		ls **/*(Lk+20)

Refer to [why-zsh](http://code.joejag.com/2014/why-zsh.html)

## Negation
Nearly every globbing pattern can be negated. To match any file not starting with the letters a or b the following pattern can be used:

	ls [^ab]*
	ls ^foo

	ls ^(foo|bar)

## Approximate matching
This is a very useful feature. With approximate matching you find files even if their names contain spelling mistakes such as differing, missing or transposed characters.

	ls (#a1)foobar

matches all files with the name foobar but also files with the names fobar, foobra or foxbar.
The number after the a defines how far the correction goes. A number of 1 corrects up to one mistake. Higher numbers do more correction. But be careful: the more correction you allow, the more false positives you'll get.

## useful alias
	alias | grep cd
	alias | grep git
	ga gst

## o-my-zsh
zsh的配置太复杂, 还好有好心人贡献了一个很好用的配置[o-my-zsh]

Install:

	wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh

## conf

### theme
如果你对theme中的提示符不爽, 可以改PROMPT(在.oh-my-zsh/themes/*). 参考[zsh-conf](https://wiki.archlinux.org/index.php/zsh#Customizing_the_prompt)

### conf files
At login, Zsh sources the following files in this [order](https://wiki.archlinux.org/index.php/zsh):

	~/.zshenv
	This file should contain commands to set the command search path, plus other important environment variables; it should not contain commands that produce output or assume the shell is attached to a tty.
	/etc/profile
	This file is sourced by all Bourne-compatible shells upon login: it sets up an environment upon login and application-specific (/etc/profile.d/*.sh) settings.
	~/.zprofile
	This file is generally used for automatic execution of user's scripts.
	~/.zshrc
	This is Zsh's main configuration file.
	~/.zlogin
	This file is generally used for automatic execution of user's scripts.

## 文件默认打开程序

	alias -s gz='tar -xzvf' #直接在命令行下输入tar文件, 就自动解压了
	alias -s tgz='tar -xzvf'
	alias -s zip='unzip'
	alias -s bz2='tar -xjvf'

## 强大的历史
输入grep 再按上下键, 会查阅所有以grep 打头的历史命令

## autojump 目录跳转
有autojump(j) 和 d 两个命令可方便的实现快速跳转：

	d<CR> #罗列所有访问过的目录 再输入数字<CR> 就直接进入到对应的目录
	-='cd -' #进入到上次的目录
	1='cd -'
	2='cd -2' #进入到上上次目录 默认设置了1~9

	..='cd ..'
	...='cd ../..'

如果开启了autojump 插件:


	j dirname #智能dir跳转, 支持模糊匹配
	j -s ＃显示记录的所有目录
	j -h ＃help

### jump path

	find ~ -name '*autojum*'
	./.local/share/autojump/autojump.txt

## 插件
.oh-my-zsh.sh 有这一行插件配置语句:

	plugins=(git textmate ruby autojump osx mvn gradle)
	brew install autojump #autojump需要安装一下

git插件旋转在`.oh-my-zh/plugins/git/git.plugin.zsh`.

介绍下这几个插件:

1、git：当你处于一个 git 受控的目录下时，Shell 会明确显示 「git」和 branch，如上图所示，另外对 git 很多命令进行了简化，例如 gco=’git checkout’、gd=’git diff’、gst=’git status’、g=’git’等等，熟练使用可以大大减少 git 的命令长度，命令内容可以参考~/.oh-my-zsh/plugins/git/git.plugin.zsh

2、textmate：mr可以创建 ruby 的框架项目，tm finename 可以用 textmate 打开指定文件。

3、osx：tab 增强，quick-look filename 可以直接预览文件，man-preview grep 可以生成 grep手册 的pdf 版本等。

## PROMPT
PROMPT PS1

	export PS1='%n@%m%{$fg[cyan]%} %c%{$fg_bold[blue]%}$(git_prompt_info)%{$fg_bold[blue]%}>%{$reset_color%}'

host user ...:

	%n@%m user@hostname
	%c 		current working directory
	${ret_status}

color:

	%{$fg[cyan]%}
	%{$fg_bold[blue]%}
	%{$reset_color%}

git:

	%{$fg_bold[blue]%}$(git_prompt_info)

vm:

	%n@%m%{$fg[cyan]%} %c %{$fg_bold[blue]%}>%{$reset_color%}

# 参考
- [readline]
- [shell_shortcutKey]
- [终极shell]

[readline]: http://ahei.info/bash.htm
[shell_shortcutKey]: http://coderbee.net/index.php/linux/20130424/41
[终极shell]: http://macshuo.com/?p=676
