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

# Shortcuts
The default shortcuts prefix is `ctrl+b`, you and set it to `ctrl+d`

	$ vim ~/.tmux.conf
	unbind C-b
	set -g prefix C-d

如果你希望新的配置项能够立即生效，那么你可以将下面这一行配置加入到文件 ~/.tmux.conf 中。

	# bind a reload key
	bind R source-file ~/.tmux.conf ; display-message "Config reloaded.."

这样配置了之后，每当向 `~/.tmux.conf` 文件中添加了新的配置，只需要按下 `Ctrl-b r` 就可以重新加载配置并使新的配置生效，从而免去了开启一个新的会话。

# 窗格面板
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

# 窗口
窗口由多个面板组成
创建窗口

	C-b c 创建窗口
	C-b & 关闭当前窗口

切换窗口

	Ctrl-b Num_Of_Window
	C-b p 切换到上一个窗口
	C-b n 切换到下一个窗口

# 会话
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

## 关闭会话
在tmux 外

	tmux kill-session -t work

## 会话列表
在列表中，按`jk` 选择，按`space` 展开，按`Enter` 确认. 也可按`session_id` 直接选择确认

	Ctrl-b s

在tmux 外查看会话

	$ tmux ls

## session attache & detach
关于会话有两个非常重要的操作，即attach和detach，attach就是让某个会话到前台来运行，而detach则是将某个会话放到后台。通常，当我们打开tmux时，tmux在创建一个会话的同时也会attach到这个会话，所以我们会立即看到tmux的窗口。在某个会话中，我们按C-b d会detach这个会话，也就会回到原先的终端控制台，但实际上并没有退出这个会话，比如你可以通过在终端中输入下列命令重新attach到work会话：

	tmux attach -t work

# 复制文本
1. `prefix [` 进入vi 模式
2. `<space>` 选择，`v` 在垂直选择和行选择之间切换
3. `<enter>` 复制

# Reference
http://blog.jobbole.com/87584/
http://abyssly.com/2013/11/04/tmux_intro/
