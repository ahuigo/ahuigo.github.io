---
layout: page
title: git 使用之日志、数据恢复
category: blog
description:
---
# 日志过滤

## by branch
1. `^` means not in
1. `A..B` means from A to B(exclude A)

	git log [repo/]branch
	git log banch1 branch2 #show commits that both in branch1 and branch2
	git log ^banch1 branch2 #show commits that are not in branch1 but in branch2
	git log banch1 ^branch2 #show commits that are not in branch2 but in branch1
	git log banch1 branch2 ^branch3 #show commits that are not in branch3 but in branch1 or branch2
	git log banch1..branch2 #show commits that are not in branch2 but in branch1

### by range

    git log <since>..<until>


### byt --not branch

	git log <branch> --not <branch2> //show commits of <branch> that not in <branch2>(since <branch2>), same as git log branch ^branch2

## by file

	git log filename

## by limit

	#last 2 comit log
	git log -2

## by author
	--committer
	--author=<pattern>,
		--author='ahuigo'

## by merge
    A0-- A1--A2--A3
      \      /
       --B1--
	git log --merges // 返回所有包含两个父节点的提交: A2
	git log --no-merges //A0,B0,A1,A3
    git log         //all

## by message

    # or
    --grep="msg_pattern1" --grep 'pattern2'

    # and
	--all-match  --grep p1 --grep p2

## by content change

    # 按字符变化匹配: word -> word1，变化的是1, -S‘word’ 不匹配
    -S "word"
    # 按行变化匹配
    -G 'regex'

## by time

### --since(--after)

	//after 2 weeks ago
	--since=2.weeks
	--since='2 years ago'

### --until(--before)

	--since, --after
	--until, --before

### branch with time

	$ git show 12a86bc38 # By revision
	$ git show v1.0.1 # By tag
	$ git show feature132 # By branch name
	$ git show 12a86bc38^ # Parent of a commit
	$ git show 12a86bc38~2 # Grandparent of a commit
	$ git show feature132@{yesterday} # Time relative
	$ git show feature132@{2.hours.ago} # Time relative


## follow all file history(rename)

	git --follow filename
	  Continue listing the history of a file beyond renames (works only for a single file).

## by stat change
    --diff-filter=A 
        Add Rename Del Modified

# output info
## stat

	git log -1 --name-only
	--name-status
        name+status
    --stat
        insert/delete info
    -p
        diff patch info
	git log --name-only --oneline

## --graph

## group by author

    $ git shortlog -12
    ahuigo (12):
      fix symbolic
      fxi title slice
      add blog index
      ....

## author of line last modified(blame)

    git blame filename

### patch diff info
	#'-p' general diff patch
	git log -p -2 [filename]

via gitk

	gitk [filename]

via blame:
To show what revision and author last modified each line of a file(single file):

	git blame filename
	git blame -C filename; # shows which file names the content came from
	git gui blame filename;

## format(--format)
man: git help log

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
        %ai author date
		%s subject

create date:

    git log --diff-filter=A --follow --format=%ai --reverse -- <fname> | head -1

### other

	--shortstat
	--name-only
	--name-status //file list
	--abbrev-commit
	--relative-date
	--pretty //same as --format

## context

    git log -U5
        like: grep -B5 -A5

# git 维护、数据恢复

## git gc
Git 会不定时地自动运行称为 "auto gc" 的命令, 一般有 7,000 个左右的松散对象或是 50 个以上的 packfile， Git 才会真正调用 gc 命令。

手工运行 auto gc 命令：

    $ git gc --auto

gc 还会将所有引用 (references) 并入一个单独文件, 

    $ find .git/refs -type f
    .git/refs/heads/experiment
    .git/refs/heads/master
    .git/refs/tags/v1.0
    .git/refs/tags/v1.1

`git gc` 会让以上文件消失, 这些文件挪到 .git/packed-refs 

    $ cat .git/packed-refs
    cac0cab538b970a37ea1e769cbbde608743bc96d refs/heads/experiment
    ab1afef80fac8e34258ff41fc1b867c702daa24b refs/heads/master
    cac0cab538b970a37ea1e769cbbde608743bc96d refs/tags/v1.0
    9585191f37f7b0fb9444f35a9bf50de191beadc2 refs/tags/v1.1
    ^1a410efbd13591db07496601ebc7a059dd55cfe9  // 以 ^ 开头的行。表示该行上一行的那个标签是一个 annotated 标签

当查找一个引用的 SHA 时，Git 首先在 refs 目录下查找，如果未找到则到 packed-refs 文件中去查找。

## git reflog(数据恢复)
如果hard-reset 一个分支 有什么办法把丢失的 commit 找回来呢？

    git reset --hard HEAD^

git reglog 就可以找到丢失的commit 引用记录

	git reflog //更详尽用 `git log -g`
        c19cfa7 HEAD@{0}: commit: A0
        64c86f6 HEAD@{1}: commit: A1
        3edf2f0 HEAD@{2}: commit: A0
	git branch recovery-branch HEAD@{2}; //HEAD{2} 是引用序，跟HEAD^^/HEAD~2 不是同一个commit

如果 commit 丢失的原因并没有记录在 reflog 中: 可以通过删除 recover-branch 和 reflog 来模拟这种情况。
这样最新的 commit A1 不会被任何东西引用到：

    $ git branch -D recover-branch
    $ rm -Rf .git/logs/

`reflog` 数据是保存在 `.git/logs/` 目录下的，这样就没有 reflog 了. 此时找回commit 就需要`fsck`

## git fsck（数据恢复）
git fsck 工具，该工具会检查仓库的数据完整性。如果指定 --full 选项，该命令显示所有未被其他对象引用 (指向) 的所有对象：

    $ git fsck --full
    dangling blob d670460b4b4aece5915caf5c68d12f560a9fe3e4
    dangling commit ab1afef80fac8e34258ff41fc1b867c702daa24b

最近添加的commit 在 dangling commit, 通过它找到丢失了的 commit

## 移除对象(git filter-branch)
git clone 会将包含每一个文件的所有历史版本的整个项目下载下来. 如果有大文件就影响性能了

    git add bigfile.tgz
    git commit -am 'bigfile.tgz'
    git rm bigfile.tgz
    git commit -am 'rm bigfile.tgz'

Notice: 我们移除对一个大文件的引用ref(commit)，从最早包含该引用的 tree 对象开始之后的所有 commit 对象都会被重写。

先统计空间占用

    $ git count-objects -v
    count: 1
    size: 4
    in-pack: 24
    packs: 1
    size-pack: 3000    //3Mb
    prune-packable: 0
    garbage: 0
    size-garbage: 0

### 识别大文件blob+rev-list
此时:
1. 如果运行 git gc，所有对象(包括大文件对象)会存入一个 packfile 文件；
2. 运行另一个底层命令 git verify-pack 以识别出大对象blob，对输出的第三列信息即文件大小进行排序

e.g.

    git verify-pack -v .git/objects/pack/pack-3f8c0...bb.idx | sort -k 3 -n | tail -3
    e3f094f522629ae358806b17daf78246c27c007b blob   1486 734 4667
    05408d195263d853f09dca71d55116663690c27c blob   12908 3478 1189
    7a9eb2fba2b1811321254ac360970fc169ba2330 blob   2056716 2056872 5401
    # note: pack 包含 blob/tree/commit

最底下blob 的2MB, 查看这到底是哪个大文件，用rev-list 命令。
若给 rev-list 命令传入 --objects 选项，它会列出所有 commit SHA 值，blob SHA 值及相应的文件路径。可以这样查看 blob 的文件名：

    $ git rev-list --objects --all | grep 7a9eb2fb
    7a9eb2fba2b1811321254ac360970fc169ba2330 bigfile.tgz

    $ git show 7a9eb2fb ;//等价于 git show branch:bigfile.tgz

#### top 10 files
    git rev-list --objects --all | grep -f <(git verify-pack -v .git/objects/pack/*.idx| sort -k 3 -n | cut -f 1 -d " " | tail -10)

### 找到commit
很容易找出哪些 commit 修改了这个文件：

    $ git log --pretty=oneline --branches -- bigfile.tgz
    da3f30d019005479c99eb4c3406225613985a1db oops - removed bigfile.tgz
    6df764092f3e7c8f5f94cbe08ee5cf42e92a0289 added bigfile.tgz

### 清理blob+commit
必须重写从 6df76 开始的所有 commit 才能将文件从 Git 历史中完全移除。
用 filter-branch 命令：

    $ git filter-branch --index-filter \
        'git rm --cached --ignore-unmatch bigfile.tgz' -- 6df7640^..
    Rewrite 6df764092f3e7c8f5f94cbe08ee5cf42e92a0289 (1/2)rm 'bigfile.tgz'
    Rewrite da3f30d019005479c99eb4c3406225613985a1db (2/2)
    Ref 'refs/heads/master' was rewritten

note:
1. git rm 的 --ignore-unmatch 选项指定当你试图删除的内容并不存在时不显示错误
2. --index-filter: 要用`git rm --cached`
2. 如果用 --tree-filter: 要用`git rm`
4. `6df7640^..` 指后来的commit.  也可以用`--all`

### 清理ref+打包
commit 中的引用已经被清除, 但是还有一些引用
2. 引用日志: .git/logs
3. filter-branch 往 .git/refs/original 添加的一些 refs 引用，

在重新打包`git gc` 前需要移除任何包含指向那些旧提交的指针的文件

    $ rm -Rf .git/refs/original
    $ rm -Rf .git/logs/
    $ git gc

看下空间: size-pack 缩减到7k, 不过size 还有2M, 因为大文件被移动到松散对象中了。
由于没有引用了，clone/push 都不会用到它了，

    $ git count-objects -v
    size: 2040
    size-pack: 7

如果想清除无引用的松散对象: --expire 选项的 git prune

    $ git prune --expire now

# Reference
- [git-scm]

[git-scm]:https://git-scm.com/book/zh/v1/Git-%E5%86%85%E9%83%A8%E5%8E%9F%E7%90%86-%E7%BB%B4%E6%8A%A4%E5%8F%8A%E6%95%B0%E6%8D%AE%E6%81%A2%E5%A4%8D