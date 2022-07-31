---
date: 2014-05-07
title: git hooks
---
# git hooks
钩子(hooks)是一些在$GIT-DIR/hooks目录的脚本, 在被特定的事件(certain points)触发后被调用。当git init命令被调用后, 一些非常有用的示例钩子脚本被拷到新仓库的hooks目录中; 但是在默认情况下它们是不生效的。 把这些钩子文件的".sample"文件名后缀去掉就可以使它们生效。

Useful hooks: 按顺序

    pre-commit
    prepare-commit-msg //.git/COMMIT_EDITMSG
    commit-msg
    post-commit
    post-checkout
    pre-rebase
    pre-push

> Warn: 不要在hooks 操作 submodules 

# applypatch-msg

	GIT_DIR/hooks/applypatch-msg

这个钩子是由git am命令调用的。它只有一个参数：就是存有将要被应用的补丁(patch)的提交消息(commit log message)的文件名。

- 如果钩子的返回值不是0，那么git am就会放弃对补丁的应用(apply the patch)。

这个钩子可以在工作时（也就是在git am运行时）编辑提交(commit)信息文件(message file)。
它的一个用途是把提交(commit)信息规范化，使得其符合一些项目的标准（如果有的话）。它也可以用来在分析(inspect)完消息文件后拒绝某个提交(commit)。

如果默认的applypatch-msg.sample钩子被启用，它会调用commit-msg钩子（如果它也被启用的话）。

# pre-applypatch

	GIT_DIR/hooks/pre-applypatch

这个钩子是由git am命令调用的。它不需要参数，并且是在一个补丁(patch)被应用后还未提交(commit)前被调用。

- 如果钩子的返回值不是`0`，那么刚才应用的补丁(patch)就不会被提交。

它可以用于检查当前的工作树（此时补丁已经被应用但没有被提交），如果补丁不能通过测试就拒绝此次提交(commit)。

如果默认的pre-applypatch.sample钩子被启用，它会调用pre-commit钩子（如果它也被启用的话）。

# post-applypatch

	GIT_DIR/hooks/post-applypatch

这个钩子是由git am命令调用的。它不需要参数，并且是在一个补丁(patch)被应用且在完成提交(commit)情况下被调用。

这个钩子主要用来通知(notification)，它并不会影响git-am的执行结果。

# pre-commit

	GIT_DIR/hooks/pre-commit

这个钩子被 git commit 命令调用, 而且可以通过在命令中添加`--no-verify` 参数来跳过。


# prepare-commit-msg

	GIT_DIR/hooks/prepare-commit-msg

执行git commit命令后，在默认提交消息准备好后但编辑器(editor)启动前，这个钩子就被调用。

它接受一到两个参数。

- 第一个包含了提交消息的文本文件的名字: $1=.git/COMMIT_EDITMSG
- 第二个是提交消息的来源，它可以是：
	* message（如果指定了-m或者-F选项）
	* template（如果指定了-t选项，或者在设置（译注：即git config）中开启了commit.template选项）
	* merge（如果本次提交(commit)是一次合并(merge)，或者存在文件.git/MERGE_MSG）
	* squash（如果存在文件.git/SQUASH_MSG）
	* commit 并且第三个参数是一个提交(commit)的SHA1值（如果指定了-c,-C或者\--amend选项）

这个钩子:
1. 目的是: 用来在工作时编辑信息文件，并且不会被`--no-verify`选项略过。一个非0值意味着钩子工作失败，会终止提交(abort the commit)。它不应该用来作为pre-commit钩子的替代。
2. git提供的样本prepare-commit-msg.sample会把当前合并提交信息(a merge's commit message)中的Conflicts:部分注释掉。

例子:

    .git/hooks/prepare-commit-msg
    .git/COMMIT_EDITMSG

# pre-push

	GIT_DIR/hooks/pre-push

# Server-Side Hooks
执行按顺序：

    pre-receive
    update
    post-receive


## pre-receive
处理来自客户端的推送操作时，最先被调用的脚本是 pre-receive。 
1. 它从标准输入获取一系列被推送的引用: old-sha new-sha branch-name
2. 如果它以非零值退出，所有的推送内容都不会被接受。 你可以用这个钩子阻止对引用进行非快进（non-fast-forward）的更新，或者对该推送所修改的所有引用和文件进行访问控制。

示例：

    $ cat ../g1/.git/hooks/pre-commit
    #!/usr/bin/env bash
    # cat | tee -a ~/pre-commit.stdin
    read oldsha newsha branch
    echo pre-commit-content: $oldsha $newsha $branch
    exit 100

## update
update 脚本和 pre-receive 脚本十分类似，不同之处在于:
1. 它会为每一个准备更新的分支各运行一次。 假如推送者同时向多个分支推送内容，pre-receive 只运行一次，相比之下 update 则会为每一个被推送的分支各运行一次。 
2. 它不会从标准输入读取内容，而是接受三个参数：
    1. 引用的名字（分支），
    2. 推送前的引用指向的内容的 SHA-1 值，
    2. 以及用户准备推送的内容的 SHA-1 值。 
3. 如果 update 脚本以非零值退出，只有相应的那一个引用会被拒绝；其余的依然会被更新。

示例：

    $ cat ../g1/.git/hooks/update
    #!/usr/bin/env bash
    echo branch-name old-sha new-sha: $@ | tee ~/tmp/a.log
    exit 100

    $ git push
    remote: branch-name old-sha new-sha: refs/heads/main 7e223 156e675
    remote: error: hook declined to update refs/heads/main

## post-receive
post-receive 挂钩在整个过程完结以后运行，可以用来更新其他系统服务或者通知用户。 它接受与 pre-receive 相同的标准输入数据。 它的用途包括给某个邮件列表发信，通知持续集成。。。

## pre-receive
[php-lib/git/pre-receive]

	GIT_DIR/hooks/pre-receive

## post-receive
The `post-receive` hook runs after the entire process is completed and can be used to update other services or notify users.

    $ cat ../g1/.git/hooks/post-commit
    #!/usr/bin/env bash
    read oldsha newsha branch
    echo $oldsha $newsha $branch

# 目录限制

    #!/usr/bin/env bash
    echo pre-receive argv: $@ | tee -a ~/tmp/a.log
    read oldsha newsha branch
    if git diff --name-only $oldsha $newsha |grep -E '^tmp/';then
        echo "this dir is not allowed to push"
        exit 101
    fi


# Reference
- [git-scm]: https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks#Server-Side-Hooks
