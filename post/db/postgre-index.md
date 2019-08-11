---
title: Postgre 的索引
date: 2018-09-27
---
# Postgre Index
本文主要围绕postgre 总结一下索引, 参考：[PostgreSQL 9种索引的原理和应用场景](https://yq.aliyun.com/articles/111793)

## 索引数据结构算法
共9种：

    btree , hash , gin , gist , sp-gist , brin , bloom , rum , zombodb , bitmap

CREATE INDEX命令默认创建B-Tree索引

1. bTree: <、<=、=、>=和>, col LIKE 'foo%'或col ~ '^foo'，索引才会生效
        CREATE INDEX test1_id_index ON test1 (id);    
2. Hash: =
        CREATE INDEX name ON table USING hash (column);
3. GiST: 不是单独的索引，它可实现多种索引策略

4. GIN: gin是倒排索引, 适合处理包含多个键的值(比如数组), '<@, @>,=,&&'
    create index idx_t_gin1_1 on t_gin1 using gin (arr);  

### GIN
> https://github.com/digoal/blog/blob/master/201702/20170204_01.md

GIN(Generalized Inverted Index, 通用倒排索引) 是一个存储对(key, posting list)集合的索引结构
1. 其中key是一个键值，而posting list 是一组出现过key的位置。如(‘hello', '14:2 23:4')中，表示hello在14:2和23:4这两个位置出现过，
2. 在PG中这些位置实际上就是元组的tid(行号，包括数据块ID（32bit）,以及item point(16 bit) )。

结构:
1. entry tree: B树，
2. 而posting tree则类似于b-tree。

在表中的每一个属性，在建立索引时，都可能会被解析为多个键值，所以同一个元组的tid可能会出现在多个key的posting list中。

## 索引语法
两种
- INDEX : 支持lower/condition 表达式
- CONSTRAINT: 不支持表达式

create table constraint:

    CREATE TABLE table_name(
        id bigserial PRIMARY KEY,
        column_name data_type UNIQUE,
        UNIQUE ( column_name [, ... ] ) 
        PRIMARY KEY ( column_name [, ... ] ) 
    );

### add index/constraint
二者实质没啥区别
add index

    CREATE [ UNIQUE | FULLTEXT | SPATIAL ] INDEX index_name
        ON table_name (col_name [length],…) [ASC | DESC]

add constraint 

    \h alter table
    alter table users add UNIQUE(name,id);
    alter table users add CONSTRAINT uesrs_pkey  UNIQUE(name,id);
    alter table t add CONSTRAINT uesrs_pkey PRIMARY KEY(id)
    alter table t add CONSTRAINT uesrs_pkey UNIQUE (id)
    column_constraint:
        NOT NULL |
        NULL |
        CHECK ( expression ) |
        DEFAULT default_expr |
        UNIQUE index_parameters |
        PRIMARY KEY index_parameters |...

add constraint via index(unique): 
https://pg.sjk66.com/postgresql/unique-constraint.html
https://stackoverflow.com/questions/23542794/postgres-unique-constraint-vs-index

    alter table t add CONSTRAINT uesrs_pkey UNIQUE USING INDEX index_name;

### Rename index/constraint
rename index/constraint:

    \h alter index
    ALTER INDEX [ IF EXISTS ] name RENAME TO new_name
    ALTER TABLE name RENAME CONSTRAINT constraint_name TO new_constraint_name;

### Drop index/constraint:

    ALTER TABLE table DROP CONSTRAINT products_pkey;
    DROP INDEX index_name;

## 约束各类
索引也是属于约束，约束不代表有索引，比如 `NOT NULL`, `CHECK`

    RIMARY Key：NOT NULL 和 UNIQUE 的结合。确保某列（或两个列多个列的结合）有唯一标识，有助于更容易更快速地找到表中的一个特定的记录。。
    CHECK： 保证列中的值符合指定的条件。
    FOREIGN Key： 保证一个表中的数据匹配另一个表中的值的参照完整性。
    EXCLUSION ：排他约束，保证如果将任何两行的指定列或表达式使用指定操作符进行比较，至少其中一个操作符比较将会返回 false 或空值。

### NOT NULL
    AGE INT NOT NULL,

### CHECK
CHECK： 保证列中的值符合指定的条件。

    SALARY  int  CHECK(SALARY > 0),

### EXCLUSION 
排他约束，保证如果将任何两行的指定列或表达式使用指定操作符进行比较，至少其中一个操作符比较将会返回 false 或空值。
比如，为了防止录入重复的人名和年龄：

    CREATE TABLE COMPANY7(
        NAME           TEXT,
        AGE            INT  ,
        EXCLUDE USING gist
        (NAME WITH =,  -- 如果满足 NAME 相同，AGE 不相同则允许插入，否则不允许插入
        AGE WITH <>)   -- 其比较的结果是如果整个表边式返回 true，则不允许插入，否则允许
    );

### primary key
SERIAL 是自增

    id int   PRIMARY KEY,
    id SERIAL PRIMARY KEY;

复合索引：

    create TABLE users(
        id integer NOT NULL,
        role_id integer NOT NULL,
        PRIMARY KEY (id, role_id)
        CONSTRAINT uesrs_pkey PRIMARY KEY(column_1, column_2,...); -- 带名称
    )

已经存在的表添加索引:

    ALTER TABLE products ADD PRIMARY KEY (column_1, column_2);
    ALTER TABLE vendors  ADD COLUMN id SERIAL PRIMARY KEY;

### foreign key
为了保证 blogs 中的uid 一定存在于users中

    create table blogs(
        uid INT references users(id),           -- 方法1
        uid INT,
        name Text,
        FOREIGN KEY (uid) REFERENCES users(id), -- 方法2表级约束
        FOREIGN KEY (uid,name) REFERENCES users(id,name), -- 组合级约束(column一一对应)
    )
    Alter table "blogs" add FOREIGN KEY (uid,name) REFERENCES users(id,name)

然后`\d users` 就会有：

    > \d users
    Referenced by:
        TABLE "blogs" CONSTRAINT "blogs_uid_fkey" FOREIGN KEY (uid) REFERENCES users(id)

#### Delete strict
如果不允许users 删除任何被其它表blogs 引用的记录, 直到所有引用行被删除, 可以使用 DELETE RESTRICT：

    create blogs(
        uid int4 REFERENCES users(id) ON DELETE RESTRICT,
    )

#### Delete cascade
如果要让 users 在删除某条记录的同时，将所有引用该条记录的关联记录也一起删除，我们可以使用 DELETE CASCADE：

> 提示，这些 DELETE 的行为同样适用于 UPDATE， 也就是说，有 `ON UPDATE RESTRICT, ON UPDATE CASCADE 和 ON UPDATE NO ACTION` 等行为。


已经存在的表添加约束:

    ALTER TABLE t ADD
    CONSTRAINT account_role_role_id_fkey 
        FOREIGN KEY (role_id) REFERENCES role (role_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,

## 索引种类

### 普通index(btree)
create table 语句不支持

    CREATE INDEX test1_id_index ON test1 (id);

### 复合索引:
只有B-tree、GiST和GIN支持复合索引，其中最多可以声明32个字段:

    CREATE INDEX idx1 ON tb_name(column1, column2);

其中，GIN复合索引不会受到查询条件中使用了哪些索引字段子集的影响，无论是哪种组合，都会得到相同的效率, 因为它是同时索引多个值

### 唯一索引

    CREATE UNIQUE INDEX name ON table (column [, ...]);
    id int   UNIQUE,
    UNIQUE (c2, c3)

### 表达式索引

    CREATE INDEX test1_lower_col1_idx ON test1 (lower(col1));
    CREATE INDEX people_names ON people ((first_name || ' ' || last_name));

### 部分索引(partial index)
部分索引(partial index)是建立在一个表的子集上的索引，

    CREATE INDEX access_log_client_ip_ix ON access_log(client_ip)
        WHERE NOT (client_ip > inet '192.168.100.0' AND client_ip < inet '192.168.100.255');
    下面的查询将会用到该部分索引：
    SELECT * FROM access_log WHERE url = '/index.html' AND client_ip = inet '212.78.10.32';

# optimize,优化

    explain (analyze,verbose,timing,costs,buffers) select * from t_gin1 where arr @> array[1,2];
    @> 是包含表达式