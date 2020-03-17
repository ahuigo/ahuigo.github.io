---
layout: page
title: ops-device
category: blog
description: 
date: 2018-09-27
---
# Preface

# cpu

## proc/

	grep -c ^processor /proc/cpuinfo

## lscpu

	lscpu | grep -E ^(?<=CPU\(s\))

# mac
https://support.apple.com/zh-cn/HT202013

## System Information, 系统概述
方法是在“实用工具”文件夹中找到它（如果在 Finder 中，则选取前往 > 实用工具）或者在按住 Option 键的同时点按 Apple 菜单并选取系统概述。

### Network
Airport 或者以太网

	Wifi(Airport), Device Name:en0

# 查询硬件信息
> sysctl -a hw

查看CPU使用情况:

	$sar -u 5 10

查询CPU信息:

	$cat /proc/cpuinfo

    # mac
    $ sysctl -n machdep.cpu.brand_string

查看CPU的核的个数:

	$cat /proc/cpuinfo | grep processor | wc -l

查看内存信息:

	$cat /proc/meminfo

显示内存page大小（以KByte为单位）:

	$pagesize

显示架构:

	$arch

Reference:
http://linuxtools-rst.readthedocs.org/zh_CN/latest/base/09_system_manage.html