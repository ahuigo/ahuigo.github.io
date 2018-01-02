---
layout: page
title:
category: blog
description:
---
# Preface

# 查询硬件信息
> sysctl -a hw

查看CPU使用情况:

	$sar -u 5 10

查询CPU信息:

	$cat /proc/cpuinfo

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
