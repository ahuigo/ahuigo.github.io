---
layout: page
title:
category: blog
description:
---
# Preface

# start redis

## init.d

	[root@web ~]# /etc/init.d/redis start

## manual

	启动
	# redis-server /etc/redis.conf

	关闭(向server 发出shutdown)
	# redis-cli shutdown

	关闭某个端口上的redis
	# redis-cli -p 6379 shutdown

on mac

	brew services start redis
	brew services stop redis
	brew services restart redis
