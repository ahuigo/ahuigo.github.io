---
layout: page
title: Git 命令大全
category: blog
description: Abstract of git commmands.
---
# Git 配置

## ConfigFile
1. /etc/gitconfig #git config --system
2. ~/.gitconfig 	#git config --global
3. working/.git/config	#git config

## user, editor, email

	## User
	git config --global user.name 'ahuigo'
	git config --global user.email	xxx@gmail.com

	## Core.Editor
	git config --global core.editor vim
	git config --global core.symlinks false

## alias

	git config --global alias.ci commit
	git config --global alias.unstage 'reset HEAD'

## Merge tool

	git config --global merge.tool vimdiff
	git config --global mergetool.keepBackup false //Do not create backed file *.orig

> You can set your loved tool, such as kdiff3,tkdiff,meld,xxdiff,emerge,gvimdiff,opendiff,etc.

	## config Command
	git config --list #list configration
	git config user.name #query a item

	## set color
	git config --global color.diff auto // git diff 要顯示顏色
	git config --global color.status auto // git status 要顯示顏色
	git config --global color.branch auto
	git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'"

## Help

	git help config
	man git-config

## debug

### verbose

    export GIT_CURL_VERBOSE=1

## git auth
### git https
Put this in your ~/.netrc and it won't ask for your username/password (at least on Linux and Mac):

	machine github.com
		   login <user>
		   password <password>

or:

	git remote set-url origin https://name:password@github.org/repo.git

## git ssh
生活在墙内的我们或者使用代理的朋友难免会遇到:`error:14090086:SSL routines:SSL3_GET_SERVER_CERTIFICATE:certificate verify failed while accessing https://github.com/zsh-users/zsh/info/refs?service=git-upload-pack`. 如果只是想用git clone, 最方便的方法是忽略SSL：

	export GIT_SSL_NO_VERIFY=1
    //or
    git config http.sslVerify false

### 使用代理时的ssh
参考: [ssl github](http://stackoverflow.com/questions/3777075/ssl-certificate-rejected-trying-to-access-github-over-https-behind-firewall)
执行下列命令，或者编辑`~/.git/config`：

    "add proxy
    git config [--global] http.proxy http://proxyuser:proxypwd@proxy.server.com:8080
    git config [--global] https.proxy http://proxyuser:proxypwd@proxy.server.com:8080
    //or
    export http_proxy=http://user:pwd@host:port
    "unset proxy
    git config [--global] unset https.proxy

socks5、 socks5h(host 解析) proxy

    git config --global http.proxy socks5h://127.0.0.1:1080
    git config --global http.proxy socks5://127.0.0.1:1080
    ALL_PROXY=socks5://127.0.0.1:1080 git clone https://github.com/some/one.git

specify domain:

    git config --global https."https://golang.org".proxy socks5://127.0.0.1:1080
    git config --global https.proxy socks5://127.0.0.1:1080

with go get （git config 有点问题）:

    HTTP_PROXY=socks5://127.0.0.1:1080 go get  github.com/gin-gonic/gin

## git status

	git status -s

# Repository

## init

	git init //create .git
	git init --bare // create bare repository

## git clone repository

	git clone url //=== git init +git fetch
	git clone https://username:password@github.com/username/repository.git

if 401

	git clone https://username@github.com/org/project.git


## export repo sub folder
This creates an empty repository with your remote, and fetches `-f` all objects but doesn't check them out. 

    git init
    git remote add -f origin <url>

    git config core.sparseCheckout true

Now you need to define which files/folders you want to actually check out. 

    echo "some/dir/" >> .git/info/sparse-checkout
    echo "another/sub/tree" >> .git/info/sparse-checkout
    git pull origin master


# git clean
clean files

	git clean " clean untracked files only
        -X  "ignore only
        -x  "ignore and untrack
        -d  "directory
        -f  "force
        -n -f " with check

If you want to also remove *directories*, run

	git clean -f -d or git clean -fd

# file status convert

## stage status

### add stage(working to stage)


## rm

	#(rm file from working & staged)
	git rm <file> //rm file from working & stage

	#(rm file from staged)
	git rm --cached <file> //rm file from stage only

	#rm file recurse
	git rm log/\*~  //recurse

# modify

## modify commit messages

	git commit --amend -m 'new messages'
	git commit --amend -m 'new messages' --author 'ahuigo'

## git revert
    C1->C2->C3->B2C3->C5->C6->C7->HEAD
      |-B2->B2/

git revert -m1 B2C3 创建了新分支: `HEAD-(B2-C3)`
git revert -m2 B2C3 创建了新分支: `HEAD-(C3-C2)`

    C1->C2->C3->C4->C5->C6->C7->HEAD

git revert C3 会创建新分支: `HEAD-(C3-C2)`

恢复到HEAD 之前的提交:

	git revert HEAD //Creat a new commit to drop HEAD's modifies. '
        相当于merge HEAD^ based on HEAD: 
        git checkout HEAD^ . ; // copy HEAD^ -> working === index 
            git checkout . ; // copy index -> working
        git commit -m 'rever version xxx'

    # merge parent based on HEAD^^
	git revert HEAD^^ -m 1
	git revert A2 -m 1

        git log --graph
        A0 -- A1 -- A2 -- A3 -- A4(HEAD)
         \        /      
          B0-----B1

        -m 1 :merge A1 (Base on A2)
        -m 2 :merge B1 (Base on A2)

> Note: git revert is used to record some new commits to reverse the effect of some earlier commits (often only a faulty one).

# git add

	git add <file> //stage file(Untracked file is also included )
	git add -i //interactive
	git add -u //添加已经track的文件，而非新加的文件

checkout 适合working 回滚到某一分支
- git revert: checkout+add+commit
    - git revert [倒数第一个提交] [倒数第二个提交]
	Revert some existing commits
- git reset: 改变commit+index: 顺便清理working
 	rollback commit: (clean index)
- git checkout(改变working, 保留index/commit)
	git checkout HEAD^ .
	working copy from index(priority) or switch to commit(without file)

## .gitignore

    !application/

    application/*
    !application/language/

    application/language/*
    !application/language/gr/


## git unadd(git reset)

	git reset file
	working copy `merge` from commit(Should No working copy or index change)

## git commit(stage to commited)

	git commit -m 'comment' //commited file
	#auto stage when commit
	git commit -a -m 'auto stage(except untracked file) '

### git checkout revert

	// not switch branch if following `dir` or `file`
	git checkout HEAD^ .

## ignore filemode

	git config --global core.filemode false
	git config --unset --global core.filemode

## git reset
> untracked file will be keeped(even with --hard)

Undoing a commit is a little scary if you don't know how it works. But it's actually amazingly easy if you do understand.

Say you have this, where C is your HEAD and (F) is the state of your files.

	   (F)
	A-B-C
		↑
	  master

You want to nuke commit C and never see it again.

### git reset hard(commit/index/working)
`--hard` You do this:

	git reset --hard B;	# same: git reset HEAD . --hard
	git reset --hard HEAD~1 (revert commit/index/working)
		clean unstaged/staged files

The result is:

	 (F:working)
	A-B
	  ↑
	master

### git reset(commit+index)
undo commit -am 'msg'

	git reset ;	# same as: git reset HEAD .
	git reset HEAD~1 

In this case the result is:

	   (F(working)) 
	A-B-C
	  ↑
	master: lost index+commit

### git reset soft(commit)
undo commit

	   (F(working))
	A-B-C
	  ↑ ↑(index)
	master
	git reset --soft HEAD~1 (commit) (保留working and stage index)
	git update-ref refs/heads/master SHA; # 指定其它分支
	git update-ref refs/heads/master HEAD~1; # 指定其它分支, HEAD是当前分支的SHA

# git checkout

## switch branch
不能有overwritten: index/working/untracked 

    git checkout [-b] <branch>
	-b new_branch
		Create a new branch named <new_branch> and start it at <start_point>
		git checkout [-b] <branch>
		git checkout [-b] <new_branch> [<start_point>]
		git checkout -b test origin/test //tracking branch
	-t, --track
		git checkout -b master upstream/master, //tracking branch
		git checkout -b master -t upstream/master, //tracking branch

##	checkout(index/working)
override: index -> working

    git checkout -- .

override: index+working

    git checkout HEAD -- .

# git diff
[/p/git-diff](/p/git-diff)

# git log
[/p/git-log](/p/git-log)

# SHA revision
Here are some revision types:SHA-1, short SHA-1,

## SHA-1

## short SHA-1

	git log --abbrev-commit

## branch's revision '
如果你想知道某个分支指向哪个特定的 SHA

	git rev-parse <branch>
	git rev-parse head
	2af3fsdfwe324

## parent commit revision

	git log HEAD^  or git log HEAD~ //parent commit,父提交
	git log HEAD^^ or git log HEAD~~ or git log HEAD~2 //父提交的父提交
	git log HEAD~<num> //第<num>个父提交

	git log HEAD^2 //follow the other parent upwards.(仅用于merged commit) 它会指向第2个合并分支
	git log HEAD^1 //follow the first parent upwards.(仅用于merged commit) 它会指向第1个合并分支, 这是默认的

    G   H   I   J
    \ /     \ /
    D   E   F
    \  |  / \
        \ | /   |
        \|/    |
        B     C
        \   /
            \ /
            A

    A =      = A^0
    B = A^   = A^1     = A~1
    C = A^2  = A^2
    D = A^^  = A^1^1   = A~2
    E = B^2  = A^^2
    F = B^3  = A^^3
    G = A^^^ = A^1^1^1 = A~3
    H = D^2  = B^^2    = A^^^2  = A~2^2
    I = F^   = B^3^    = A^^3^
    J = F^2  = B^3^2   = A^^3^2

## HEAD
HEAD 指向当前分支引用的revision

	git log HEAD
	git log HEAD@{2} != HEAD~2
	git show HEAD@{2}

查看昨天分支指向哪里

	git show HEAD@{yesterday}

# git remote

## add/rm/rename

	git remote add shortname url
	git remote set-url shortname url
	git remote rm shortname
	git remote rename shortnameA shortnameB

Example:

	git remote add origin ssh://git@ahuigo.github.io:ahuigo/wiki.git
	git remote add upstream https://github.com/octocat/Spoon-Knife.git
    git -C "/usr/local/Homebrew" remote set-url origin https://github.com/Homebrew/brew.git

## show remote

	git remote -v
	git remote show <remote-name> //origin

# git show(svn cat, git cat)
git show specify commit

	git show $REV:$FILE
	git show somebranch:from/the/root/myfile.txt
	git show HEAD^^^:test/test.py

## show remote

    git show origin/dev:go.sum

## show commit diff
	git show $REV [FILE]
    git show head
    git show head file.txt
    git show head^ file.txt
	git show --name-only SHA1

# git tag
tag 相当于commit 的别名

## list tag

	git tag
	git tag -l 'v1.*'

## del tag

    # git push origin :tagname
    git push --delete origin tagname
    git push origin :refs/tags/<tagname>
    # git tag -d tagname
    git tag --delete tagname

## add tag

### add lighted tag

	git tag v1.4 [<commit>]

### add annotated tag

	git tag -a v1.4 -m 'fix bug'

### add tag for a commit

	git tag -a v1.4 <commit>

### add -s (-signed) tag

	git tag -s v1.4 -m 'fix'
	#add tag for a commit
	git tag -a v1.5 9fceb	//revision 9fceb

## verify signature tag

	git tag -v v1.4

## push tag
tag 是绑定在`当前`commit上的，但是默认push不会将tag 推到远端.

###  push a tag

	git push origin <tagname>
	git push origin v1.4

### push all tag

    # push commit + tags
    git push --follow-tags origin

    # push tags only
	git push --tags
	git push origin --tags

# git describe
找到离HEAD最近的tag

	git describe [<object>] //list annotated tags
	git describe --tags //list unannotated tags

Output:

	<tag>_<numCommits>_g<hash>
	Where tag is the closest ancestor tag in history, numCommits is how many commits away that tag is, and <hash> is the hash of the commit being described.

# git archive
Create an archive of files from a named tree.

	git archive <object> --prefix='project/' | gzip > `git describe master`.tar.gz
	git archive --format=tar.gz --prefix='project/' <object> > `git describe`.tar.gz

# git branch

## rename branch

	git branch -m new_name;# rename current branch
	git branch -m <oldname> <newname>

## list branch

	git branch
	git branch -v #more detail
	git branch -va #more branch
    git branch -r, --remotes
               List or delete (if used with -d) the remote-tracking branches.

### merge status

	git branch --merged
	git branch --no-merged //the branch not merged

## add/del branch

	git branch <branchName>		//add
	git branch <new_branch> [<start-point>] //new_branch started from <start_point>
	git branch -d <branchName> //del
	git branch -D <branchName> //Force Del

## move branch to commit

	git branch -f <branch> <commit> //move branch to commit(HEAD必须与master分离)

# git fetch

	git fetch //fetch all repos
	git fetch <repo> //fetch all branch on remote <repo>
	git fetch <repo> <source> // fetch <source> to local <repo>/<source>
	git fetch <repo> <source>:<destination> // fetch <source> to local <destination> . <destination> 不能是checked状态, 这会改变本地的分支,

# git push

	git push <repo> <local_branch>[:remote_branch]
	git push origin master:test
	git push . master:test  #.代表upstream origin?

    # git push -f git@github.com:<USERNAME>/<REPO>.git master:gh-pages

## push all remote

    git push --all origin
    git push origin

## push buffer
> `git config http.postBuffer 5242880000` 设置push 时的大小限制, 否则会报 The remote end hung up unexpectedly。 还有一个原因是服务端限制

	http {
    	# ...
		client_max_body_size 1G;

还有可能是没有加`repository.git`

## push branch
push 时，remote 必须存在相应的branch, 比如master. 否则会报: No refs in common and none specified; doing nothing.

此时应该指定此branch:

	git push -u origin master
		-u add upstream (tracking) reference
	[branch "master"]
		remote = origin
		merge = refs/heads/master

	//or
	git branch -u origin/master master
	git checkout -tb new_feature_name origin/new_feature_name

untrack

	git branch --unset-upstream

## default branch
Push all branches

    git config --global push.default matching

Push only the current branch

    git config --global push.default simple

push all branch

    git push --all

## DNS SPOOFING DETECTED
WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!
Remove host:

	ssh-keygen -f ~/.ssh/known_hosts -R gitlab.site.org

Ignore HostKey

	$ vim ~/.ssh/config
	Host github.com-ahuigo
		HostName github.com
		User git
		StrictHostKeyChecking no

    $ ssh github.com-ahuigo

## del remote branch

	git push origin :test

## push add upstream (tracking) reference,
Add upstream (tracking) reference:

	git push -u origin master

# git merge

	git merge <branch>
	git merge origin/test
	git merge origin test
	git merge origin

merge old, keeping "our" (master's) content

    git merge -s ours old-master

## merge abort
git merge --abort is equivalent to git reset --merge when MERGE_HEAD is present.

    git merge --abort
    git reset --merge

or:

    git reset --hard HEAD

## merge other remote
Step 1. Fetch other code

	git fetch origin master

Step 2. Merge the branch and push the changes to GitLab

	git merge other/master
	git mergetool
	git push

Also, you can use pull directly:

	git pull origin master
	git pull origin 
	git pull 


## merge strategy(before)

    -s, --strategy
        resolve     This resolves cases with only two heads,
        octopus     This resolves cases with more than two heads,
        recursive   This can only resolve two heads using a 3-way merge algorithm
            -X <options>     this strategy can take merge-options:
                ours
                theirs
                patience
                ignore-space-change
        ours        This resolves any number of heads

e.g.

    # 直接用自己的
        git pull -s ours   
    # recursive 冲突时才用自己的
        git pull -s recursive -Xours  
        git pull -Xours   # 默认-s recursive

用别人的:

    git pull -s recursive -Xtheirs origin dev

## merge strategy(after)
to keep the remote or local file, :

	git checkout --theirs /path/to/file
	git checkout --ours /path/to/file
### option

	git merge --no-commits //告诉 Git 此时无需自动生成和记录(合并)提交.最后一起提交
	git merge --squash //选项将目标分支上的所有更改全拿来应用到当前分支上

### git pull

	git pull //auto fetch and merge the newest vertion of remote branch
	git pull --rebase //auto fetch and rebase the newest vertion of remote branch
	git pull <shortname> [<branch>]
	git pull <repository> [<branch>]

Set default pull branch

	branch.master.remote = origin
	branch.master.merge = refs/heads/master

    git config branch.master.remote origin
    git config branch.master.merge refs/heads/master

You can do this with a single command:

	git branch --track master origin/master
    // or auto setup
    git config --global branch.autoSetupMerge always

### Solove Conflicts
Use vimdiff(Default)

	git config --global merge.tool vimdiff
	git config --global mergetool.prompt false
	git config --global mergetool.keepBackup false

start vimdiff

	$ git mergetool

Vim's operation:

	]c [c "jump in conflict blocks
	:diffg RE  " get from REMOTE
	:diffg BA  " get from BASE
	:diffg LO  " get from LOCAL

> Use `v` to select all, then use `diffg LO` to replace current block from LO. A better way is `:%diffg LO`, `:%diffput Working`

# git stash
现在你想切换分支或者pull，但是你还不想提交你正在进行中的工作；所以你储藏这些变更。

为了往堆栈推送一个新的储藏，只要运行 git stash：

	$ git stash
	Saved working directory and index state WIP on master: bb6dd9c haha
	HEAD is now at bb6dd9c haha
	(To restore them type "git stash apply")

这时，你可以方便地切换到其他分支工作；你的变更都保存在栈上。要查看现有的储藏，你可以使用 git stash list：

	$ git stash list
	stash@{0}: WIP on master: bb6dd9c commit_msg1
	stash@{1}: WIP on master: xbx6d1z commit_msg2
	(两次stash)

	$ git stash show -p stash@{0}
	diff --git a/a.txt b/a.txt
	index e69de29..589fc73 100644
	--- a/a.txt
	+++ b/a.txt
	@@ -0,0 +1 @@
	+stash

在其它分支切换回来后，想恢复这个暂存的变更. 当然，你也可以在其它分支应用这个暂存变更(如果变更无法应用git 会给出归并冲突的提示)

	//
	git stash apply stash@{0}
	git stash apply

	//应用变更时清空暂存
	git stash pop stash@{0}
	git stash pop

## git stash drop

	git stash drop stash@{0}
	git stash drop //remove stash@{0}

	git stash clear //remove all

## 取消储藏(Un-applying a Stash)

# git rebase branch

	git rebase <branchA> //rebase current branch,based on branchA
	git rebase <onto branch> <branch>
	git rebase -i master
	git rebase -i <branchA> //rebase current branch, base on branchA (interactively)
	git rebase --onto master branchA branchB //rebase branchB(but keep commits from branchA being committed), base on master.

If u have conflict files:

	git mergetool //resolve conficts
    git checkout --ours -- <filename>
    git checkout --theirs -- <filename>
	git add -u
	git rebase --continue //It will commit automatic.

If u want to restart rebasing and do not want any current file patch

	git rebase --skip
		Restart the rebasing process by skipping the current patch.

# cherry-pick
git cherry-pick命令"复制"一个提交节点并在当前分支做一次完全一样的新提交。

    $ git cherry-pick 2c33a

To cherry-pick all the commits from commit A to commit B (where A is older than B), run:

    git cherry-pick A^..B

If you want to ignore A itself, run:

    git cherry-pick A..B


# git hub
hub is a command-line wrapper for git that makes you better at GitHub.
https://hub.github.com/
