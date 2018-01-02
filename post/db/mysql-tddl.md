---
layout: page
title:	mysql tddl sequence
category: blog
description: 
---
# Preface

# 如何生成全局id
Refer to: 
http://www.bo56.com/%E6%95%B0%E6%8D%AE%E5%BA%93%E5%88%86%E8%A1%A8%E5%90%8E%EF%BC%8C%E5%B9%B6%E5%8F%91%E7%8E%AF%E5%A2%83%E4%B8%8B%EF%BC%8C%E7%94%9F%E6%88%90%E5%85%A8%E5%B1%80id%E7%94%9F%E6%88%90%E7%9A%84%E5%87%A0%E7%A7%8D/

http://my.oschina.net/u/142836/blog/174465

## CAS(Compare And Swap)
使用CAS, 其实这里并不是严格的CAS，而是使用了比较交换实现原子操作的思想。
每次生成全局id时，先从sequence表中获取当前的全局最大id。然后在获取的全局id上做加1操作。把加1后的值更新到数据库。更新时是关键。

如加1后的值为203,表名是users，数据表结构如下：

	CREATE TABLE `SEQUENCE` (
		`name` varchar(30) NOT NULL COMMENT '分表的表名',
		`gid` bigint(20) NOT NULL COMMENT '最大全局id',
		PRIMARY KEY (`name`)
	) ENGINE=InnoDB 

更新语句是：

	update sequence set gid = 203 where name = 'users' and gid < 203;

不可以用存储例程，它不是atomic 的

	DELIMITER $$
	CREATE PROCEDURE increment_score
	(
	   IN id_in INT
	)
	BEGIN
		UPDATE item SET score = score + 1 WHERE id = id_in;
		SELECT score AS new_score FROM item WHERE id = id_in;
	END
	DELIMITER ;

## 使用全局锁。
Via redis or mysql

## 利用mysql auto_increment
facebook 采用此法
有单点问题: 可以部署N 台mysql, 每台机器生成的id: N*id+n, n 是机器号(0 ~ N-1)

## snowflake 生成唯一id
Twitter在把存储系统从MySQL迁移到Cassandra的过程中由于Cassandra没有顺序ID生成机制，于是自己开发了一套全局唯一ID生成服务：Snowflake。GitHub地址：https://github.com/twitter/snowflake。根据twitter的业务需求，snowflake系统生成64位的ID。由3部分组成：

	41位的时间序列（精确到毫秒，41位的长度可以使用69年）
	10位的机器标识（10位的长度最多支持部署1024个节点）
	12位的计数顺序号（12位的计数顺序号支持每个节点每毫秒产生4096个ID序号）如果序号不够，就等待nextMiliseconds
	最高位是符号位，始终为0。

优点：高性能，低延迟；独立的应用；按时间有序。
缺点：需要独立的开发和部署。没有单点问题

php 实现: https://github.com/ahui132/php-lib/blob/master/id/snowflake.php
