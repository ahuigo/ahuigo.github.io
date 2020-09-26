---
title: Redis
date: 2018-09-27
---
# Redis
redis所有的数据都是redisObject存储的。redisObject来表示所有的key/value数据是比较浪费内存的(为了支持各种数据类型嘛)，还好redis 作者也考虑了很多内存优化的方法。

# todo
http://redis.io/
http://redisbook1e.readthedocs.org/en/latest/
https://github.com/springside/springside4/wiki/Redis

# Why Redis
Mysql+Memcached 遇到的问题：

1. Mysql 需要不断分库分表，扩容测试麻烦
2. Memcached 与 Mysql 数据一致性比较麻烦(像网易那样用mysq user define UDF主动trigger 更新Cacher 会涉及到锁机制的问题, 或者用HandlerSocket)

Nosql 的优点：

1. 丰富的数据结构
1. 具备一定的落地功能(始bigsave)和备份功能(binlog)
3. 性能比memcached 高效
4. 分布式和多机房同步(Master-slave)
5. 数据一致性: 主要有dynamo(完全无中心的设计，节点之间通过gossip方式传递集群信息，数据保证最终一致性)
	和 bigtable (一个中心化的方案设计，通过类似一个分布式锁服务来保证强一致性. 数据写入先写内存和redo log 然后定期compat归并到磁盘上，将随机写优化为顺序写，提高写入性能）
6. Schema free，auto-sharding等。比如目前常见的一些文档数据库都是支持schema-free的，直接存储json格式数据，并且支持auto-sharding等功能，比如mongodb。

**Redis 的场景**：

1. 适合key-value 及相关数据类型的热数据（比如计数，排行，pub, 粉丝，评论）. 所以系统并发要求高的，热数据自动续期，冷数据自动淘汰. 或者将冷数据放在持久化的存储引擎中(比如mysql,RocksDB/leveldb)
2. 不适合关系复杂的关系型数据
3. 不适合存储敏感数据：因为落地比如鸡肋，用screenshot 有可能因未到备份时间内丢失新加的数据，用binlog 又浪费硬盘.所以redis 更适合all-in-memory 型的热数据。

> leveldb 也是k-v 数据库，但不会像redis 那样把狂吃内存，而是将大部分数据放到硬盘。

# vs memcached
mc: 多线程，适合小的静态数据进行缓存处理
1. 使用基于Slab的内存管理方式，有利于减少内存碎片和频繁分配销毁内存所带来的开销。
2. 各个Slab按需动态分配一个page的内存（和4Kpage的概念不同，这里默认page为1M），
3. page内部按照不同slab class的尺寸再划分为内存chunk供服务器存储KV键值对使用
4. LRU 
redis: 缓存控制更为出色
2. 单线程，导致所有IO也是串行化的
1. redis 减少网络通讯时间开销 RTT (Round Trip Time)，支持pipeline和script技术。
    1. pipeline 命令打包
    2. redis内嵌了LUA解析器，可以执行lua脚本，
3. 主动LRU/被动

# 集群
mc: 一致性hash算法
redis: 官方推荐是Twitter的开源项目Twemproxy(支持Memcached和Redis协议)


# client

    >>> import redis
    >>> r = redis.StrictRedis(host='localhost', port=6379, db=0,decode_responses=True)
    >>> r.set('foo', 'bar')
    True

# 数据类型
参考 [redis info](http://www.infoq.com/cn/articles/tq-redis-memory-usage-optimization-storage)
![redis db struct](http://blog.nosqlfan.com/wp-content/uploads/2011/05/Image011710.jpeg)

## Type
获取key的存储类型

	TYPE key
	DEL key
	echo Redis::REDIS_STRING."\n";//1
	echo Redis::REDIS_SET."\n";//2
	echo Redis::REDIS_LIST."\n";//3
	echo Redis::REDIS_ZSET."\n";//4
	echo Redis::REDIS_HASH."\n";
	echo Redis::REDIS_NOT_FOUND;

## String

	set key v
	get key

String在redis内部存储默认就是一个字符串，被redisObject所引用，当遇到incr,decr等操作时会转成数值型进行计算，此时redisObject的encoding字段为int。

    incr key
    incrby key 2
    incrbyfloat key 2.2
    decr key 1

## Expire

	EXPIRE key 10 (10s)
	TTL key #获取key 的剩余有效时间(s)
	PTTL key #获取key 的剩余有效时间(ms)

## Hashes 哈希
- hash map :reids 内部实现的hash其实就是哈希结构。可以说String 只是控制一级key-v, 而Hash则是二层key-v
- 重复的key:使用redis hash 可以避免使用"user:name" 而导致的重复存储相同的user
- 存储实现(zipmap-> HashMap):Redis Hash对应Value内部实际就是一个HashMap，实际这里会有2种不同实现，这个Hash的成员比较少时Redis为了节省内存会采用类似一维数组的方式来紧凑存储，而不会采用真正的HashMap结构，对应的value redisObject的encoding为zipmap,当成员数量增大时会自动转成真正的HashMap,此时encoding为ht。

Hash 命令

	hset key field  value
	hget key field
	hmget key field1 field2
	HVALS key #所有值
	HKEYS key #所有key
	HGETALL key #所有key
	HLEN key #field 数量

hincr

    hincrby key field 2
    hincrbyfloat key field 2.2

Iterate hash:

	HSCAN key cursor [MATCH pattern] [COUNT count]

#### LinkedHashMap
其实就是支持遍历的有序hash, 每个节点有prev+next

    map{
        *head->node
        length
        *end->node
    }
    node{
        key
        value
        *prev
        *next
    };

hash table collision handling, if `hash(key1)==hash(key2)==5`

        +------------------------------------------+
        |                                          |
    [index1, index2, index3, ....], [node1, node2,node3,.....]
        +-----------------------------------+   +--+
        |                                   |   |  |
    [index1, index2, index3, ....], [node1, node2,node3,.....]

    map{head:null, length:0, end:null}
    hash(key1)=5
        index1 = index_table[5]
        node3 = node_table[index1]
        node3.key = key1
        map.end = node3
        map.length++

    hash(key2)=5
        index1 = index_table[5]
        node3 = node_table[index1]
        if node3.key != key2:
            # find an empty node sush as: node2
            node2.next = *node3
            node2.key = key2
            index_table[5] = *node2

        map.end = node2
        map.length++

## List
- 队列结构: lpush rpush. 相当于数组
- 存储结构：Redis list的实现为一个双向链表


	redis> RPUSH mylist "one"
	(integer) 1
	redis> RPUSH mylist "two"
	(integer) 2
	redis> RPUSH mylist "three"
	(integer) 3
	redis> LPOP mylist
	"one"
	redis> LRANGE mylist 0 -1
	1) "two"
	2) "three"
	redis> LRANGE mylist start end(include end)

Removes and returns the last element of the list stored at key.

	>RPOP mylist
	"three"

### list type

FIFO: lpop + rpush
LIFO: rpush + rpop

### list other

RPUSH:
Insert all the specified values at the tail of the list stored at key. If key does not exist, it is created as empty list before performing the push operation. When key holds a value that is not a list, an error is returned.

	RPUSH key value [value ...]

RPUSHX:  only if key already exists

	RPUSHX key value


BLPOP is a blocking list pop primitive. It is the blocking version of LPOP because it blocks the connection when there are no elements to pop from any of the given lists.
An element is popped from the head of the first list that is non-empty, with the given keys being checked in the order that they are given.

	BLPOP key [key ...] timeout


## Sets 无序集合
- 它和List的不同在于：不允许出现相同的元素,
- 与Hash 不同在于: 它只是一层value_list, 而不是field_list
- 存储结构:set 的内部实现是一个 value永远为null的HashMap，实际就是通过计算hash的方式来快速排重的，这也是set能提供判断一个成员是否在集合内的原因。

Sets:

	sadd key value
	smembers

## Sorted Sets 有序集合
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
		member 相同, 则替换原来的member

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

## 其它功能
聚合计算、pubsub、scripting

# Server 命令

## redis-server

	redis-server --help
	Usage: ./redis-server [/path/to/6379.conf] [options]
		   ./redis-server --test-memory <megabytes>

## info
查看server 信息

## client connect

	$r = new Redis;
	$r->connect('127.0.0.1', 6379);
	$r->auth('password');
	$r->ping();// '+PONG' on success. false on timeout, RedisException on connection close
	php > echo $r->set('a',json_encode(['a'=>2]));
	1
	php > var_dump(json_decode($r->get('a'),true));
	array(1) {
	  ["a"]=>
	  int(2)
	}

	$r->bgSave()
	$r->close();

### timeout

	# php-redis.ini
	session.save_handler = redis
	## default connection timeout is 86400
	session.save_path = "tcp://host1:6379?weight=1, tcp://host2:6379?weight=2&timeout=2.5, tcp://host3:6379?weight=2"
	session.persistent = 0

### ping

	$redis->ping() === '+PONG'

## Flush

	FLUSHDB       - Removes data from your connection's CURRENT database.
	FLUSHALL      - Removes data from ALL databases.

## keys

	keys *
	keys *user*
	keys ttt_user_???

## cursor

	SCAN cursor [MATCH pattern] [COUNT count]

SCAN 命令及其相关的 SSCAN 命令、 HSCAN 命令和 ZSCAN 命令都用于增量地迭代（incrementally iterate）一集元素（a collection of elements）：

	SCAN 命令用于迭代当前数据库中的数据库键。
	SSCAN 命令用于迭代*集合键*中的元素。
	HSCAN 命令用于迭代*哈希键*中的键值对。
	ZSCAN 命令用于迭代*有序集合*中的元素（包括元素成员和元素分值）。

### cursor count
返回数据集最大数量
While SCAN does not provide guarantees about the number of elements returned at every iteration,
https://github.com/antirez/redis/issues/1723

### cursor guarantees, 保证
在进行完整遍历的情况下可以为用户带来以下保证：

	1. 从完整遍历开始直到完整遍历结束期间， 一直存在于数据集内的所有元素都会被完整遍历返回；

然而因为增量式命令仅仅使用游标来记录迭代状态， 所以这些命令带有以下缺点：

	1. 同一个元素可能会被返回多次。 可以考虑将迭代返回的元素仅仅用于可以安全地重复执行多次的操作上。
	2. 如果一个元素是在迭代过程中被添加到数据集的， 又或者是在迭代过程中从数据集中被删除的， 那么这个元素可能会被返回， 也可能不会，（undefined）。

### match
match 使用`glob` 语法
hscan match 的是key 不是Value

	hscan k2  0 match key_prefix* count 100

### valid cursor
使用间断的（broken）、负数、超出范围或者其他非正常的游标来执行增量式迭代并不会造成服务器崩溃， 但可能会让命令产生未定义的行为。

只有两种游标是合法的：

	在开始一个新的迭代时， 游标必须为 0 。
	增量式迭代命令在执行之后返回的， 用于延续（continue）迭代过程的游标。如果返回的是为0, 那么迭代结束


# 事务
http://www.cnblogs.com/stephen-liu74/archive/2012/02/18/2357783.html

# 分布式k-v
RebornDB：下一代分布式Key-Value数据库架构介绍
http://mp.weixin.qq.com/s?__biz=MzAwNjMxNjQzNA==&mid=208050108&idx=1&sn=05f972ab35726fcaa0fc3a8c4e9a33f8&scene=1&from=groupmessage&isappinstalled=0#rd

# References
- [深入理解Redis主键失效原理及实现机制][key expire]

[key expire]: http://blog.nosqlfan.com/html/4218.html