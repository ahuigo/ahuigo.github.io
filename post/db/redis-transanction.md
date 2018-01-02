---
layout: page
title:
category: blog
description:
---
# Preface

MULTI 、 EXEC 、 DISCARD 和 WATCH 是 Redis 事务的基础。

- MULTI     开启一个事务
- EXEC      命令负责触发并执行事务中的所有命令：
- DISCARD   放弃事务
- WATCH

当使用 AOF 方式做持久化的时候， Redis 会使用单个 write(2) 命令将事务写入到磁盘中。

1. AOF 事务命令记录 可能因进程kill 或硬件原因导致记录不完整
2. Redis 在重新启动时, 会因这种AOF 错误退出
3. redis-check-aof 程序可以修复这一问题：它会移除 AOF 文件中不完整事务的信息，确保服务器可以顺利启动。

Redis>2.2 可以通过乐观锁（optimistic lock）实现 CAS （check-and-set）操作，具体信息请参考文档的后半部分

# EXEC 使用事务
事务中所有的命令要先入队(QUEUED)
EXEC 执行每个命令

    > MULTI
    OK

    > INCR foo
    QUEUED

    > INCR bar
    QUEUED

    > EXEC
    1) (integer) 1
    2) (integer) 1

# 事务错误
分两种：
1. 事务EXEC执行前的错误：语法错误、更严重的内存不足
    redis服务器会对`入队失败`的错误进行记录，`EXEC`时拒绝执行并放弃事务
2. EXEC 后的错误
    并没有对命令错误进行特别处理： 即使事务中有某个/某些命令在执行时产生了错误， 事务中的其他命令仍然会继续执行。

发生在EXEC 后的错误：第一条ok 第二条-ERR

    MULTI
    +OK

    SET a 3
    abc

    +QUEUED
    LPOP a

    +QUEUED
    EXEC

    *2
    +OK
    -ERR Operation against a key holding the wrong kind of value

# Rollback
为什么 Redis 不支持回滚（roll back） 以下是这种做法的优点：
Redis 选择了更简单、更快速的无回滚方式来处理事务

# DISCARD 放弃事务
当执行 DISCARD 命令时， 事务会被放弃， 事务队列会被清空， 并且客户端会从事务状态中退出：

    redis> SET foo 1
    OK

    redis> MULTI
    OK

    redis> INCR foo
    QUEUED

    redis> DISCARD
    OK

    redis> GET foo
    "1"

# WATCH

## 使用 check-and-set 操作实现乐观锁
> redis 的exec执行时，其涉及的key 可能被别人改变，所以它本身不保证操作的原子性

有了 WATCH ， 我们就能保证操作的原子性了:
    WATCH 命令可以为 Redis 事务提供 check-and-set （CAS）行为。

1. 被 WATCH 的键会被监视，如果有至少一个被监视的键在 EXEC 执行之前被修改了， 那么执行exec 时：整个事务都会被取消
2. EXEC 返回空多条批量回复（null multi-bulk reply）来表示事务已经失败。
3. 当 EXEC 被调用时，对所有键的监视都会被取消

这种形式的锁被称作乐观锁: 乐观的认为键通常不会被改变, 大家可以并行操作，如果真的遇到键被改变了我们就重试

    WATCH mykey

    val = GET mykey
    val = val + 1

    MULTI
    SET mykey $val
    EXEC

WATCH 命令可以被调用多次
    还可以在单个 WATCH 命令中监视任意多个键， 就像这样：

    redis> WATCH key1 key2 key3
    OK

如果exec 时，key 改变了：

    127.0.0.1:6379> multi
    (error) ERR MULTI calls can not be nested

## zpop
用事务实现ZPOP

    WATCH zset
    element = ZRANGE ZSET 0 0
    MULTI
        ZREM zset element
    EXEC

# Redis 脚本
Lua 脚本功能是 Reids 2.6 版本的最大亮点， 通过内嵌对 Lua 环境的支持:
1. Redis 解决了长久以来不能高效地处理 CAS （check-and-set）命令的缺点， 并且可以通过组合使用多个命令， 轻松实现以前很难实现或者不能高效实现的模式。
2. 代替事物、更高效、简单


# Reference
- [redis-transaction]

[redis-transaction]: http://redisdoc.com/topic/transaction.html
