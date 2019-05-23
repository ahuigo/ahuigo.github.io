---
layout: page
title:	linux-tmux
category: blog
description: 
---
# Preface
tmux 用于复用终端窗口, 安装tmux 很简单

	brew install tmux
	sudo yum install tmux -y

> 除了tmux 还有screen. 另一个只用于保持会话的最小可选方案是 dtach。

# Usage:

	$ tmux
	$ node server.js

	# 返回原来的session
	$ tmux detach

除了tmux detach，另一种方法是按下`Ctrl + B和d` ，也可以回到原来的 session。

	# 下次登录时，返回后台正在运行服务session
	$ tmux attach
	如果新建多个 session，就需要为每个 session 指定名字。

	# 新建 session
	$ tmux new -s session_name

	# 切换到指定 session
	$ tmux attach -t session_name

	# 列出所有 session
	$ tmux list-sessions

	# 退出当前 session，返回前一个 session
	$ tmux detach

	# 杀死指定 session
	$ tmux kill-session -t session-name

# Config
The default shortcuts prefix is `ctrl+b`, you and set it to `ctrl+d`

	$ vim ~/.tmux.conf
	unbind C-b
	set -g prefix C-d

如果你希望新的配置项能够立即生效，那么你可以将下面这一行配置加入到文件 ~/.tmux.conf 中。

	# bind a reload key
	bind R source-file ~/.tmux.conf ; display-message "Config reloaded.."

这样配置了之后，每当向 `~/.tmux.conf` 文件中添加了新的配置，只需要按下 `Ctrl-b r` 就可以重新加载配置并使新的配置生效，从而免去了开启一个新的会话。

# 会话(session)
会话由多个窗口组成

## 创建会话:

	# 在命令行内(非tmux 环境)
	tmux new -s <session_name>
	# 同时指定第一个窗口的名字为mysql
	tmux new -s <session_name> -n mysql 

在tmux 环境下

	Ctrl-b : new -s <session_name>

创建会话时，创建project 窗口

	tmux new-window -n project -t work

在创建会话和窗口时甚至可以指定要执行的命令：创建work会话后，在其第一个窗口的控制台中执行SSH命令以远程连接到服务器中。

	tmux new-session -s work -n dev -d "ssh user@example.com"

创建会话时，`-d` 表示不自动attache 会话

	tmux new-session -s work -d

total:

    New Session
        tmux new [-s name] [cmd] (:new) - new session
    Switch Session
        tmux ls (:ls) - list sessions
        tmux switch [-t name] (:switch) - switches to an existing session
        tmux as [id] [-t name] (:attach) - attaches to an existing session
        <C-b>c (:detach) - detach the currently attached session
    Session Management
        <C-b>s - list sessions
            <C-b>:ls - list sessions
        <C-b>$ - name session
    Close Session
        tmux kill-session [-t name] (:kill-session)


## 关闭会话(session)
在tmux 外

	tmux kill-session -t work

## 会话列表
在列表中，按`jk` 选择，按`space` 展开，按`Enter` 确认. 也可按`session_id` 直接选择确认

	Ctrl-b s

在tmux 外查看会话

	$ tmux ls
    ctrl+b :ls

## session attache & detach
关于会话有两个非常重要的操作，即attach和detach，attach就是让某个会话到前台来运行，而detach则是将某个会话放到后台。通常，当我们打开tmux时，tmux在创建一个会话的同时也会attach到这个会话，所以我们会立即看到tmux的窗口。在某个会话中，我们按C-b d会detach这个会话，也就会回到原先的终端控制台，但实际上并没有退出这个会话，比如你可以通过在终端中输入下列命令重新attach到work会话：

	tmux attach -t work

# 窗口
窗口由多个面板组成
创建窗口

    <C-b>c (:neww [-n name] [cmd]) - new window
    <C-b>& (:kill-window) - kill window

切换窗口

	Ctrl-b Num_Of_Window
	C-b p 切换到上一个窗口
	C-b n 切换到下一个窗口
    <C-b>l - go to last window

Window Management

    <C-b>T - rename window
    <C-b>, - rename window
    <C-b>w - list all windows
    <C-b>f - find window by name
    <C-b>. - move window to another session (promt)
    :movew - move window to next unused number

# 窗格面板 Panes
新加窗格面板

	" 竖直
	Ctrl-b %
	" 水平
	Ctrl-b "

在面板间移动光标

	Ctrl-b Up/left/right/down
	C-b o 下一面板

关闭面板

	C-b x 关闭当前面板

New Pane

    (%) <C-b>| (:splitw [-v] [-p width] [-t focus] [cmd]) - split current pane vertically
    (") <C-b>s (:splitw -h [-p width] [-t focus] [cmd]) - split  current pane horizontally

Cursor Movement

    (o) <C-b><Tab> (:selectp -t :.+) - move cursor to the next pane
    <C-b><Up> (:selectp -U) - move cursor to the pane above
    <C-b><Down> (:selectp -D) - move cursor to the pane below
    <C-b><Left> (:selectp -L) - move cursor to the pane to the left
    <C-b><Right> (:selectp -R) - move cursor to the pane to the right
    :selectp [i] - move cursor to the pane [i]

Panes Management

    (:swap-pane -U) - move current pane up
    (:swap-pane -D) - move current pane down
    <C-b>{ (:swap-pane -L) - move current pane to the left
    <C-b>} (:swap-pane -R) - move current pane to the right
    <C-b>q - show pane numbers (type number to move cursor)
    <C-b><Space> - toggle pane arrangements

# command mode

    ctrl+b :list-keys -T copy-mode-vi

# 复制文本
1. `ctrl-b [` 进入vi 模式
2. `<space>` 选择，`v` 在垂直选择和行选择之间切换
3. `<enter>` 复制

# tmux with iterm2
https://toutiao.io/posts/q86tnu/preview

Navigate to “Preferences > Profiles > PROFILE >Command > Send text at start” and set it to:

    tmux ls && read tmux_session && tmux attach -t ${tmux_session:-default} || tmux new -s ${tmux_session:-default}

note:

    tmux -CC -t session-name用新窗口新建一个session

# Reference
http://blog.jobbole.com/87584/
http://abyssly.com/2013/11/04/tmux_intro/
https://gist.github.com/Starefossen/5955406
