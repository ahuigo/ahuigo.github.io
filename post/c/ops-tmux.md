---
layout: page
title:	linux-tmux
category: blog
description: 
---
# install
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

## 关闭会话(session)
在tmux 外

	tmux kill-session -t work

在tmux 会话内

    Ctrl-d

## 退出tmux, 但是不关闭会话(session)
从当前 tmux 会话分离(detach)，让服务继续跑：

	# 命令行直接分离
	tmux detach

	# 常用快捷键：Ctrl-b d

如果当前会话开了多个客户端，按 `Ctrl-b D` 选择要分离的客户端。

## 会话列表
在列表中，按`jk` 选择，按`space` 展开，按`Enter` 确认. 也可按`session_id` 直接选择确认

	Ctrl-b s

在tmux 外查看会话

	$ tmux ls
    ctrl+b :ls

## session attache & detach

	tmux attach -t work
	tmux ls

## capture
	tmux capture-pane -t <session>:<window> -e -p -S - -E - | aha > /tmp/a.html

# 窗口

## 窗口由多个面板组成
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

## 面板 Panes
新加窗格面板

	" 竖直
	Ctrl-b %
	" 水平
	Ctrl-b "

在面板间移动光标

	Ctrl-b Up/left/right/down
	C-b o 下一面板
	C-b ; 切换回上一个面板

嫌方向键键程长，可以在 ~/.tmux.conf 里用更短的 Vim 风格绑定：

	bind -r h select-pane -L
	bind -r j select-pane -D
	bind -r k select-pane -U
	bind -r l select-pane -R

使用时先按前缀 `Ctrl-b`，再按对应的 h/j/k/l。

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

# 编辑
## command mode

    ctrl+b :list-keys -T copy-mode-vi

## 复制文本
1. `ctrl-b [` 进入vi 模式
2. `<space>` 选择，`v` 在垂直选择和行选择之间切换
3. `<enter>` 复制

## 鼠标支持
~/.tmux.conf：

    set -g mouse on

或实时切换到鼠标模式：

	# 临时开启（当前tmux内执行）
	Ctrl-b : set -g mouse on

	# 临时关闭
	Ctrl-b : set -g mouse off

	# 绑定一个键 (m) 用于一键切换
	# 写入 ~/.tmux.conf 后，重载配置或重启 tmux
	bind m if -F '#{mouse}' 'set -g mouse off \; display-message "Mouse: OFF"' 'set -g mouse on \; display-message "Mouse: ON"'

提示：开启 mouse 后，滚轮会滚动并进入复制模式；若不习惯，可随时用上面的快捷方式关闭。
    

或用vi 模式选择复制

    setw -g mode-keys vi

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
