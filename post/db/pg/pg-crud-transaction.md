---
title: pg transaction
date: 2021-05-20
private: true
---
# Preface
## 锁与事务、隔离级别
- 事务: 是一组需要作为一个整体执行的 SQL 操作,要么全部成功，要么全部失败. 原子性、一致性、隔离性和持久性（ACID）
    - 如果不加BEGIN, 就是一次性事务的锁（隐式事务，自动commit）
- 锁: 事务中获取的所有锁（无论是显式获取的还是由 PostgreSQL 自动获取的）都会在事务结束时自动释放
- 事务隔离级别：决定了事务中的操作如何与其他并发事务中的操作交互. 分为读未提交、读已提交、可重复读和串行化。

# 锁的类型
## 默认锁
select　默认无锁，不会获取锁，不受for share, for update 影响

    select * from stocks where condition; 

下文会介绍, update 自动会获取排它锁(row Exclusive lock):

    update 会被其它语句select for update, 以及select for share 阻塞

## 共享锁(for share: row share lock)
pg 共享锁（Share Locks）：这种锁允许多个事务同时读取同一行数据，但阻止任何事务修改数据（包括获取排他锁）。

    BEGIN;
    select * from stocks where price<20 for share;
    -- 其他操作...
    COMMIT;

如果其它语句在write 以上满足条件的行, 那么以上语句会补阻塞，为了避免补阻塞，可以写：

    select * from stocks where price<20 for share SKIP LOCKED;


### 共享更新排他锁（Share Update Exclusive Locks）
这种锁阻止其他事务同时执行相同类型的 ALTER TABLE 语句. 但是不阻止读

    BEGIN;
    ALTER TABLE your_table SET (fillfactor = 70);
    -- 其他操作...
    COMMIT;


## 排他锁（Exclusive Locks）
在 PostgreSQL 中，可以通过 LOCK TABLE 命令或者在修改数据的语句（如 UPDATE、DELETE 或 INSERT）中隐式地获取 ExclusiveLock。以下是一些示例：

### For update 排它锁(Row Exclusive Lock)
for update 锁阻止其他事务读read或write 同一行数据

    BEGIN;
        SELECT * FROM your_table WHERE condition FOR UPDATE;
        -- 其他操作...
    COMMIT;

如果满足以上condition的行正在被别的sql读写，那么以上语句会被阻塞，如果想跳过阻塞的话，就加 SKIP LOCKED

        SELECT * FROM your_table WHERE condition FOR UPDATE SKIP LOCKED;


### Update 排他锁（Row Exclusive Locks）
下面的 UPDATE 语句中，PostgreSQL 也会为被修改的行获取 Row ExclusiveLock。
这个锁同样会在事务结束后释放，释放前其它的共享锁

    BEGIN;
    UPDATE table_name SET column = value WHERE some_column = some_value;
    -- 更多的 SQL 操作
    COMMIT;

### 访问排他锁（Access Exclusive Locks）
这是最重量级的锁，它阻止其他事务读取或修改表。当你执行 ALTER TABLE、DROP TABLE 或 TRUNCATE 等修改表结构的语句时,

它会阻止其他事务读取或修改 your_table。这个锁会一直持续到当前事务结束


    BEGIN;
    ALTER TABLE your_table DROP COLUMN column_name;
    -- 其他操作...
    COMMIT;

### LOCK TABLE (table lock)
lock table 命令显式获取 Table ExclusiveLock , 只有当事务结束 (COMMIT 或 ROLLBACK) 的时候，才会释放这个锁。

    BEGIN;
    LOCK TABLE table_name IN EXCLUSIVE MODE;
    -- 你的 SQL 操作
    COMMIT;

# 锁的管理
## 查看所有行锁
    SELECT
        a.datname,
        l.relation::regclass AS "table",
        a.state,
        a.query,
        l.transactionid,
        l.mode,
        l.GRANTED,
        a.usename,
        a.query_start,
        age(now(), a.query_start) AS "age",
        a.pid
    FROM
        pg_stat_activity a
    JOIN
        pg_locks l ON l.pid = a.pid
    WHERE
        l.mode in ('RowShareLock','ExclusiveLock');

输出示例：

    table| state|     query                        |     mode 
    stocks| idle |LOCK TABLE stocks IN EXCLUSIVE MODE;| ExclusiveLock

Note:
> 在 pg_stat_activity.state 列可以告诉我们当前查询的状态: idel/active/...
> age 计算时间差

## current transaction is aborted
当发生问题却没有rollback 就会这样，比如

    ```shell
    ahuigo=#  CREATE TABLE t1 ( id serial PRIMARY KEY);
    ahuigo=# begin;
    BEGIN
    ahuigo=*# insert into t1 values(1);
    INSERT 0 1
    ahuigo=*# select * from t1;
    id 
    ----+-----
    1 
    (1 row)

    ahuigo=*# insert into t1 values(1);
    ERROR:  duplicate key value violates unique constraint "t1_pkey"
    DETAIL:  Key (id)=(1) already exists.
    ahuigo=!# insert into t1 values(2);
    ERROR:  current transaction is aborted, commands ignored until end of transaction block
    ```

quit:

    > rollback
    > commit

# 事务隔离级别
PostgreSQL 隔离级别决定了事务中的操作如何与其他并发事务中的操作交互. 
分为: 读未提交、读已提交、可重复读和串行化。 默认事务隔离级别是 "Read Committed"（读已提交）。

## 修改隔离级别 与　mvcc
你可以将 "SERIALIZABLE" 替换为 "READ UNCOMMITTED"、"READ COMMITTED" 或 "REPEATABLE READ" 来设置为其他的隔离级别。

    BEGIN;
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
    -- 你的 SQL 语句...
    COMMIT;

事务的隔离是通过MVCC（多版本并发控制, Multi-version Concurrent Control）实现的。
即修改数据时会根据级别确定是否创建新的版本，通过比较版本实现数据隔离访问修改

### 读未提交(read uncommitted): 脏读
PostgreSQL 设置 "读未提交" 时，会将其视为 "读已提交". 
1. 因为 PostgreSQL 使用了多版本并发控制（MVCC, Multi-version Concurrent Control），这意味着每个事务都在一个快照版本中运行，这个快照包含了事务开始时所有已经提交的数据
2. 所以一个事务无法看到其他并发事务的未提交的更改

### 读已提交(read committed): 不可重复读和幻读问题
> 因为可以看到其它事务**已经提交** 的mvcc快照.　所以不可重复读， 此时加行锁可避免
一个事务只能看到其他事务已经提交的更改。这可以防止脏读，但可能导致不可重复读和幻读问题。

### 可重复读(REPEATABLE READ): 幻读问题
> 因为**不能**看到其它事务提交的mvcc 快照, 所以可重复读。但是幻读问题，因为: 可以查询到其它事务新增加、删除的数据，因为没有mvcc 版本快照版本的.

一个事务在整个过程中都能看到一个一致的快照。这可以防止脏读和不可重复读，但可能导致幻读问题。

### 串行化 
它通过完全序列化事务来防止所有并发问题

## 隔离的问题分类
### 脏读
> postgres　它没有读未提交,不存在脏读问题
脏读: 允许事务看到其他事务未提交的更改

### 不可重复读（Nonrepeatable Read）
> 行锁可避免
这是指在同一事务中，多次读取同一数据返回的**结果**不一致。这通常是因为在两次读取之间，其他事务**Update**并提交了这些数据

    BEGIN;
    SELECT * FROM your_table WHERE id = 1; -- 返回 {id: 1, value: 'old'}
    -- 此时，另一个事务修改了 id 为 1 的行的 value 并提交
    SELECT * FROM your_table WHERE id = 1; -- 返回 {id: 1, value: 'new'}
    COMMIT;

### 幻读（Phantom Read）
> 表锁可避免
这是指在同一事务中，多次执行同一查询返回的**结果集**不一致(影响总数)。这通常是因为在两次查询之间，其他事务**Insert 或 Delete**了满足查询条件的行。

    BEGIN;
    SELECT * FROM your_table WHERE value > 100; -- 返回 10 行
    -- 此时，另一个事务插入了一个 value 大于 100 的行并提交
    SELECT * FROM your_table WHERE value > 100; -- 返回 11 行
    COMMIT;