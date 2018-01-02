---
layout: page
title:
category: blog
description:
---
# Preface
钩子(hooks)是一些在$GIT-DIR/hooks目录的脚本, 在被特定的事件(certain points)触发后被调用。当git init命令被调用后, 一些非常有用的示例钩子脚本被拷到新仓库的hooks目录中; 但是在默认情况下它们是不生效的。 把这些钩子文件的".sample"文件名后缀去掉就可以使它们生效。

# TODO & Reference
- [git-scm]: https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks#Server-Side-Hooks
- [gitbook]: http://gitbook.liuhui998.com/5_8.html

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

这个钩子被 git commit 命令调用, 而且可以通过在命令中添加`--no-verify` 参数来跳过。这个钩子不需要参数，在得到提交消息和开始提交(commit)前被调用。如果钩子返回值不是0，那么 git commit 命令就会中止执行。

如果（进行git commit的）命令没有制定一个编辑器来修改提交信息(commit message)，任何的 git-commit 钩子（译注：即无论是否自带）被调用时都会带上环境变量GIT_EDITOR=:

# prepare-commit-msg

	GIT_DIR/hooks/prepare-commit-msg

执行git commit命令后，在默认提交消息准备好后但编辑器(editor)启动前，这个钩子就被调用。

它接受一到三个参数。

- 第一个包含了提交消息的文本文件的名字。
- 第二个是提交消息的来源，它可以是：
	* message（如果指定了-m或者-F选项）
	* template（如果指定了-t选项，或者在设置（译注：即git config）中开启了commit.template选项）
	* merge（如果本次提交(commit)是一次合并(merge)，或者存在文件.git/MERGE_MSG）
	* squash（如果存在文件.git/SQUASH_MSG）
	* commit 并且第三个参数是一个提交(commit)的SHA1值（如果指定了-c,-C或者\--amend选项）

这个钩子的目的是:
	用来在工作时编辑信息文件，并且不会被`--no-verify`选项略过。一个非0值意味着钩子工作失败，会终止提交(abort the commit)。它不应该用来作为pre-commit钩子的替代。

> git提供的样本prepare-commit-msg.sample会把当前合并提交信息(a merge's commit message)中的Conflicts:部分注释掉。

# pre-push

	GIT_DIR/hooks/pre-push

# Server-Side Hooks

## pre-receive
[php-lib/git/pre-receive]

	GIT_DIR/hooks/pre-receive

## post-receive
The `post-receive` hook runs after the entire process is completed and can be used to update other services or notify users. 
