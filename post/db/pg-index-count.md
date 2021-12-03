---
title: 分页优化
date: 2021-10-25
private: true
---
# 分页优化
https://developer.aliyun.com/article/39682

## total 优化

    SELECT reltuples AS estimate_count FROM pg_class WHERE relname = 'table_name';
    SELECT reltuples::bigint FROM pg_catalog.pg_class WHERE relname = 'mytable';

创建一个函数，从explain中抽取返回的记录数

    CREATE FUNCTION count_estimate(query text) RETURNS INTEGER AS
    $func$
    DECLARE
        rec   record;
        ROWS  INTEGER;
    BEGIN
        FOR rec IN EXECUTE 'EXPLAIN ' || query LOOP
            ROWS := SUBSTRING(rec."QUERY PLAN" FROM ' rows=([[:digit:]]+)');
            EXIT WHEN ROWS IS NOT NULL;
        END LOOP;
    
        RETURN ROWS;
    END
    $func$ LANGUAGE plpgsql;

评估的行数和实际的行数相差不大，精度和柱状图有关。
PostgreSQL autovacuum进程会根据表的数据量变化比例自动对表进行统计信息的更新。
而且可以配置表级别的统计信息更新频率以及是否开启更新。

    postgres=# select count_estimate('select * from sbtest1 where id between 100 and 100000');
    count_estimate 
    ----------------
            102166
    (1 row)
    postgres=# explain select * from sbtest1 where id between 100 and 100000;
                                        QUERY PLAN                                       
    ---------------------------------------------------------------------------------------
    Index Scan using sbtest1_pkey on sbtest1  (cost=0.43..17398.14 rows=102166 width=190)
        Index Cond: ((id >= 100) AND (id <= 100000))
    (2 rows)

### 使用辅助表
我们创建mytable_count用于记录表的行数，并在mytable修改数据时使用触发器更新mytable_count的值。

    START TRANSACTION;
    
    CREATE TABLE mytable_count(c bigint);
    
    CREATE FUNCTION mytable_count() RETURNS trigger
       LANGUAGE plpgsql AS
    $$BEGIN
       IF TG_OP = 'INSERT' THEN
          UPDATE mytable_count SET c = c + 1;
    
          RETURN NEW;
       ELSIF TG_OP = 'DELETE' THEN
          UPDATE mytable_count SET c = c - 1;
    
          RETURN OLD;
       ELSE
          UPDATE mytable_count SET c = 0;
    
          RETURN NULL;
       END IF;
    END;$$;
    
    CREATE TRIGGER mytable_count_mod AFTER INSERT OR DELETE ON mytable
       FOR EACH ROW EXECUTE PROCEDURE mytable_count();
    
    -- TRUNCATE triggers must be FOR EACH STATEMENT
    CREATE TRIGGER mytable_count_trunc AFTER TRUNCATE ON mytable
       FOR EACH STATEMENT EXECUTE PROCEDURE mytable_count();
    
    -- initialize the counter table
    INSERT INTO mytable_count
       SELECT count(*) FROM mytable;
    COMMIT;

我们在单个事务中执行所有操作，以便不会“丢失”任何数据，因为CREATE TRIGGER是SHARE ROW EXCLUSIVE的锁，这可以防止所有并发修改，当然，缺点是所有并发数据修改必须等到SELECT count(*)完成。

## 游标代替分页
offset limit 未优化的情况，取前面的记录很快。 取后面的记录，因为前面的记录也要扫描，所以明显变慢。

    postgres=# explain analyze select * from sbtest1 where id between 100 and 1000000 order by id offset 900000 limit 100;
     Limit  (cost=83775.21..83784.52 rows=100 width=190) (actual time=461.941..462.009 rows=100 loops=1)
       ->  Index Scan using sbtest1_pkey on sbtest1  (cost=0.43..93450.08 rows=1003938 width=190) (actual time=0.025..308.865 rows=900100 loops=1)
             Index Cond: ((id >= 100) AND (id <= 1000000))
     Planning time: 0.179 ms
     Execution time: 462.053 ms (实际很长，遍历了90w id)
    (5 rows)

由于offset 数据可能被多次扫描，使用游标就能解决。

    postgres=# begin;
    BEGIN
    Time: 0.152 ms
    postgres=# declare cur1 cursor for select * from sbtest1 where id between 100 and 1000000 order by id;
    DECLARE CURSOR
    Time: 0.422 ms
    postgres=# fetch 100 from cur1;
    。。。

游标需要长连接的支持