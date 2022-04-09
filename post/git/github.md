---
title: github note
date: 2022-04-09
private: true
---
# github 认证

## 认证email
github 使用email 认证自己的身份

相关配置在：
1. 进入https://github.com/settings/emails
2. 添加email
3. 发送邮件完成验证

### keep my email private
开启了此项后，gihtub.com 会分配一个 假的noreply email. 比如 `178+ahuigo@users.noreply.github.com`
所有的git 操作都应使用这个 noreply email

### 使用认证email

如果keep email private, 则使用noreply email

    git config --global user.email 178+ahuigo@users.noreply.github.com

## 认证状态（verification statuses for all of your commits）
认证状态是认证邮箱不一样。如果要让提交有verified 状态。按这个步骤来

1. https://github.com/settings/keys 
2. 提交gnu key （生成key 见git/gpg.md）
2. Enabling vigilant mode

然后每次提交时：

    $ git commit -S -m "your commit message"

