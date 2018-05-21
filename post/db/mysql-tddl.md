---
layout: page
title:	mysql tddl sequence
category: blog
description: 
---
# 如何生成全局id

1. 单点:
	1. mysql auto_increment
	2. redis incrnx
2. 分布:
	1. stepN: 可以部署N 台mysql, 每台机器生成的id: N*id+n, n 是机器号(0 ~ N-1)
		1. snowflake

## snowflake 生成唯一id
Twitter在把存储系统从MySQL迁移到Cassandra的过程中由于Cassandra没有顺序ID生成机制，于是自己开发了一套全局唯一ID生成服务：Snowflake。GitHub地址：https://github.com/twitter/snowflake。根据twitter的业务需求，snowflake系统生成64位的ID。由3部分组成：

	41位的时间序列（精确到毫秒，41位的长度可以使用69年）
	10位的机器标识（10位的长度最多支持部署1024个节点）
	12位的计数顺序号（12位的计数顺序号支持每个节点每毫秒产生4096个ID序号）如果序号不够，就等待nextMiliseconds
	最高位是符号位，始终为0。

php 实现: https://github.com/ahuigo/php-lib/blob/master/id/snowflake.php
