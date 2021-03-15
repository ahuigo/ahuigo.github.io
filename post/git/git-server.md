---
title: 搭建 git server
date: 2018-09-27
---
# 搭建 git server
方案参考:
0. git-scm 教程
1. 廖老师的文章在本地建一个git server http://www.liaoxuefeng.com/wiki/0013739516305929606dd18361248578c67b8067c8c017b000/00137583770360579bc4b458f044ce7afed3df579123eca000

## 1.create git user

    sudo adduser git

## 2.创建证书登录
需要收集所有需要登录的用户的公钥，就是他们自己的id_rsa.pub文件，把所有公钥导入到`/home/git/.ssh/authorized_keys`文件里，一行一个。

在用户的local 机器上创建id_rsa.pub

    $ ssh-keygen -t rsa




	$ git clone git@127.0.0.1:/Users/hilojack/www/bat.git

## 管理公钥
如果团队很小，把每个人的公钥(*.pub)收集起来放到服务器的`/home/git/.ssh/authorized_keys` 文件里就是可行的。如果团队有几百号人，就没法这么玩了，这时，可以用Gitosis来管理公钥。

## 管理权限 gitolite
Git也继承了开源社区的精神，自身不支持权限控制。不过，因为Git支持钩子（hook），所以，可以在服务器端编写一系列脚本来控制提交等操作，达到权限控制的目的。Gitolite就是这个工具。