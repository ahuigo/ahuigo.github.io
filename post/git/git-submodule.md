---
layout: page
title:
category: blog
description:
---
# Preface

# git submodule add

	$ git submodule add https://github.com/ahuigo/c-lib
	Cloning into 'c-lib'...
	$ gst
	On branch master
	Your branch is up-to-date with 'origin/master'.
	Changes to be committed:
	  (use "git reset HEAD <file>..." to unstage)

		new file:   .gitmodules
		new file:   c-lib

`c-lib` 作为module，git 认为它是一个文件，而非dir

> 可通过在本地执行 `git config submodule.c-lib.url <URL>` 来覆盖这个选项的值

## git diff

	$ git diff --cached ;# 简化信息
	$ git diff --cached --submodule; # 显示submodule 的sha
	diff --git a/.gitmodules b/.gitmodules
	new file mode 100644
	index 0000000..bb7fdfe
	--- /dev/null
	+++ b/.gitmodules
	@@ -0,0 +1,4 @@
	+[submodule "c-lib"]
	+       path = c-lib
	+       url = https://github.com/ahuigo/c-lib
	+
	Submodule c-lib 0000000...c061cce (new submodule)

如果你不想每次运行 git diff 时都输入`--submodle`，那么可以将 `diff.submodule` 设置为 “log” 来将其作为默认行为。

	$ git config --global diff.submodule log

提交时 c-lib 记录的 160000 模式。 这是 Git 中的一种特殊模式，
它本质上意味着你是将一次提交记作一项目录记录的，而非将它记录成一个子目录或者一个文件。

	$ git commit -am 'added module'
	[master fb9093c] added c-lib module
	 create mode 100644 .gitmodules
	 create mode 160000 c-lib

# 克隆含有子模块的项目
克隆项目时，默认会包含该子模块目录，但其中还没有任何文件, 需要init 并拉取update(fetch+checkout)

0. git submodule init
	Initialize the submodules recorded in the index
    by copying submodule names and urls from .gitmodules to .git/config.
1. git submodule update
	0. with init: git submodule update --init
	1. updates the contents of the submodules: It is effectively running a "git fetch" and "git checkout" in each of your submodules.
2. git submodule sync
	1. updates the *metadata* about a submodule to reflect changes in the submodule URL.
	2. It re-synchronizes the information in *.git/config* with the information in *.gitmodules*.

更简单的方式在克隆时：

	git clone --recursive url

手动更新

	git submodule update --remote c-lib
	git submodule update --remote

默认更新的是submodule 的master, 可以指定其它的如`stable`

	git config -f .gitmodules submodule.c-lib.branch stable

## submodule sync

### change remote url
1. You should just be able to edit the `.gitmodules` file to update the URL
	1. or via command: `git config --file=.gitmodules submodule.SubmodName.url https://github.com/username/ABC.git`

2. then run `git submodule sync` to reflect that change to the superproject and your working copy.

# 合并submodule

	$ git submodule update --remote --merge

# log
提交之后，你也可以运行 git log -p 查看这个信息。

	$ git log -p --submodule

# Reference
- [scm submodule]

[scm submodule]: https://git-scm.com/book/zh/v2/Git-%E5%B7%A5%E5%85%B7-%E5%AD%90%E6%A8%A1%E5%9D%97
