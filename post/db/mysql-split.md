---
layout: page
title:	mysql 分表分库
category: blog
description:
---
# Preface
分表原因

1. 提高sql 执行时间
2. 降低单表表锁、行锁导致的sql 阻塞

# Reference
- mysql 三种分表方法：http://blog.51yip.com/mysql/949.html

# mysql 集群
mysql 集群: mysql cluster, mysql proxy, mysql replication, drdb 等；
集群其实不是分表，但是起到了分表的作用—— 通过分布式为数据库减负

- mysql proxy: 将路由mysql的逻辑, 从业务代码中解耦出来
- MySQL replication: 提供了数据库复制的功能,可以实现多个数据库实时同步

集群特点：

- 优点：扩展性好，没有多个分表后的复杂操作
- 缺点：单个表的数据量还是没有变，一次操作所花的时间还是那么多，硬件开销大。


# 水平分表与垂直分表
分表有两种：

- 水平分表: 根据某一个字段(比如uid) 分表
- 垂直分表: 把一些字段拆分到另一个表，并且该表与原表是一对一的关系。

# merge 合并分表
当水平分表后，可以通过merge 合并分表。这样老代码就不需要改动了！不过，只支持MyISAM, 比较适合读数据，而不适合写数据

# mysql partition
> 链接：https://www.zhihu.com/question/19719997/answer/13545760

根据知友的经验，分区对效率的提升非常小, 只对myisam 有点用(1%~5%), 

- explain parition 时：如果record 在每个分区都有，本质上没有解决读的问题，这样只会提升写的效率。
- 多个index: 如果有多个column 都是查询的index, partion 是很悲剧的

