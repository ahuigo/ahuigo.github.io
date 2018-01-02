---
layout: page
title:	svn merge diff 脚本
category: blog
description: 
---
# Preface
svn自带的diff/merge很不友好，所以我写了几个diff/merge脚本

# 配置
编辑`vim ~/.subversion/config`, 增加以下两行：

	# 用于svn diff, svn up 时比较两个文件
	diff-cmd = /Users/hilojack/.subversion/vimdiff.sh 

	# 用于svn merge 时三个文件做比较
	merge-tool-cmd = /Users/hilojack/.subversion/vimmerge.sh

# 两个文件比较
`cat vimdiff.sh`:

	#!/bin/sh
	theirs_name=${3//	/}
	theirs=${6}
	working_name=${5//	/}
	working=${7}
	vimdiff $theirs $working -c "diffthis | setl stl=${theirs_name// /\ }| wincmd W | setl stl=${working_name// /\ } "

# 三个文件比较
`cat vimdmerge.sh`:

	#!/bin/sh
	BASE=${1}
	THEIRS=${2}
	MINE=${3}
	MERGED=${4}
	WCPATH=${5}
	vimdiff $THEIRS $MINE -c ":bo sp $MERGED" -c "diffthis" -c "setl stl=MERGED | wincmd W | setl stl=Mine | wincmd W | setl stl=Theirs|wincmd W"
