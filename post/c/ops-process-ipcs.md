---
layout: page
title:
category: blog
description:
---
# Preface
ipcs是Linux下显示进程间通信设施状态的工具。可以显示消息队列、共享内存和信号量的信息

	$ipcs -m 查看系统使用的IPC共享内存资源
	$ipcs -q 查看系统使用的IPC队列资源
	$ipcs -s 查看系统使用的IPC信号量资源

# ipcrm, 清除IPC资源
使用ipcrm 命令来清除IPC资源：这个命令同时会将与ipc对象相关联的数据也一起移除。当然，只有root用户，或者ipc对象的创建者才有这项权利；

ipcrm用法:

	ipcrm -M shmkey  移除用shmkey创建的共享内存段
	ipcrm -m shmid    移除用shmid标识的共享内存段
	ipcrm -Q msgkey  移除用msqkey创建的消息队列
	ipcrm -q msqid  移除用msqid标识的消息队列
	ipcrm -S semkey  移除用semkey创建的信号
	ipcrm -s semid  移除用semid标识的信号
