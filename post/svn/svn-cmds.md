---
layout: page
title:	svn-cmds
category: blog
description:
---
# Preface

# config
	diff-cmd (svn diff)
	merge-tool-cmd (svn up, svn merge)
	diff3-cmd(auto merge for svn up & svn merge)

# list
用于显示目录结构

	svn list http://svn.sinaapp.com/hilo/

# cat
svn cat 目标[@版本]…如果指定了版本，将从指定的版本开始查找。

	svn cat -r PREV filename (PREV 是上一版本,也可以写具体版本号,这样输出结果是可以提交的)
	svn cat -r HEAD filename | vim -

如果是删除文件，如果指定repository URL，而非working copy

	svn cat https://svn.ahui132.github.io/autofans.js@238
	svn cat ^/autofans.js@238

# import 导入数据到你的版本库
有两种: add && import, import 是导入到svn 库里面

	$ svnadmin create /var/svn/newrepos
	$ svn import mytree file:///var/svn/newrepos/some/project  -m "Initial import"
			 Adding         mytree/foo.c
			 Adding         mytree/bar.c
			 Adding         mytree/subdir
			 Adding         mytree/subdir/quux.h

	svn add dir
	svn revert --recursive dir //unadd

# info
 概要信息

	svn info [url|dir|file]

# status

	svn st [url|dir|file] -v

	$ svn st -u -v
	M      *        44        23    sally     README

	# 具体含义如下
	44	working copy revision
	23 last revision
	sally author
	?       scratch.c           # file is not under version control
	A       stuff/loot/bloo.h   # file is scheduled for addition
	C       stuff/loot/lump.c   # file has textual conflicts from an update
	D       stuff/fish.c        # file is scheduled for deletion
	M       bar.c               # the content in bar.c has local modifications
	L       bar.c               # locked (Y have to do `svn cleanup`)

# update
conflict:

	(e)  edit             - change merged file in an editor(rely on enviroment EDITOR)
	(df) diff-full        - show all changes made to merged file
	(r)  resolved         - accept merged version of file

	(dc) display-conflict - show all conflicts (ignoring merged version)
	(mc) mine-conflict    - accept my version for all conflicts (same) 遇到冲突块时, 选择mine
	(tc) theirs-conflict  - accept their version for all conflicts (same)

	(mf) mine-full        - accept my version of entire file (even non-conflicts)
	(tf) theirs-full      - accept their version of entire file (same)

	(p)  postpone         - mark the conflict to be resolved later
	(l)  launch           - launch external tool to resolve conflict

	C confilct

## launch external tool

### config
	$ vi ~/.subversion/config
	# Subversion will pass 4 arguments to
	# the specified command: base theirs mine merged
	merge-tool-cmd = /Users/hilojack/.subversion/vimmerge.sh

	$ cat ~/.subversion/vimmerge.sh
	#!/bin/sh
	BASE=${1}
	THEIRS=${2}
	MINE=${3}
	MERGED=${4}
	vimdiff $MINE $THEIRS -c "bo sp $MERGED" -c "diffthis" -c "setl stl=MERGED | wincmd W | setl stl=THEIRS | wincmd W | setl stl=MINE"


## postpone延后解决冲突
It will create some file as below.

	filename (contain conflict markers)
	filename.mine
	filename.rOLDREV Base
	filename.rNEWREV

## diff

	svn di -r PREV:HEAD (svn up后)
	svn di -r COMMITTED:HEAD (svn up 前)
	svn diff:
		use diff-cmd=

	 A revision argument can be one of:
		NUMBER       revision number
		'{' DATE '}' revision at start of the date
		'HEAD'       latest in repository
		'BASE'       base rev of item's working copy
		'COMMITTED'  last commit at or before BASE
		'PREV'       revision just before COMMITTED

## resolve
svn update后，出现冲突, 使用resolve解决

	$ svn resolve –-accept=ARG [option] PATH

其中ARG:

	base	.BASE 原始的版本
	theirs-conflict	遇到冲突的块时，使用theirs的改动
	theirs-full	无论是否遇到冲突的块，全部都使用theirs的改动
	mine-conflict 遇到冲突块时，使用我的改动
	mine-full	全部使用我的(合并前的working copy[wc])
	working		工作区文件(合并全的working copy [wc])

比如：

	$ svn resolve –-accept=theirs-full -R PATH //也就是接受文件*.rNew
	$ svn resolve –-accept=working -R PATH //也就是接受文件*

## resolved
svn help resolved
resolved: Remove 'conflicted' state on working copy files or directories.
usage: resolved PATH...

  Note:  this subcommand does not semantically resolve conflicts or
  remove conflict markers; it merely removes the conflict-related
  artifact files and allows PATH to be committed again.  It has been
  deprecated in favor of running 'svn resolve --accept working'.

# merge

	svn help merge

	svn merge url ;//已经合并过的版本不会现合并了, 不用指定版本号
	svn merge -r m:n path
	svn merge -r m:n ^/trunk    (^==root)
		例如：svn merge -r 200:205 test.php（将版本200与205之间的差异合并到当前文件，但是一般都会产生冲突，需要处理一下）
	svn merge -r 28:25 url //从28还原到25(回滚)
	svn merge -c 5 //same as -r 4:5
	svn merge -c -5 //same as -r 5:4
	svn merge -c 5,7 -r 28:33 url //cherry-pick
	svn merge -r 105711:105991 --accept theirs-full --force url

	svn merge -r 29 url // -r lastMerged:29

# revert

	 svn revert [-R] path //放弃working copy修改

# lock
加锁/解锁

	svn lock -m “LockMessage“ [--force] PATH

# cleanup
When Subversion modifies your working copy (or any information within .svn), it tries to do so as safely as possible. Before changing the working copy, Subversion writes its intentions to a logfile. Next, it executes the commands in the logfile to apply the requested change, holding a lock on the relevant part of the working copy while it works—to prevent other Subversion clients from accessing the working copy mid-change. Finally, Subversion removes the logfile. Architecturally, this is similar to a journaled filesystem. If a Subversion operation is interrupted (e.g, if the process is killed or if the machine crashes), the logfiles remain on disk. By reexecuting the logfiles, Subversion can complete the previously started operation, and your working copy can get itself back into a consistent state.

And this is exactly what svn cleanup does: it searches your working copy and runs any leftover logs, removing working copy locks in the process. If Subversion ever tells you that some part of your working copy is “locked,” this is the command that you should run. Also, svn status will display an L next to locked items:

# log

	svn log -v -l num path/url //-v 显示文件 -l限制最近的条数
	svn log -v -r 106230
	svn log -r 26:28
	svn log -r 26
	svn log -c 26,27

## date

	svn log -r '{2014-05-10 17:29:02}':'{2014-05-12 18:00:00}'

# diff|di

## di working copy

	# base -> working copy
	svn diff //same as svn di HEAD

	# r:3 -> working copy
	svn diff -r 3

	# r:3->r:38
	svn diff -r 1:38

	# r:3->r:4
	svn di -c 4

	# last change
	svn di PREV:HEAD

## di url

	#url r:6 ->r:HEAD
	svn di -r 6 url

	#url r:6 ->r:8
	svn di -r 6:8 url

## diff-cmd

	--diff-cmd ARG           : use ARG as diff command
	--internal-diff          : override diff-cmd specified in config file
	-x [--extensions] ARG    : Default: '-u'. When Subversion is invoking an
	                        external diff program, ARG is simply passed along to the program.

	$ svn diff --diff-cmd=diff -x '-u'
	$ diff -u -L 'a.c(revision 1)' -L 'a.c(working copy)' '/Users/hilojack/www/svntest/.svn/pristine/da/da39a3ee5e6b4b0d3255bfef95601890afd80709.svn-base' '/Users/hilojack/www/svntest/a.c'

	Index: a.c
	===================================================================
	--- a.c	(revision 1)
	+++ a.c	(working copy)
	@@ -0,0 +1 @@
	+teste

# resolved
svn resolved: 移除工作副本的目录或文件的“冲突”状态。

	用法: resolved PATH…

注意: 本子命令不会依语法来解决冲突或是移除冲突标记；它只是移除冲突的相关文件，然后让 PATH 可以再次提交。

# switch|sw
svn switch (sw): 更新工作副本至不同的URL。
用法:

	1、switch URL [PATH]
	2、switch –relocate FROM TO [PATH...]

1、更新你的工作副本，映射到一个新的URL，其行为跟“svn update”很像，也会将服务器上文件与本地文件合并。这是将工作副本对应到同一仓库中某个分支或者标记的方法。
2、改写工作副本的URL元数据，以反映单纯的URL上的改变。当仓库的根URL变动(比如方案名或是主机名称变动)，但是工作副本仍旧对映到同一仓库的同一目录时使用这个命令更新工作副本与仓库的对应关系。

# copy
参考[merge]
创建分支

	svn copy -m "1.7.2-theme" svn://localhost/www/trunk svn://localhost/www/branches/branch1.7.2-theme

主干合并到分支

	#branch1.7.2是分支目录，注意不可以进到分支子目录
	cd branch1.7.2
	#前面的12972是开分支之前trunk的版本号，后面的12991是merge时trunk的版本号
	svn merge -r 12972:12991 svn://localhost/www/trunk

分支合并到主干

	#先从trunk checkout一份新鲜的代码，然后cd到该版本目录下
	svn co svn://localhost/www/trunk
	cd trunk
	#12973是分支开始的版本号，13006是分支结束的版本号
	svn merge -r 12973:13006 svn://localhost/www/branches/branch1.7.2

# rm
创建tags, 产品开发已经基本完成，发布我们的1.0版本

	svn copy ^/trunk ^/tags/v1.0 -m "1.0 released"

删除分支或tags

	svn rm ^/branches/branches-theme
	svn rm ^/tags/v1.0

恢复分支：

	svn cp [path to deleted branch]@[revision before delete] [new path]
	svn cp ^/branches/2.0.5@1993  ^/branches/2.0.5_restored

# propset
propset propedit
属性设置

## ignore

### set

	svn propset svn:ignore dirname .
	svn propset svn:ignore "
	dirname
	file1" .

### edit
    svn propedit svn:ignore .

###delete

    svn propdel svn:ignore . # For directory
    svn prodel svn:ignore -R # For recursive

## log

	svn propedit -r N --revprop svn:log URL
	svn propset  svn:log "new log message"  -r N --revprop [url]

# debug

	svn diff --diff-cmd='echo'
	svn diff --diff-cmd='a.sh'

# Reference
- [svn manual]
- [merge]
- [svn1.6 manual google]
- [svn1.4 manual google]

[svn1.6 manual google]: http://i18n-zh.googlecode.com/svn/www/svnbook/zh/index.html
[svn1.4 manual google]: http://i18n-zh.googlecode.com/svn/www/svnbook/zh/index.html
[vim merge]: http://stackoverflow.com/questions/19678860/svn-using-vim-to-merge-conflicts
[svn merge2]: http://adam8157.info/blog/2011/01/use-vim-to-resolve-svn-conflicts
[merge]: http://panweizeng.com/svn-branching-merging.html
