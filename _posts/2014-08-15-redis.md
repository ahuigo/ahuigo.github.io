---
layout: page
title:	redis 使用简记
category: blog
description:
---
# Preface
redis所有的数据都是redisObject存储的。redisObject来表示所有的key/value数据是比较浪费内存的(为了支持各种数据类型嘛)，还好redis 作者也考虑了很多内存优化的方法。

# todo
http://redisbook.com/
http://redisbook1e.readthedocs.org/en/latest/
https://github.com/springside/springside4/wiki/Redis

# Why Redis
Refer: [](http://www.infoq.com/cn/articles/tq-why-choose-redis)

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

# 数据类型实现
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

Iterate hash:

	HSCAN key cursor [MATCH pattern] [COUNT count]

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

- HashMap里放的是成员到score的映射(hash(member) -&gt; score)，
- 而跳跃表里存放的是集合元素的指针(指向member/score)。每个跳跃表节点都保存了一个集合元素： 跳跃表节点的 object 属性保存了元素的成员， 而跳跃表节点的 score 属性则保存了元素的分值;每个集合元素使用两个紧挨在一起的压缩列表节点来保存， 第一个节点保存元素的成员（member）， 而第二个元素则保存元素的分值（score）。 插入排序依据是HashMap里存的score,使用跳跃表的结构可以获得比较高的查找效率，并且在实现上比较简单。

> 有序集合每个元素的成员都是一个字符串对象， 而每个元素的分值都是一个 double 类型的浮点数。 值得一提的是， 虽然 zset 结构同时使用跳跃表和字典来保存有序集合元素， 但这两种数据结构都会通过指针来共享相同元素的成员和分值， 所以同时使用跳跃表和字典来保存集合元素不会产生任何重复成员或者分值， 也不会因此而浪费额外的内存。

有序数组(元素长度有限制，可只保存指针, 插入删除O(N), 查询O(logN))， 有序链表(不适合按score 查询插入O(N), 不支持二分查询)
跳跳表是插入查询的拆中，但实现比平衡树简单。

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


### Rem
sorted sets remove:

	zRem key member1 member2 ...
	zRemRangeByRank key start stop
	zRemRangeByScore key min max

## 其它功能
聚合计算、pubsub、scripting

# 内存优化
- redis实际上的内存管理成本非常高

## 要不要开VM
首先最重要的一点是不要开启Redis的VM选项，即虚拟内存功能，这个本来是作为Redis存储超出物理内存数据的一种数据在内存与磁盘换入换出的一个持久化策略，但是其内存管理成本也非常的高，并且我们后续会分析此种持久化策略并不成熟，所以要关闭VM功能，请检查你的redis.conf文件中 vm-enabled 为 no。

## MaxMemory
其次最好设置下redis.conf中的maxmemory选项，该选项是告诉Redis当使用了多少物理内存后就开始拒绝后续的写入请求，该参数能很好的保护好你的Redis不会因为使用了过多的物理内存而导致swap,最终严重影响性能甚至崩溃

## 存储结构(zipmap->HashMap)参数
另外Redis为不同数据类型分别提供了一组参数来控制内存使用，我们在前面详细分析过Redis Hash是value内部为一个HashMap，如果该Map的成员数比较少，则会采用类似一维线性的紧凑格式来存储该Map, 即省去了大量指针的内存开销，这个参数控制对应在redis.conf配置文件中下面2项：

	hash-max-zipmap-entries 64
	hash-max-zipmap-value 512

当hash的条数（64）/值长度(512) 超过限制时，就使用HashMap.
zipmap 不同于HashMap, hashMap 查找插入时间是O(1), zipmap 只是普通的线性表，当数据增加后，性能会严重下降。

还有：

	#说明：list数据类型多少节点以下会采用去指针的紧凑存储格式。
	list-max-ziplist-entries 512

	#说明：list数据类型节点值大小小于多少字节会采用紧凑存储格式。
	list-max-ziplist-value 64

	#说明：set数据类型内部数据如果全部是数值型，且包含多少节点以下会采用紧凑格式存储。
	set-max-intset-entries 512

## 共享数值
如果在Redis内部存储的大部分数据是数值型的话，Redis内部采用了一个shared integer的方式来省去分配内存的开销，即在系统启动时先分配一个从1~n 那么多个数值对象放在一个池子中，如果存储的数据恰好是这个数值范围内的数据，则直接从池子里取出该对象，并且通过引用计数的方式来共享，这样在系统存储了大量数值下，也能一定程度上节省内存并且提高性能，这个参数值n的设置需要修改源代码中的一行宏定义REDIS_SHARED_INTEGERS，该值默认是10000，可以根据自己的需要进行修改，修改后重新编译就可以了。

	REDIS_SHARED_INTEGERS = 10000

# persistence 持久化
Refer to:
1. http://justjavac.com/nosql/2012/04/13/redis-persistence-demystified.html
2. https://github.com/antirez/redis-doc/blob/master/topics/persistence.md
3. http://ifeve.com/redis-persistence/

Redis由于支持非常丰富的内存数据结构类型，如何把这些复杂的内存组织方式持久化到磁盘上是一个难题，所以Redis的持久化方式与传统数据库的方式有比较多的差别，Redis一共支持四种持久化方式，分别是：

- 定时快照方式(snapshot)
- 基于语句追加文件的方式(aof)
- 虚拟内存(vm)(已经放弃)
- Diskstore方式

在设计思路上，前两种是基于全部数据都在内存中，即小数据量下提供磁盘落地功能，而后两种方式则是作者在尝试存储数据超过物理内存时，即大数据量的数据存储，截止到本文，后两种持久化方式仍然是在实验阶段，并且vm方式基本已经被作者放弃，所以实际能在生产环境用的只有前两种，换句话说Redis目前还只能作为小数据量存储（全部数据能够加载在内存中），海量数据存储方面并不是Redis所擅长的领域。下面分别介绍下这几种持久化方式：

## snapshot 定时快照方式
该持久化方式实际是在Redis内部一个定时器事件，每隔固定时间去检查当前数据发生的改变次数与时间是否满足配置的持久化触发的条件，如果满足则通过操作系统fork调用来创建出一个子进程，这个子进程默认会与父进程共享相同的地址空间，这时就可以通过子进程来遍历整个内存来进行存储操作，而主进程则仍然可以提供服务，当有写入时由操作系统按照内存页(page)为单位来进行copy-on-write保证父子进程之间不会互相影响。

该持久化的主要缺点是定时快照只是代表一段时间内的内存映像，所以系统重启会丢失上次快照与重启之间所有的数据。

## aof 基于语句追加方式(binlog)
aof方式实际类似mysql的基于语句的binlog方式，即每条会使Redis内存数据发生改变的命令都会追加到一个log文件中，也就是说这个log文件就是Redis的持久化数据。

aof的方式的主要缺点是追加log文件可能导致体积过大，当系统重启恢复数据时如果是aof的方式则加载数据会非常慢，几十G的数据可能需要几小时才能加载完，当然这个耗时并不是因为磁盘文件读取速度慢，而是由于读取的所有命令都要在内存中执行一遍。另外由于每条命令都要写log,所以使用aof的方式，Redis的读写性能也会有所下降。

## vm 虚拟内存方式
虚拟内存方式是Redis来进行用户空间的数据换入换出的一个策略，此种方式在实现的效果上比较差，主要问题是代码复杂，重启慢，复制慢等等，目前已经被作者放弃。

## diskstore方式：
diskstore方式是作者放弃了虚拟内存方式后选择的一种新的实现方式，也就是传统的B-tree的方式，目前仍在实验阶段，后续是否可用我们可以拭目以待。

*持久化磁盘IO方式*

有Redis线上运维经验的人会发现Redis在物理内存使用比较多，但还没有超过实际物理内存总容量时就会发生不稳定甚至崩溃的问题，有人认为是基于快照方式持久化的fork系统调用造成内存占用加倍而导致的，这种观点是不准确的，因为fork 调用的copy-on-write机制是基于操作系统页这个单位的，也就是只有有写入的脏页会被复制，但是一般你的系统不会在短时间内所有的页都发生了写入而导致复制，那么是什么原因导致Redis崩溃的呢？

答案是Redis的持久化使用了Buffer IO造成的，所谓Buffer IO是指Redis对持久化文件的写入和读取操作都会使用物理内存的Page Cache,而大多数数据库系统会使用Direct IO来绕过这层Page Cache并自行维护一个数据的Cache，而当Redis的持久化文件过大(尤其是快照文件)，并对其进行读写时，磁盘文件中的数据都会被加载到物理内存中作为操作系统对该文件的一层Cache,而这层Cache的数据与Redis内存中管理的数据实际是重复存储的，虽然内核在物理内存紧张时会做Page Cache的剔除工作，但内核很可能认为某块Page Cache更重要，而让你的进程开始Swap ,这时你的系统就会开始出现不稳定或者崩溃了。我们的经验是当你的Redis物理内存使用超过内存总容量的3/5时就会开始比较危险了。

## 总结

- 根据业务需要选择合适的数据类型，并为不同的应用场景设置相应的紧凑存储参数。
- 当业务场景不需要数据持久化时，关闭所有的持久化方式可以获得最佳的性能以及最大的内存使用量。
- 如果需要使用持久化，根据是否可以容忍重启丢失部分数据在快照方式与语句追加方式之间选择其一，不要使用虚拟内存以及diskstore方式。
- 不要让你的redis所在机器物理内存使用超过实际内存总量的3/5。

# master-slave 主从同步
参考:[陌陌redis 实践](http://blog.codingnow.com/2014/03/mmzb_redis.html)

## bgsave 避免同步进程并发
redis 做同步时，一定要避免多台slave 同时在master 上fork 出多个进程做同步。这样会导致，master 同时运行多个进程而内存不足（master 的内存进入交换区的概率大增加）。
应该用脚本保证进程的顺序性(轮流同步)。

## 用脚本控制冷备的时间
错开 BGSAVE 的 IO 高峰期。

## 足够的内存
防止同步过程中，copy 文件时耗空cache

## 改用aof
主从同步比较浪费空间(每次同步都会将内存存盘). 改用AOF 的话，也会有信息冗余（浪费硬盘）.

可以换一个思路：完全放弃redis 的可持久化，放弃BGSAVE 和 AOF, 持久化交给mysql/unqlite

# expire key redis 主键失效原理及实现机制
本小节原文：[redis expire 机制](http://blog.nosqlfan.com/html/4218.html)

## 失效时间的控制
Redis的key 失效时间会受到命令的影响吗？当然了

- 首先，在通过 DEL 命令删除一个主键时，失效时间自然会被撤销
- 其次，在一个设置了失效时间的主键被更新覆盖时，该主键的失效时间也会被撤销。但需要注意的是，这里所说的是主键被更新覆盖，而不是主键对应的 Value 被更新覆盖，因此 SET、MSET 或者是 GETSET 可能会导致主键被更新覆盖，而像 INCR、DECR、LPUSH、HSET 等都是更新主键对应的值，这类操作是不会触碰主键的失效时间的。
- 此外，还有一个特殊的命令就是 RENAME，当我们使用 RENAME 对一个主键进行重命名后，之前关联的失效时间会自动传递给新的主键，但是如果一个主键是被RENAME所覆盖的话（如主键 hello 可能会被命令 RENAME world hello 所覆盖），这时被覆盖主键的失效时间会被自动撤销，而新的主键则继续保持原来主键的特性。

## 失效的内部实现
Redis 删除失效主键的方法主要有两种：

- 消极方法（passive way），在主键被访问时如果发现它已经失效，那么就删除它
- 积极方法（active way），周期性地从设置了失效时间的主键中选择一部分失效的主键删除
- 主动删除：当前已用内存超过maxmemory限定时，触发主动清理策略，该策略由启动参数的配置决定

主键具体的失效时间全部都维护在expires这个字典表中。

	typedef struct redisDb {
		dict *dict; //key-value
		dict *expires;  //维护过期key
		dict *blocking_keys;
		dict *ready_keys;
		dict *watched_keys;
		int id;
	} redisDb;

### passive way 消极方法
- 在passive way 中， redis在实现GET、MGET、HGET、LRANGE等所有涉及到读取数据的命令时都会调用 expireIfNeeded，它存在的意义就是在读取数据之前先检查一下它有没有失效，如果失效了就删除它。
- expireIfNeeded函数中调用的另外一个函数propagateExpire，这个函数用来在正式删除失效主键之前广播这个主键已经失效的信息，这个信息会传播到两个目的地：
1. 一个是发送到AOF文件，将删除失效主键的这一操作以DEL Key的标准命令格式记录下来；
2. 另一个就是发送到当前Redis服务器的所有Slave，同样将删除失效主键的这一操作以DEL Key的标准命令格式告知这些Slave删除各自的失效主键。从中我们可以知道，所有作为Slave来运行的Redis服务器并不需要通过消极方法来删除失效主键，它们只需要对Master唯命是从就OK了！

代码段二：

	int expireIfNeeded(redisDb *db, robj *key) {
		获取主键的失效时间
		long long when = getExpire(db,key);
		假如失效时间为负数，说明该主键未设置失效时间（失效时间默认为-1），直接返回0
		if (when < 0) return 0;
		假如Redis服务器正在从RDB文件中加载数据，暂时不进行失效主键的删除，直接返回0
		if (server.loading) return 0;
		假如当前的Redis服务器是作为Slave运行的，那么不进行失效主键的删除，因为Slave
		上失效主键的删除是由Master来控制的，但是这里会将主键的失效时间与当前时间进行
		一下对比，以告知调用者指定的主键是否已经失效了
		if (server.masterhost != NULL) {
			return mstime() > when;
		}
		如果以上条件都不满足，就将主键的失效时间与当前时间进行对比，如果发现指定的主键
		还未失效就直接返回0
		if (mstime() <= when) return 0;
		如果发现主键确实已经失效了，那么首先更新关于失效主键的统计个数，然后将该主键失
		效的信息进行广播，最后将该主键从数据库中删除
		server.stat_expiredkeys++;
		propagateExpire(db,key);
		return dbDelete(db,key);
	}

	void propagateExpire(redisDb *db, robj *key) {
		robj *argv[2];
		shared.del是在Redis服务器启动之初就已经初始化好的一个常用Redis对象，即DEL命令
		argv[0] = shared.del;
		argv[1] = key;
		incrRefCount(argv[0]);
		incrRefCount(argv[1]);
		检查Redis服务器是否开启了AOF，如果开启了就为失效主键记录一条DEL日志
		if (server.aof_state != REDIS_AOF_OFF)
			feedAppendOnlyFile(server.delCommand,db->id,argv,2);
		检查Redis服务器是否拥有Slave，如果是就向所有Slave发送DEL失效主键的命令，这就是
		上面expireIfNeeded函数中发现自己是Slave时无需主动删除失效主键的原因了，因为它
		只需听从Master发送过来的命令就OK了
		if (listLength(server.slaves))
			replicationFeedSlaves(server.slaves,db->id,argv,2);
		decrRefCount(argv[0]);
		decrRefCount(argv[1]);
	}

### Active Way
消极方法的缺点是，如果key 迟迟不被访问，就会占用很多内存空间. 所以就产生的积极的方式(Active Way)：此方法利用了redis的时间事件，即每隔一段时间就中断一下完成一些指定操作，其中就包括检查并删除失效主键。

* 时间事件

创建时间事件, 回调函数就是serverCron，它在Redis服务器启动时创建，每秒的执行次数由宏定义REDIS_DEFAULT_HZ来指定，默认每秒钟执行10次。


* 使用activeExpireCycle 清除失效key

其实现原理是从Redis中每个数据库的expires字典表中，随机抽样REDIS_EXPIRELOOKUPS_PER_CRON（默认值为10）个设置了失效时间的主键，检查它们是否已经失效并删除掉失效的主键，如果失效主键个数占本次抽样个数的比例超过25%，它会继续进行下一轮的随机抽样和删除，直到刚才的比例低于25%才停止对当前数据库的处理，转向下一个数据库。

> 注意，activeExpireCycle函数不会试图一次性处理Redis中的所有数据库，而是最多只处理REDIS_DBCRON_DBS_PER_CALL（默认值为16），此外activeExpireCycle函数还有处理时间上的限制，不是想执行多久就执行多久，凡此种种都只有一个目的，那就是避免失效主键删除占用过多的CPU资源。


## Memcached删除失效主键的方法与Redis有何异同？
首先，Memcached在删除失效主键时采用的是消极方法
其次，Memcached与Redis在主键失效机制上的最大不同是，Memcached不会像Redis那样真正地去删除失效的主键，而只是简单地将失效主键占用的空间回收。直到有新数据要写入时，才复用失效空间。
LRU内存回收: 如果空间用光了，Memcached还可以通过LRU机制来回收那些长期得不到访问的空间。

Redis在出现OOM时同样可以通过配置maxmemory-policy这个参数来决定是否采用LRU机制来回收内存空间(放到硬盘)

## LRU算法
LRU是Least Recently Used最近最少使用算法。源于操作系统使用的一种算法，对于在内存中但最近又不用的数据块叫做LRU，操作系统会将那些属于LRU的数据移出内存，从而腾出空间来加载另外的数据。
算法：对key 按失效时间排序，然后取最先失效的key
还有一种FIFO（先入先出）算法: 只适用expire_time = current_time + valid_time(固定) 的情况，这样就可以避免对key 进行expire_time 排序了（它本来就是有序的）

## Redis的主键失效机制会不会影响系统性能？
当然了，所以我们要合理设定:
- 每次处理数据库个数的限制、
- activeExpireCycle函数在一秒钟内执行次数的限制
- 分配给activeExpireCycle函数CPU时间的限制
- 继续删除主键的失效主键数百分比的限制

Redis已经大大降低了主键失效机制对系统整体性能的影响，但是如果在实际应用中出现大量主键在短时间内同时失效的情况还是会使得系统的响应能力降低，所以这种情况无疑应该避免。

# Server 命令

## redis-server

	redis-server --help
	Usage: ./redis-server [/path/to/redis.conf] [options]
		   ./redis-server - (read config from stdin)
		   ./redis-server -v or --version
		   ./redis-server -h or --help
		   ./redis-server --test-memory <megabytes>

	Examples:
		   ./redis-server (run the server with default conf)
		   ./redis-server /etc/redis/6379.conf
		   ./redis-server --port 7777
		   ./redis-server --port 7777 --slaveof 127.0.0.1 8888
		   ./redis-server /etc/myredis.conf --loglevel verbose

	Sentinel mode:
		   ./redis-server /etc/sentinel.conf --sentinel

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
	SSCAN 命令用于迭代集合键中的元素。
	HSCAN 命令用于迭代哈希键中的键值对。
	ZSCAN 命令用于迭代有序集合中的元素（包括元素成员和元素分值）。

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

# Reference
- [深入理解Redis主键失效原理及实现机制][key expire]

[key expire]: http://blog.nosqlfan.com/html/4218.html
