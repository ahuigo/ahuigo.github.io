---
title: Postgre CRUD
date: 2018-09-27
---
# Postgre CRUD
## string or keyword
    select 'string';
    select "count"(1) from "table_name"

## insert 
    CREATE TABLE users (id INT, counters JSONB NOT NULL DEFAULT '{}');
    INSERT INTO users (id, counters) VALUES (1, '{"bar": 10}');

语法

    INSERT INTO "table1" ("created_at","status") VALUES ('2019-05-13 15:34:51','1') RETURNING "table1"."id";

### last insert id
3 ways,all are concurrent safe:

    SELECT currval(table_name+'_id_seq');
    SELECT LASTVAL();
    insert into .... RETURNING id;

### insert+update
1. 加条insert+update 两句
INSERT INTO table (id, field, field2)
       SELECT 3, 'C', 'Z'
       WHERE NOT EXISTS (SELECT 1 FROM table WHERE id=3);
2. insert + onconflict do update

    INSERT INTO the_table (id, column_1, column_2) VALUES (1, 'A', 'X'), (2, 'B', 'Y'), (3, 'C', 'Z')
    ON CONFLICT (id) 
    DO UPDATE 
        SET column_1 = EXCLUDED.column_1, 
            column_2 = the_table.column_2 
        [RETURNING id];
    DO NOTHING;

#### on conflict
`ON CONFLICT target action [RETURNING id]`:

    target:
        (uid, phone)
        ON CONSTRAINT constraint_name
        WHERE predicate
    action:
        DO UPDATE SET column_1 = EXCLUDED.value_1,v2, .. WHERE condition

## select 
双引号 反引号。表示特殊的字段：

    select "abc";
    ERROR:  column "abc" does not exist

字符应该用单引号

    select 'abc'

### between

    hourt between 0 and 23

### group by 
`wmname` must appear in the GROUP BY clause or be used in an aggregate function

    SELECT cname, MAX(avg)  FROM makerar GROUP BY cname;

#### group by expression
group by hour

    group by date_trunc('hour', ctime)
    group by date_trunc('day', ctime)
    group by date_trunc('week', ctime)

不等价:

    select hour/2 as hour2 from users group by hour2;
    select hour/2 as hour from users group by hour;

with order by:

    select hour/2 as hour2 from users group by hour2 order by hour2;

#### group by with top N
https://stackoverflow.com/questions/3800551/select-first-row-in-each-group-by-group

    # SELECT FIRST(id), customer, FIRST(total) FROM  purchases GROUP BY customer ORDER BY total DESC;

Supported by any database:

    SELECT MIN(x.id),  -- change to MAX if you want the highest
         x.customer, 
         x.total
    FROM PURCHASES x
    JOIN (SELECT p.customer,
            MAX(total) AS max_total
            FROM PURCHASES p
            GROUP BY p.customer) y 
    ON y.customer = x.customer AND y.max_total = x.total
    GROUP BY x.customer, x.total


#### partition
partition:

    # SELECT FIRST(id), customer, FIRST(total) FROM  purchases GROUP BY customer ORDER BY total DESC;
    WITH summary AS (
        SELECT p.id, 
            p.customer, 
            p.total, 
            ROW_NUMBER() OVER(PARTITION BY p.customer 
                                    ORDER BY p.total DESC) AS rk
        FROM PURCHASES p)
    SELECT s.*
    FROM summary s
    WHERE s.rk = 1

##### delete duplicated row
delete and keep top 2 row(order by peg) with group by industry

    DELETE FROM stock where id in 
        (select id  FROM (
            SELECT
                ROW_NUMBER() OVER (PARTITION BY industry ORDER BY peg) AS r, stock.*
            FROM
            stock) x WHERE x.r > 2
        )

多维支持

    PARTITION BY company, department

### DISTINCT
> https://stackoverflow.com/questions/18539223/select-random-row-for-each-group-in-a-postgres-table
> SELECT DISTINCT ON expressions must match initial ORDER BY expressions

Select random one for each group of customer

In PostgreSQL this is typically simpler and faster (more performance optimization below):

    # customer 必须出现在: order by
    SELECT DISTINCT ON (customer)
        id, customer, total
    FROM   purchases
    ORDER  BY customer, total DESC, id;

Or shorter (if not as clear) with ordinal numbers of output columns:

    # 2:customer 1:id 3:total
    SELECT DISTINCT ON (2)
        id, customer, total
    FROM   purchases
    ORDER  BY 2, 3 DESC, 1;

If total can be NULL (won't hurt either way, but you'll want to match existing indexes):

    ORDER  BY customer, total DESC NULLS LAST, id; //null 排序时放在最后

## del

    SELECT '{"a":[null,{"b":[3.14]}]}' #- '{a,1,b,0}'

## update

	UPDATE ed_names SET c_request = c_request+1 WHERE id = 'x'"

### update DUPLICATE
mysql update 多个unique key 时,如果遇到 `duplicate key`, 比如所有的i加1

一般情况下可以通过排序避免(mysql update/insert 时会按一定的顺序去查数据是否有效):

	UPDATE <table> set i=i+1 where id>10 order by i desc; # 大的先加1，避免冲突

如果`i`没有加索引，排序比较耗时或内存，就变通一下，比如：放弃排序，先负数：

	UPDATE <table> set i=-i where id>10; # 先变负，就不存在+1冲突
	UPDATE <table> set i=1-i where id>10;
