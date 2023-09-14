---
title: pg transaction
date: 2021-05-20
private: true
---
# pg transaction

# FAQ
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

# For update(行锁/写锁)
for update是写锁, 会阻止其它连接`写`或者获取`写锁for update`，以下：

    //不阻塞：select * from addresses where uid =1
    //阻塞：
    select * from addresses where uid =1 for update;
    select * from addresses where uid =1 for update SKIP LOCKED;
    update addresses set address1='add4' where uid=1;
    delete from addresses where uid=1;

例子：

    // 1.connect1 行锁：
    begin;
    select * from addresses where uid=1 for update;

    // 2. connect2：(会因为行锁等待)
    update addresses set address1='add2' where uid=1;

    // 3. 仅当connect1结束事务, connect才开始：
    commit; -- 或 rollback

> 如果想连select也禁止， 在 PostgreSQL 中，默认情况下，只有 ALTER TABLE, DROP TABLE, TRUNCATE, REINDEX, CLUSTER, 或者 VACUUM FULL 命令才会获取访问排他锁。也就是说，没有办法通过类似 SELECT FOR UPDATE 的方式获取这种锁。

## SKIP LOCKED
如果加行锁时，不想阻塞, 执行以下语句

    // 如果查询没有结果，说明行锁失败(或没有行被锁)
    select * from addresses where uid =1 for update SKIP LOCKED;

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

> 在 pg_stat_activity.state 列可以告诉我们当前查询的状态。
> age 计算时间差

# ExclusiveLock(读写锁)
在 PostgreSQL 中，可以通过 LOCK TABLE 命令或者在修改数据的语句（如 UPDATE、DELETE 或 INSERT）中隐式地获取 ExclusiveLock。以下是一些示例：

## 使用 LOCK TABLE 命令显式获取 ExclusiveLock：

    BEGIN;
    LOCK TABLE table_name IN EXCLUSIVE MODE;
    -- 你的 SQL 操作
    COMMIT;

这个命令会在整个事务期间锁定整张表。只有当事务结束 (COMMIT 或 ROLLBACK) 的时候，才会释放这个锁。

## 通过修改数据隐式获取 ExclusiveLock：
下面的 UPDATE 语句中，PostgreSQL 也会为被修改的行获取 ExclusiveLock。这个锁同样会在事务结束后释放。

    BEGIN;
    UPDATE table_name SET column = value WHERE some_column = some_value;
    -- 更多的 SQL 操作
    COMMIT;

如果不加BEGIN, 就是一次性事务的锁（隐式事务，自动commit）

    UPDATE table_name SET column = value WHERE some_column = some_value;