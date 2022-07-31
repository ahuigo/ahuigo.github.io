---
layout: page
title: git-diff
category: blog
description: 
date: 2018-09-27
---
# git diff 

## difftool

	git config --global alias.d difftool

## diff object

1. git diff sha1 main/origin:
2. git diff --staged // same as : git diff --cached : between cached and commit
2. git diff // between working and staged
2. git diff HEAD// between working and commit(HEAD)

### diff working

	## diff between working and staged
	git diff
	## diff between working and HEAD
	git diff HEAD

### diff staging
	## diff between staged and commit
	git diff --staged // same as : git diff --cached

	## diff working & commit
	git diff HEAD
	git diff HEAD ./lib # diff sub-dir between working & HEAD
	git diff branch1 //diff current branch based on branch1
	git diff branch1 feature//diff feature based on branch1

### diff between commit

	git diff $start_commit $end_commit -- path/to/file
	git diff $start_commit path/to/file
	git diff $start_commit

For instance, to see the difference for a file "main.c" between now and two commits back, here are three equivalent commands:

	$ git diff HEAD^^ HEAD main.c
	$ git diff HEAD^^..HEAD -- main.c
	$ git diff HEAD~2 HEAD -- main.c

> The .. isn't really necessary, though it'll work with it (except in fairly old versions, maybe).
> The -- is useful e.g. when you have a file named -p

Equal:

	HEAD~1 HEAD^	HEAD~
	HEAD~2 HEAD^^	HEAD~~
	HEAD~3
	//refer to # revision

### diff parent

	## diff 2 branch
	git diff master..branch1 #diff branch1 based on The Parent of master&branch1 基于共同祖先做diff, 即得到branch1的变更.

	## The following 3 commands is equal in function.
	git log origin/master..HEAD
	git log ^origin/master HEAD
	git log HEAD --not origin/master

	## 如果你想查找所有从refA或refB包含的但是不被refC包含的提交(A+B-C)
	git log refA refB ^refC
	git log refA refB --not refC

	## 如果你想查 看master或者experiment中包含的但不是两者共有的引用
	$ git log master...experiment //两者的并集再减去交集
	F
	E
	D
	# 这种情形下,log命令的一个常用参数是--left-right,它会显示每个提交到底处于哪一 侧的分支
	$ git log --left-right master...experiment
	<F
	<E
	>D

### diff specify file
> use `git remote update` first

To view the differences going from the remote file to the local file:

	git diff remotename/branchname:remote/path/file1.txt local/path/file1.txt

To view the differences in the other direction:

	git diff HEAD:local/path/file1.txt remotename/branchname:remote/path/file1.txt

Basically you can diff any two files anywhere using this notation:

	git diff ref1:path/to/file1 ref2:path/to/file2

Example:

	"Equal
	git d origin/dev mis/src/model/signcheck.php
	git d origin/dev:mis/src/model/signcheck.php mis/src/model/signcheck.php
	git d origin/dev -- mis/src/model/signcheck.php

	"two commit
	git d origin/dev main/master -- mis/src/model/signcheck.php

## diff output
### git diff file only

	git diff --name-only SHA1 SHA2

where you only need to include enough of the SHA to identify the commits. You can also do, for example

	git diff --name-only HEAD~10 HEAD~5

and filter ACMDR

	git diff-index --cached --name-only --diff-filter=ACMR HEAD
	git diff-index --name-only --diff-filter=ACMR HEAD

shows *what operations were done* to the files too

	git diff --name-status [TAG|SHA1]

### diff fileinfo

	#--stat just print statistic
	git diff master..branch1 --stat

## filter

### filter ACMDR
	git diff-index --diff-filter=ACMR HEAD
	git diff --diff-filter=ACMR HEAD
		A add
		M modified
		C Copied
		R rename
		D delete

### show merged files only

	git diff -m --stat

### check option

	#check white space at the end of line
	git diff --check

## merge-base

	//先找共同祖先
		$ git merge-base branch1 master //find the Parent of branch and master
			bb92d38751bde50b5520a78b82c288fd6edaee9d
	//基于祖先做diff
		// to HEAD
		$ git diff branch1..HEAD
		// to working copy
		$ git diff bb92

# other diff command

## git diff-index
compare a tree to a working tree or index

	# compare index with HEAD
	git diff-index --cached  HEAD
	:100644 100644 9c8caea89aa52f.. 0f92c8e9e1116.. M	path/navMenu.html

	# working tree with HEAD
	git diff-index HEAD

e.g. 

    git diff-index --cached --name-only --diff-filter=ACMR HEAD -- PATH

## diff-tree
git-diff-tree - Compares the content and mode of blobs found via two tree objects

	git diff-tree --name-only -r $oldrev..$newrev