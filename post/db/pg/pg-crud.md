---
title: Postgre CRUD
date: 2018-09-27
---

# Postgre meta

## string or keyword

    select 'string';
    select "count"(1) from "table_name"

## find foreign keys

查找使用users为外键foreign key的表

    select R.table_name,R.column_name,U.column_name as id
    from INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE u
    inner join INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS FK
        on U.CONSTRAINT_CATALOG = FK.UNIQUE_CONSTRAINT_CATALOG
        and U.CONSTRAINT_SCHEMA = FK.UNIQUE_CONSTRAINT_SCHEMA
        and U.CONSTRAINT_NAME = FK.UNIQUE_CONSTRAINT_NAME
    inner join INFORMATION_SCHEMA.KEY_COLUMN_USAGE R
        ON R.CONSTRAINT_CATALOG = FK.CONSTRAINT_CATALOG
        AND R.CONSTRAINT_SCHEMA = FK.CONSTRAINT_SCHEMA
        AND R.CONSTRAINT_NAME = FK.CONSTRAINT_NAME
    where U.TABLE_NAME = 'users'

## select primary key

refer:
https://dataedo.com/kb/query/postgresql/list-all-primary-keys-and-their-columns

    select kcu.column_name as pk
    from information_schema.table_constraints tco
    join information_schema.key_column_usage kcu
        on kcu.constraint_name = tco.constraint_name
        and kcu.constraint_schema = tco.constraint_schema
        and kcu.constraint_name = tco.constraint_name
    where tco.constraint_type = 'PRIMARY KEY' and kcu.table_name='oauth_tokens';

说明：

    table_schema - PK schema name
    table_name - PK table name
    constraint_name - PK constraint name
    position - index of column in table (1, 2, ...). 2 or higher means key is composite (contains more than one column)
    key_column - PK column name

# crud

## insert

    CREATE TABLE users (id INT, counters JSONB NOT NULL DEFAULT '{}');
    INSERT INTO users (id, counters) VALUES (1, '{"bar": 10}');

语法

    INSERT INTO "table1" ("created_at","status") VALUES ('2019-05-13 15:34:51','1') RETURNING "table1"."id";

### insert with select

    insert into items_ver (item_id, name, item_group)
        select item_id, name, item_group from items where item_id=2;
    insert into items_ver (id, item_id, name, item_group)
        select 100, item_id, name, item_group from items where item_id=2;

### last insert id

3 ways,all are concurrent safe:

    SELECT currval(table_name+'_id_seq');
    SELECT LASTVAL();
    insert into .... RETURNING id;

### insert+update

1. 加条insert+update 两句 INSERT INTO table (id, field, field2) SELECT 3, 'C', 'Z'
   WHERE NOT EXISTS (SELECT 1 FROM table WHERE id=3);
2. insert + onconflict do update eg:

   INSERT INTO the_table (id, column_1, column_2) VALUES (1, 'A', 'X'), (2, 'B',
   'Y'), (3, 'C', 'Z') ON CONFLICT (id) DO UPDATE SET column_1 =
   EXCLUDED.column_1, -- 更新值 column_2 = the_table.column_2 -- 保留值 [RETURNING
   id]; DO NOTHING;

#### on conflict

`ON CONFLICT [target] action [RETURNING id]`:

    target:
        (uid, phone)
        ON CONSTRAINT constraint_name
        WHERE predicate
    action:
        DO UPDATE SET column_1 = EXCLUDED.value_1,v2, .. WHERE condition

可以什么都不做时，就不需要target:

    ON CONFLICT DO NOTHING

## select

    select array[1,2] where true;

### order

execute order:

    FROM with JOIN's to get tables
    WHERE for limit rows from tables
    SELECT for limit columns
    GROUP BY for group rows into related groups
    HAVING for limit resulting groups (不能使用select 中的别名，不过`having sum(cost)>50`不会重复计算)
    ORDER BY for order results

### is null

see https://www.postgresql.org/docs/current/functions-comparison.html

    select 1 is null;  -- alias: expression ISNULL
    where column is null; -- alias: expression NOTNULL

not 'C' but include null

    SELECT * FROM "A" WHERE "B" != 'C'; -- not include B is null

not 'C': `IS DISTINCT FROM`(Not equal), treating null as a comparable value.

    SELECT * FROM "A" WHERE "B" != 'C' OR "B" IS NULL
    -- or
    SELECT * FROM "A" WHERE "B" is distinct from 'C'

IS NULL in PostgreSQL is not value:

    // error
    select 1 is 1

### 字段引号

双引号 反引号。表示特殊的字段：

    select "abc";
    ERROR:  column "abc" does not exist

字符应该用单引号

    select 'abc'

### custom table

    select user_id, name
    from (values (1, 'John Smith')) t(user_id, name)

### offset

    page=0
    limit 10 offset 10*page

### where

#### between

    hourt between 0 and 23

#### not exists

https://stackoverflow.com/questions/19363481/select-rows-which-are-not-present-in-other-table

    SELECT col1 FROM tab1 WHERE EXISTS (SELECT 1 FROM tab2 WHERE col2 = tab1.col2);
    SELECT col1 FROM tab1 WHERE NOT EXISTS (SELECT 1 FROM tab2 WHERE col2 = tab1.col2);

Only good without NULL values or if you know to handle NULL properly.

    SELECT ip 
    FROM   login_log
    WHERE  ip NOT IN (
        SELECT DISTINCT ip  -- DISTINCT is optional
        FROM   ip_location
    );

### left join/is null

Sometimes this is fastest. Often shortest. Often results in the same query plan
as NOT EXISTS.

    SELECT l.ip FROM   login_log l 
    LEFT   JOIN ip_location i USING (ip)  -- short for: ON i.ip = l.ip
    WHERE  i.ip IS NULL;

### Except

Short. Not as easily integrated in more complex queries.

    SELECT ip 
    FROM   login_log

    EXCEPT ALL  -- "ALL" keeps duplicates and makes it faster
    SELECT ip
    FROM   ip_location;

want the ALL keyword. If you don't care, still use it because it makes the query
faster.

### group by

`wmname` must appear in the GROUP BY clause or be used in an aggregate function

    SELECT cname, MAX(avg)  FROM makerar GROUP BY cname;

#### count number of group
    SELECT COUNT(*) AS total_group
    FROM
    ( SELECT 1
        FROM images 
        GROUP BY group_id
    ) AS t ;

或者利用over 聚合

    WITH images(group_id, uid)
        AS (SELECT 1,1 UNION ALL
            SELECT 1,2 UNION ALL
            SELECT 1,3 UNION ALL
            SELECT 2,21)
    SELECT COUNT(*) OVER() AS total_group
    FROM images 
    GROUP BY group_id
    LIMIT 1 ;

解释：over中没有带参数，会将group list 看成单个大分区。count则会统计分区内的group 总数


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

不存在first 这个函数, 下面是伪代码

    # SELECT FIRST(id), customer, FIRST(total) FROM  purchases GROUP BY customer ORDER BY total DESC;

利用 join: group + `column==max(column)`, Supported by any database: 

    SELECT MIN(x.id),  -- change to MAX if you want the highest id
         x.customer, 
         x.total
    FROM PURCHASES x
    JOIN (SELECT p.customer,
            MAX(total) AS max_total
            FROM PURCHASES p
            GROUP BY p.customer) y 
    ON y.customer = x.customer AND y.max_total = x.total
    GROUP BY x.customer, x.total

例子2: 选择最大的id

    # 例子3：也可以用id in subquery 代替（效率一样）
    SELECT x.* 
    FROM task_checks x
    JOIN (SELECT max(id) as id
            FROM task_checks p
            GROUP BY p.workflow_uuid, p.task_name) y
    ON y.id=x.id limit 1

#### partition(top N)

##### partition with ROW_NUMBER()
> 结合OVER 分组聚合运算符

partition top 1:

    # 相当于伪代码：SELECT FIRST(id), customer, FIRST(total) FROM  purchases GROUP BY customer ORDER BY total DESC;
    WITH summary AS (
        SELECT p.id, 
            p.customer, 
            p.total, 
            ROW_NUMBER() 
            OVER( PARTITION BY p.customer ORDER BY p.total DESC ) AS rk
        FROM PURCHASES p)
    SELECT s.*
    FROM summary s
    WHERE s.rk = 1

PARTITION BY when multiple columns:

    WITH summary AS (
        SELECT *, ROW_NUMBER() 
            OVER(PARTITION BY workflow_uuid,task_name ORDER BY p.id DESC ) AS rk
        FROM task_checks p)
    SELECT s.*
    FROM summary s
    WHERE s.rk = 1

##### partition with RANK() and DENSE_RANK()

RANK() and DENSE_RANK() 区别:
https://stackoverflow.com/questions/7747327/sql-rank-versus-row-number

    WITH T(StyleID, ID)
        AS (SELECT 1,1 UNION ALL
            SELECT 1,1 UNION ALL
            SELECT 1,1 UNION ALL
            SELECT 2,2 UNION ALL
            SELECT 1,100)
    SELECT *,
        ROW_NUMBER() OVER(PARTITION BY StyleID ORDER BY ID) AS ROW_NUMBER,
        RANK() OVER(PARTITION BY StyleID ORDER BY ID)       AS RANK,
        DENSE_RANK() OVER(PARTITION BY StyleID ORDER BY ID) AS DENSE_RANK
    FROM   T; 

    styleid | id  | row_number | rank | dense_rank 
    ---------+-----+------------+------+------------
        1 |   1 |          1 |    1 |          1
        1 |   1 |          2 |    1 |          1
        1 |   1 |          3 |    1 |          1
        1 | 100 |          4 |    4 |          2
        2 |   2 |          1 |    1 |          1

可以看到:

1. ROW_NUMBER 对分区内row是自增排序编号
1. RANK 对分区排序的row，相等的row用`相同编号`, 不相等的row编号才改变(不相等时使用ROW_NUMBER 计数)
1. DENSE_RANK 对分区排序的row，相等row用`相同编号`, 不相等的row才改变(不相等编号自增)

##### delete duplicated row

delete and keep top 2 row(order by peg) with group by industry

    DELETE FROM stock where id in 
        (select id  FROM (
            SELECT
                ROW_NUMBER() OVER (PARTITION BY industry ORDER BY peg) AS r, id
            FROM
            stock) x WHERE x.r > 2
        )

多维支持

    PARTITION BY company, department

如果有多个key:

    DELETE FROM table_name
    WHERE (key1, key2) IN (
        SELECT key1, key2 FROM table_name ORDER BY date DESC LIMIT 2
    );

#### having

PostgreSQL won't calculate the sum twice

    SELECT  SUM(points) AS total FROM table GROUP BY username HAVING  SUM(points) > 25

### concat rows

合并为array

    select code, ARRAY_AGG(label) l from t group by code;
    SELECT family, ARRAY_AGG (first_name || ' ' || last_name) fullname FROM users group by family; 

合并为字符串：

    -- GROUP BY 1 is a positional reference and a shortcut for GROUP BY movie
    -- The `group by 1` is a positional reference and a shortcut for `GROUP BY movie` in this case.
    SELECT movie, string_agg(actor, ', ') AS actor_list FROM tbl GROUP  BY 1;

#### distinct

    WITH T(uid, age)
    AS (SELECT 1,1 UNION ALL
        SELECT 1,3 UNION ALL
        SELECT 1,2 UNION ALL
        SELECT 2,1)
    SELECT distinct uid FROM T ;
     uid 
    -----
    1
    2

    WITH T(uid, age)
    AS (SELECT 1,1 UNION ALL
        SELECT 1,3 UNION ALL
        SELECT 1,2 UNION ALL
        SELECT 1,2 UNION ALL
        SELECT 2,1)
    SELECT distinct uid,age FROM T ; -- 类似于 SELECT  uid,age FROM T group by uid,age
    -----
    2 |   1
    1 |   3
    1 |   2
    1 |   1

不能用这个，语法错误：

    # syntax error 
    SELECT uid,distinct age FROM T ;
#### count distinct

    # bad
    select group,count(*) from (select group, uid from tmp group by group, uid) tmp group by group;
    # better
    select group, count(distinct uid) from tmp group by group;



#### distinct array

    SELECT ARRAY(SELECT DISTINCT e FROM unnest(ARRAY[a,b,c,d]) AS a(e))
    FROM ( VALUES
        ('foo', 'bar', 'foo', 'baz' )
    ) AS t(a,b,c,d);
        array
    ---------------
    {baz,bar,foo}

with CROSS JOIN LATERAL which is much cleaner,

    SELECT ARRAY(
        SELECT DISTINCT e
        FROM ( VALUES
            ('foo', 'bar', 'foo', 'baz' )
        ) AS t(a,b,c,d)
        CROSS JOIN LATERAL unnest(ARRAY[a,b,c,d]) AS a(e)
        -- ORDER BY e; -- if you want it sorted
    );


#### DISTINCT on

> https://stackoverflow.com/questions/18539223/select-random-row-for-each-group-in-a-postgres-table
> SELECT DISTINCT ON expressions must match initial ORDER BY expressions

distinct 就是分组，然后按序(order by 取top1)/或随机取一个row

    # 按customer 分组, 其它的id, total 只取一个
    SELECT DISTINCT ON (customer)
        id, customer, total
    FROM   purchases
    ORDER  BY customer, total DESC, id;

    # or
    SELECT DISTINCT ON (customer) * FROM   purchases;

Or shorter (if not as clear) with ordinal numbers of output columns:

    # 2:customer 1:id 3:total
    SELECT DISTINCT ON (2)
        id, customer, total
    FROM   purchases
    ORDER  BY 2, 3 DESC, 1;

按uid 分组，不排序直接取第一个age

    WITH T(uid, age)
    AS (SELECT 1,1 UNION ALL
        SELECT 1,3 UNION ALL
        SELECT 1,2 UNION ALL
        SELECT 2,1)
    SELECT distinct on(uid) uid,age FROM T ;
     uid | age
    -----+-----
    1 |   1
    2 |   1

按uid 分组，排序取第一个age

    WITH T(uid, age)
    AS (SELECT 1,1 UNION ALL
        SELECT 1,3 UNION ALL
        SELECT 1,2 UNION ALL
        SELECT 2,1)
    SELECT distinct on(uid) uid,age FROM T order by age desc;

如果按有group分组可以替代ON 分组

    select distinct task_id, min(update_time) as update_time from pod_monitors group by task_id having count(*) > 1

Note:

1. `distinct on(fieldList)` 必须匹配`order by list`. list与fieldlist 必须要有交集(除非不要order
   by) 且**交集必须位于order by 开头**,
2. `fieldList`中字段顺序不影响分组及结果, `list` 排序则影响顺序

e.g.

    # ERROR: DISTINCT ON expressions must match initial ORDER BY expressions: (code,pe)与end_date 没有交集
    select distinct on (code,pe) code,pe,end_date from profits order by end_date;
    # 以code,end_date分组
    select distinct on (code,end_date) code,pe,end_date from profits order by end_date;
    # 以code分组, 取最新end_date
    select distinct on (code) code,end_date,pe,peg from profits order by code,end_date desc

where filter, 会导致提前过滤掉的分组top1行, 导致留下topN列上位顶替原来的top1

    # 比如我想找所有股票code 中，取最新end_date财报中, peg<1 的
    # 有问题: 先过滤，再最新的end_date
    select distinct on (code,end_date) code,end_date,pe from profits where peg<1 order by code,end_date desc limit 1
    # 没有问题: 先分组取最新的end_date, 再过滤
    select p.* from (select distinct on (code) code,end_date,pe,peg from profits order by code,end_date desc  ) p where p.peg<1;

If total can be NULL (won't hurt either way, but you'll want to match existing
indexes):

    ORDER  BY customer, total DESC NULLS LAST, id; //null 排序时放在最后

## del

    SELECT '{"a":[null,{"b":[3.14]}]}' #- '{a,1,b,0}'

### delete join

    DELETE FROM AAA AS a 
    USING 
        BBB AS b,
        (select * from subtable) AS c
    WHERE 
        a.id = b.id 
    AND a.id = c.id
    AND a.uid = 12345 
    AND c.gid = 's434sd4'

### 删除重复（无unique）

    # 检查重复数量
    select count(1) from (select 1 from pod_monitors group by task_id having count(*) > 1) t;

    # 去重保存
    \copy (select distinct on(task_id) * from pod_monitors where task_id in (select task_id from pod_monitors group by task_id having count(*) > 1)) to 'staging.csv' csv;

    # 删除
    delete from pod_monitors where task_id in (select task_id from pod_monitors group by task_id having count(*) > 1);

    # 恢复
    \copy  pod_monitors from 'staging.csv' csv;

## update

    UPDATE ed_names SET c_request = c_request+1 WHERE id = 'x'"

### update subquery

    UPDATE dummy
    SET customer=subquery.customer,
        address=subquery.address,
        partn=subquery.partn
    FROM (SELECT address_id, customer, address, partn
        FROM  /* big hairy SQL */ ...) AS subquery
    WHERE dummy.address_id=subquery.address_id;

### update DUPLICATE

mysql update 多个unique key 时,如果遇到 `duplicate key`, 比如所有的i加1

一般情况下可以通过排序避免(mysql update/insert 时会按一定的顺序去查数据是否有效):

    UPDATE <table> set i=i+1 where id>10 order by i desc; # 大的先加1，避免冲突

如果`i`没有加索引，排序比较耗时或内存，就变通一下，比如：放弃排序，先负数：

    UPDATE <table> set i=-i where id>10; # 先变负，就不存在+1冲突
    UPDATE <table> set i=1-i where id>10;

### update limit

    UPDATE server_info
    SET    status = 'active' 
    WHERE  server_ip = ( SELECT server_ip FROM   server_info WHERE  status = 'standby' LIMIT  1)
    RETURNING server_ip;

update with lock:

    UPDATE server_info
    SET    status = 'active' 
    WHERE  server_ip = ( SELECT server_ip FROM   server_info WHERE  status = 'standby' LIMIT  1 FOR    UPDATE SKIP LOCKED)
    RETURNING server_ip;
