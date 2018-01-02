---
layout: page
title:
category: blog
description:
---
# Preface

	#commit log
	git log

# filter log

## sepecify branch
1. `^` means not in
1. `A..B` means from A to B(exclude A)

	git log [repo/]branch
	git log banch1 branch2 #show commits that both in branch1 and branch2
	git log ^banch1 branch2 #show commits that are not in branch1 but in branch2
	git log banch1 ^branch2 #show commits that are not in branch2 but in branch1
	git log banch1 branch2 ^branch3 #show commits that are not in branch3 but in branch1 or branch2
	git log banch1..branch2 #show commits that are not in branch2 but in branch1

Remember that your clone of the repository will update its state of any remote branches only by doing git fetch. You can't connect directly to the server to check the log there, what you do is download the state of the server with git fetch and then locally see the log of the remote branches.

Perhaps another useful command could be:

	git log HEAD..remote/branch

which will show you the commits that are in the remote branch, but not in your current branch (HEAD).

### --not

	git log <branch> --not <branch2> //show commits of <branch> that not in <branch2>(since <branch2>), same as git log branch ^branch2

## filter file

	git log filename

## limit

	#last 2 comit log
	git log -2

### --since(--after)

	//after 2 weeks ago
	--since=2.weeks
	--since='2 years ago'

### other

	--since, --after
	--until, --before
	--author=<pattern>,
		--author='hilojack'
	--committer
	--no-merges
	--all-match

### parent

	$ git show 12a86bc38 # By revision
	$ git show v1.0.1 # By tag
	$ git show feature132 # By branch name
	$ git show 12a86bc38^ # Parent of a commit
	$ git show 12a86bc38~2 # Grandparent of a commit
	$ git show feature132@{yesterday} # Time relative
	$ git show feature132@{2.hours.ago} # Time relative

# info

## show reflog

	git log -g

## show merges

	git log --merges //Print only merge commits. This is exactly the same as --min-parents
	git log --no-merges //Do not print commits with more than one parent. This is exactly the same as --max-parents=1.

## file info

### list file
like svn log -v

	git log -1 --name-only
	git log -1 --name-status
	git log -1 --stat
	git log --name-only --oneline

list all merge file: -m

	git log -1 -m --stat
	git log -m -1

### file patch
via -p

	#'-p' general diff patch
	git log -p -2 [filename]

via gitk

	gitk [filename]

via blame:
To show what revision and author last modified each line of a file(single file):

	git blame filename
	git blame -C filename; # shows which file names the content came from
	git gui blame filename;

### follow all file history

	git --follow -p -- filename
	 --follow
	  Continue listing the history of a file beyond renames (works only for a single file).

## format(--format)

	--format=oneline|short|full|fuller
		--oneline
	--format="%h - %an,$ar"
		%H commit hash
		%h abbreviation commit hash
		%T tree hash
		%t abbreviated tree hash
		%P parent hash
		%p abbreviated parent hash
		%an author name
		%ae author email
		%ad author date
		%ar author date(relative)
		%cn committer name(relative)
		%s subject

### other

	--shortstat
	--name-only
	--name-status //file list
	--abbrev-commit
	--relative-date
	--pretty //same as --format

## merge info

	--graph //merge tree log info
    -m
        see from sha1

example

    commit f514219(from be6fe4d)
    Merge: be6fe4d 89ac1b8

    commit f514219(from 89ac1b8)
    Merge: be6fe4d 89ac1b8

## log context

	-U<n>, --unified=<n>
           Generate diffs with <n> lines of context instead of the usual three

# other log

## shortlog

	git shortlog [<object>]
	git shortlog <object> --not <object>

## git reflog
引用日志：HEAD指向的日志

	git reflog //same as `git log -g`
	c19cfa7 HEAD@{0}: commit: add css:blockquote
	64c86f6 HEAD@{1}: commit: add a line
	git show HEAD@{2}

