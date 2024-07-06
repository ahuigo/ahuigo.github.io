---
layout: page
title:	linux yum
category: blog
description: 
---
# Preface

# repo

## add repo
sudo rpm -Uvh --force https://mirrors.aliyun.com/centos/7/os/x86_64/Packages/centos-release-7-4.1708.el7.centos.x86_64.rpm

vim /etc/yum.repos.d/MariaDB.repo
```
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.1/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
enabled=1
```

### Iupstream repo
sudo yum -y install https://centos7.iuscommunity.org/ius-release.rpm


## list repo
yum repolist all
yum repolist enabled

## search
search repo by bin

    yum provides javac
    yum provides '*/javac'
    yum provides '*bin/javac'

search repo by pkg

    yum provides mariadb

search repo by so

    $ ldd chrome
    libgtk3.so.0 => not found
    $ yun provides libgit3.so.0

# yum & rpm

## find package
via file

	yum provides `which cmd`
	rpm -qf <file>

via package name

	rpm -qp <package name>

Example:

	yum provides /usr/bin/ab
	yum install httpd-tools

## remove

	rpm -e <package>
	yum remove <package>

# find command

	which nutcracker
	type -a nutcracker

