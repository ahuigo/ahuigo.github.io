---
layout: page
title:	Emacs 
category: blog
description: 
---
# Preface
Advantage:

1. 写中文比vim 更方便
2. 打字配套的附件功能始终不如Emacs，比如repl环境、文件管理、笔记管理、minor mode 等。相当一部分major mode(浅薄地说，和Vim的filetype对应)，都是Emacs的比Vim的对应物好用，比如AUCTeX，haskell-mode，tuareg-mode。
2. org-mode 体验一下
3. 学习emacs 下的思考方式, 包括emacs lisp 思想

不过现在还是主要用vim. 

Shortcoming:

1. Not support mouse scroll when window is not actived??
1. Not support mutithread like vim.

More：

http://bluegene8210.is-programmer.com/posts/69956.html


# Start

## init config

	rm -r ~/{.emacs.d,.emacs}
	git clone https://github.com/purcell/emacs.d ~/.emacs.d
	//or from redguardtoo(without network dependency)
	git clone git@github.com:redguardtoo/emacs.d.git ~/.emacs.d

## practical
1. http://www.cbi.pku.edu.cn/chinese/documents/csdoc/emacs/
1. M-x help-with-tutorial or C-h t
2. https://github.com/redguardtoo/mastering-emacs-in-one-year-guide/blob/master/guide-zh.org

## org mode manual
http://www.cnblogs.com/Open_Source/archive/2011/07/17/2108747.html

## with vim 

[vim or emacs]: http://emacser.com/vimvsemacs.htm


### ide
evil http://www.emacswiki.org/emacs/Evil

## learn lisp
- Common Lisp。ANSI标准，还有很多库，是用途最广的Lisp。实现的话，楼上说的SBCL（Steel Bank Common Lisp）蛮不错的，我之前用的是CLISP和GCL（好久没写CL了）。
- Scheme, simple and elegant，自带的函数很少，但也很强大，我个人推荐Guile实现。我和Guile的维护者Ludovic Courtès聊过，他是个非常优秀的开发者。
- Emacs Lisp。自带很多处理文本、缓冲区、命令循环、键绑定等很有用的功能。即使你不用Emacs，Emacs Lisp也是一门很值得学习的语言，你可以用emacs --script和emacs --batch来执行程序。实现的话，还是用GNU Emacs吧，其他的implementation也都大同小异。

http://coolshell.cn/articles/7526.html

# Install

	brew install emacs --cocoa
		--cocoa with GUI
		--srgb support sRGB color

	ln -s /usr/local/Cellar/emacs/24.3/Emacs.app /Applications
	or
	brew linkapps emacs
	

It's suggested you to remove that older Emacs version to avoid conflicts with the new one. Do this:

	$ echo <<< 'alias emacs="/usr/local/Cellar/emacs/24.3/Emacs.app/Contents/MacOS/Emacs -nw"	' >> ~/.zshrc
	or
	$ sudo rm /usr/bin/emacs
	$ sudo rm -rf /usr/share/emacs
	
Refer to: http://wikemacs.org/wiki/Installing_Emacs_on_OS_X

# Term 术语

## KEY

	<SPC> space
	<Del> delete
	<RET> enter

## Emacs-Speak

	selection	Region
	cut			kill
	paste		yank
	window		Frame
	shortcut	KeySequence


## On MAC OSX

1. Swapping CTRL and CAPS LOCK in keyboard preference.
2. Remap Left Option key as +ESC(meta key) in iTerm2(Profiles, Keys ).

## Xkeymacs
Xkeymacs 是一个日本人写的软件，将windows 所有的按键都接管, 使得软件运行在 emacs 模式了

# Format

## Line

### Max line

	C-x f 70
	C-u 70 C-x f

This will influence auto-fill-mode when you made changes at end of line. 
To re-fill the paragraph, you should type `M-q`

# Mode
At any time, only on major mode can be active. But there is no limitation for minor modes.

## Major Mode
Each Major mode makes a few commands behaves differently. Each major mode is and extend command, which is how you can switch to that mode:
For instance, you can switch to text-mode by pressing the following command:

	M-x text-mode

In fundamental-mode, M-f/b treat apostrophes as word-separators. But not in text-mode.

To view all major-mode's documentation.

	C-h m	//major


## Minor Mode
One minor mode is very useful, especially for human-language text, is Auto-fill-mode. When this mode is on, emacs breaks the line in between words automatically if text line is too wide.

You can use the following command to toggle auto-fill-mode

	M-x auto-fill-mode

# Completion
It is describes in emacs manual in the node called *Completion*

	TAB
		filled with most characters
	SPACE
		filled with only one word
	?
		list all completions

# Dired
Dired is a visual directory editor, which help you to list files in a directory, and visit, rename, delete on the file.

	C-x d
	C-x C-d

Operation:

	d delete
	r rename
	c copy
	x xpunge(excute)
	f find
	o other-window
	? help


# Help

	*C-h ?	
		help-for-help: describes how to use help fcilities.

## Manual

	C-h i
		The Info documentation
		This command puts you to special buffer called *Info*.
	C-h r
		The Emacs documentation
		You should consult this manual as primary documentation.
	C-h m 
		The documentation in current minor and major mode.

Here are some shortcuts:

	? 
		help you to know how to use manual.
	n/p
		next/previous node
	[/]
		previous/next node
	</>
		first/final node
	^/
		up node
	r/l
		backward/forward in history node

## KEYS

### Brief Usage for KEYS

	C-h c KEYS
		Example: C-h c C-p

### Detail Usage for KEYS

	C-h k KEYS
		M-x describe-key KEYS:
			Example: C-h k C-p

### Find Key

	C-h w COMMAND
		Display the keystrokes invoke the given command.

## Search a command

	C-h a PATTERN
		list all commands that contains the PATTERN
		C-h a file

## Function & Command

	C-h f FUNCTION
		M-x describe-function:
			description the documentation for the given function.
		C-h f previous-line <ENTER>
	C-h F COMMAND
		Show the manual for the given command in current window.

## Variable

	C-h v VARIABLE
		M-x describe-variable

## tutorial

	*C-h t 	
		help-with-tutorial

## roughly command

	M-x
		execute-extended-command: allows you to execute a command if you know roughly what it is called, but cannot remember the key strokes for it.

# Commands
An asterisk(*) to the left of a command indicate it is one to learn imediately.

	Meta characters are often used for operations related to the units defined by language(words, sentences, paragraphs)
	Control characters operate on basic units that are independent of what you are Editing(character, lines, etc).

## Windows/Files/Buffers/Frames

### Frames
A frame is what we called one collection of windows, together with its menus, scroll bars, echo area, etc.
On graphic displays, many graphic frames can be shown at a time, but not in terminal emacs.

	M-x make-frame
	M-x delete-frame

### Files/Buffers

Most of time, buffer name is same as file name. However, this is not always true:

- `*Buffer List*` contains the buffer list that you made with `C-x C-b`
- `*Messages*` contains the messages that appeared on the bottom line of your emacs session.
- `*Buffer List*` contains the buffer list that you made with `C-x C-b`
- `*Buffer List*` contains the buffer list that you made with `C-x C-b`

Here are some commands related to buffer.

	*C-x C-f	
		find-file
	*C-x C-s [<new_filename>]
		save-file:
			save the buffer into the associated filename.
			The first time you do this, emacs will rename original file whth a new name by adding a `~` to the end of original file's name.
	*C-x s [buffer_name>]
		save-some-buffers:
			save specified buffer
	C-x C-w		
		write-named-file: prompts a new filename and write buffer into it.
	C-x b <buffer_name>
		switch-to-buffer: display a different buffer.
	C-x C-b
		list-buffers:

### Windows
The bottom line which prompts you to input, is called minibuffer input.

#### Window Split

	C-x 0
		zero-window: delete current window
	C-x 1
		get rid of other buffer
	C-x 2
		double-window: split current window into two parts.
	C-x o
		other-window: switch to other window
	C-x 4 C-f <filename>
		open file in new window

#### scroll

	C-M-v
		Scroll down the other window.
	C-M-S-v
		Scroll up the other window?

## Move

	M-f/b 	move cursor forward/backward one word
	C-n/p		move cursor to next/previous line
	C-a/e		
		move cursor to start/end-of-line
	M-a/e	
		Move to the beginning or end of sentence.
	C-v/Esc-v	
		Move to the next/previous screen.
	C-l		Move text around the cursor to then middle of screen
	M-</>
		Move to the start/end of the whole text.
		≤≤≥≥÷÷≤≥÷≤≥÷≤≥÷

### Edit( Copy & Delete & paste)

#### Recursive Editing Level
`Recursive Editing Level` is indicated by square brackets in mode line, surrounding the parentheses around the major name.

You cannot use `C-g` to get out of `Recursive Editing Level`, because it is used to stop command only. You shoud use the following command instead:

	<ESC> <ESC> <ESC>

This is a all-purpose "get out" command.

#### Insert
	C-j			New Line(with cursor move)
	C-o			New Line(without cursor move)
	C-e C-j
	C-a C-o

#### Search

	C-s/r
		isearch-forward: prompts for text string and search from current cursor position forwards in the buffer.
		isearch-backward: likes isearch-forward, but search from current cursor position to the end of buffer.
#### Replace

	M-x repl s
		replace-string:
	M-%
		query-replace:
			prompts for a search string and a string with which to replace search string.

#### Select

	C-@			set-mark-command: mark is used to indicate the beginning of an area of text to be yanked
	C-<SPC>		set-mark-command: mark is used to indicate the beginning of an area of text to be yanked
	*M-H			Select sentence.
	C-x h
		Select buffer

#### Delete(kill)
The difference between "killing" and "deleting" is that "killed" text
can be reinserted (at any position), whereas "deleted" things cannot
be reinserted in this way (you can, however, undo a deletion)  Reinsertion of killed text is called "yanking".

	//by char
	C-d/Del		delete-char/backward-kill-char: character under/previous cursor

	//by word
	M-d/M-Del	
		delete-word/backward-kill-word: delete from cursor to end of word immediately ahead of the cursor

	//by line
	C-k			
		kill-line: Delete the rest of current line
	//by sentence
	M-k
		kill-sentence: kill to the end of sentence.
	C-x <Del>
		backward-kill-sentence: Kill back to the beginning of sentence.

	//by mark region
	*C-w		kill-region: kill area of text between the mark and the current cursor or the whole line
	//only copy
	*M-w 		kill-ring-save(copy-region-as-kill): copy area between mark and cursor into kill-buffer, so that it can be yanked into someplace else

	//by mark char
	M-z char
		zap-to-char: kill through the next ocuurence of char.
	
	C-M-k
		kill-sexp: kill the following balanced expression.

### Yank

	//paste
	C-y			
		yank: insert at current cursor whatever the most recently deleted.
	M-y
		replace yanked text with previous killed text

## undo

	C-/
	C-_
		Same as C-x u
		Undo last command


## Extending the command set
Emacs gets around with X(eXtend) command. This comes in tow flavors:

	C-x Character eXtend. Followed by one character.
	M-x Named Command eXtend. Followed by a long name.

Just type `M-x repl x<TAB>`, emacs will complete the name to `replace-string`

## Exit and Fixing Mistakes

	C-x C-c
		save-buffers-kill-emacs
	C-x g
		keyboard-quit:	if while typing command you make a mistake and want to stop.
			discard a command you do not want to finish
	
### Auto Save
To protect you from lost unsaved data when computer crashes, emacs periodically write an "auto save" file for each file that you are editing.
The auto file name has a # at the beginning and the end of filename.

You can recover your auto-saved file by typing:

	M-x recover-file

## Repeat Command

	C-u number <most_command>
	M-number <most_command>
		universal-argument: if you want to do a command serveral times, type `<times> <command>`
		C-v/M-v are another kind of exception. When given argument, the scroll the text up and down by that many lines
	C-x u
		undo: Undoes the last command if you made a mistake.


# LINE

## ECHO AREA

## MODE LINE
The mode lines says something like this:

	-:**-  TUTORIAL       63% L749    (Fundamental)

This line gives useful infomation about the status of emacs and the text you are editing.

	**
		The star means you have made changes 
	--
		The dashes means there is no changes to save.
	63%
		indicates your current position in the buffer text.
	
	L749
		The L indicates current position in another way, it gives current line number.
	(Fundamental)
		The part of mode line inside parentheses is to tell you what the editing mode you are in.
		Fundamental is one of 'major modes', At any time only one mode is active.
	

# todo

http://stackoverflow.com/questions/5710334/how-can-i-get-mouse-selection-to-work-in-emacs-and-iterm2-on-mac

For Emacs in iTerm 2, I've found that the following bit in my ~/.emacs file works very well, providing the ability to insert the character at an arbitrary location, mark a region, and use the scroll wheel:

    ;; Enable mouse support
    (unless window-system
      (require 'mouse)
      (xterm-mouse-mode t)
      (global-set-key [mouse-4] '(lambda ()
                                  (interactive)
                                  (scroll-down 1)))
      (global-set-key [mouse-5] '(lambda ()
                                  (interactive)
                                  (scroll-up 1)))
      (defun track-mouse (e))
      (setq mouse-sel-mode t)
    )

