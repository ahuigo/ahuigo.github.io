# clone
> 不支持 低版本的svn file protocol, use `svn://` or `https://` instead

  $ git svn clone file:///tmp/test-svn -T trunk -b branches -t tags
  $ git svn clone file:///tmp/test-svn -s ; # -s=-T/-b/-t
  $ git svn clone url -s

这相当于针对所提供的 URL 运行了两条命令—— git svn init 加上 git svn fetch 。

  $ git branch -a
  * master
    my-calc-branch
    tags/2.0.2
    tags/release-2.0.1
    tags/release-2.0.2
    tags/release-2.0.2rc1
    trunk

Make your git repository ignore everything the subversion repo does:

    git svn show-ignore >> .git/info/exclude

## git show-ref

  $ git show-ref
  1cbd4904d9982f386d87f88fce1c24ad7c0f0471 refs/heads/master
  aee1ecc26318164f355a883f5d99cff0c852d3c4 refs/remotes/my-calc-branch
  03d09b0e2aad427e34a6d50ff147128e76c0e0f5 refs/remotes/tags/2.0.2
  50d02cc0adc9da4319eeba0900430ba219b9c376 refs/remotes/tags/release-2.0.1
  4caaa711a50c77879a91b8b90380060f672745cb refs/remotes/tags/release-2.0.2
  1c4cb508144c513ff1214c3488abe66dcb92916f refs/remotes/tags/release-2.0.2rc1
  1cbd4904d9982f386d87f88fce1c24ad7c0f0471 refs/remotes/trunk

而普通的 Git 仓库应该是这个模样：

  $ git show-ref
  83e38c7a0af325a9722f2fdc56b10188806d83a1 refs/heads/master
  3e15e38c198baac84223acfc6224bb8b99ff2281 refs/remotes/gitserver/master
  0a30dd3b0c795b80212ae723640d4e5d48cabdff refs/remotes/origin/master
  25812380387fdd55f916652be4881c6f11600d6f refs/remotes/origin/testing

这里有两个远程服务器：一个名为 gitserver ，具有一个 master分支；另一个叫 origin，具有 master 和 testing 两个分支。

## 提交到 Subversion
https://git.wiki.kernel.org/index.php/Git-svn#commit_to_remote_SVN

  $ git commit -am 'Adding git-svn instructions to the README'
  $ git svn dcommit

### commit to local Git
Git automatically tracks contents and therefor automatically detects all changes done with file browsers, programming tools etc.

  git diff
  git add --all
  git diff --cached
  git commit -m "whatebber"

If there is a warning like

   warning: CRLF will be replaced by LF in bladiblu/dir/...
   The file will have its original line endings in your working directory.

consider converting all files to UNIX eol style, here an example for java:

    find . -name \*.java -exec dos2unix --d2u {} \;

If not, and git svn rebase fails because of line endings (true for git <= 1.8.1) see howto's below.

### commit to remote SVN
To see what is going to be committed one can choose the following options.

    gitk git-svn..
    gitk
    git log remotes/git-svn.. --oneline
    git svn dcommit --dry-run

To really commit

    git svn rebase
    git svn dcommit

## pull 拉取最新进展
Use `git svn rebase`, do not not `git pull`!
1. This fetches revisions from the SVN parent of the current HEAD and rebases the current (uncommitted to SVN) work against it.
2. This works similarly to `svn update or git pull` except that it *preserves linear history* with git rebase instead of git merge for ease of dcommitting with git svn.

    $ git svn fetch ; # 不必须
    $ git svn rebase; #include fetch

> Use of git pull or git merge with git svn set-tree A..B will cause non-linear history to be flattened when committing into SVN

# branch

## new branch
`git svn branch [分支名] ：` like ` svn copy trunk branches/dev`

    $ git svn branch dev
    $ svn copy https://xxx.com/svn/project/trunk  https://xxx.com/svn/project/trunk/branches/dev

### -n dry-run

    $ git svn branch -n -m "开发分支" dev
    Copying https://xxx.com/svn/project/trunk at r584 to https://xxx.com/svn/project/trunk/branches/dev..

## switch branch

    git branch dev [remotes/origin/dev]
    git checkout -b mybranch-svn remotes/origin/mybranch

# cmd
类似 git svn log 对 git log 的模拟，svn annotate 的等效命令是 git svn blame [文件名]。其输出如下

## info
git svn info
