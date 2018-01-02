---
layout: page
title:	linux yum
category: blog
description: 
---
# Preface

# os version
check os version:

	cat /etc/*-release

	lsb_release -a
	OS=$(lsb_release -si)
	ARCH=$(uname -m | sed 's/x86_//;s/i[3-6]86/32/')
	VER=$(lsb_release -sr)

kernel version:

	 uname -a
	 uname -r
	 uname -mrs

see kernel version and gcc version used to build the same:

	$ cat /proc/version

## cpuinfo
Set process count as cpu cores is a good start:

	# grep -c ^processor /proc/cpuinfo
	worker_processes 2;

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

