---
title: redis zset
date: 2021-07-07
private: true
---
# Sorted Sets 有序集合
实现方式:
	Redis sorted set的内部使用HashMap和跳跃表(SkipList)来保证数据的存储和有序，

sorted set的实现是这样的：

1. 当数据较少时，sorted set是由一个ziplist来实现的。
   1. ziplist是一个表（list），但其实不是一个链表（linked list）
   2. 普通的双向链表，地址不连续会带来大量的内存碎片，指针也会占用额外的内存
   2. 存储字符串或整数，其中整数是按真正的二进制表示进行编码的
2. 当数据多的时候，sorted set是由一个dict + 一个skiplist来实现的。简单来讲，dict用来查询数据到分数的对应关系，而skiplist用来根据分数查询数据（可能是范围查找）
    - HashMap里放的是成员到score的映射(hash(member) -&gt; score)，
    - 而跳跃表里存放的是集合元素的指针(sorted score -> member)。

有序集合每个元素的成员都是一个字符串对象， 而每个元素的分值都是一个 double 类型的浮点数。 

有序数组(元素长度有限制，可只保存指针, 插入删除O(N), 查询O(logN))， 有序链表(不适合按score 查询插入O(N), 不支持二分查询)
跳跳表是插入查询的拆中，但实现*比平衡树*简单。

	ZADD key score member [score member ...]
		member 相同, 则替换原来的score

	redis> ZADD myzset 1 "one"
	(integer) 1
	redis> ZADD myzset 1 "uno"
	(integer) 1
	redis> ZADD myzset 2 "two"
	(integer) 1
	redis> ZADD myzset 3 "two"
	(integer) 0
	redis> ZRANGE myzset 0 -1 WITHSCORES
	1) "one"
	2) "1"
	3) "uno"
	4) "1"
	5) "two"
	6) "3"

zrange: log(N) + M

	# zrange start stop 指定位置范围(从0开始) [start stop] #include stop
	# zrangebyscrore min max 指定分数范围
	# zrevrange start=0 stop 倒序
	# zrevrangebyscrore [ max min] 指定分数范围

zcount: log(N)

	ZCOUNT myzset -inf +inf
	ZCOUNT myzset (1 3; >1 <=3

### zddd 命令
    ZADD key [NX|XX] [CH] [INCR] score member [score member ...]

1. XX: Only update elements that already exist. Never add elements.
1. NX: Don't update already existing elements. Always add new elements.
1. CH: Count changed elements. By default, ZADD only counts the number of new elements added.
1. INCR: When this option is specified `ZADD` acts like `ZINCRBY`. Only `one score-element pair` can be specified in this mode.

### Rem
sorted sets remove:

	zRem key member1 member2 ...
	zRemRangeByRank key start stop
	zRemRangeByScore key min max
