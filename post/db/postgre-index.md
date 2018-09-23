# Postgre Index
本文主要围绕postgre 总结一下索引, 参考：[PostgreSQL 9种索引的原理和应用场景](https://yq.aliyun.com/articles/111793)

## 索引算法
共9种：

    btree , hash , gin , gist , sp-gist , brin , bloom , rum , zombodb , bitmap

CREATE INDEX命令默认创建B-Tree索引

1. bTree: <、<=、=、>=和>, col LIKE 'foo%'或col ~ '^foo'，索引才会生效
        CREATE INDEX test1_id_index ON test1 (id);    
2. Hash: =
        CREATE INDEX name ON table USING hash (column);
3. GiST: 不是单独的索引，它可实现多种索引策略

4. GIN: gin是倒排索引, 适合处理包含多个键的值(比如数组), '<@, @>,=,&&'

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
create table:

    CREATE TABLE table_name(
        id bigserial PRIMARY KEY,
        column_name data_type UNIQUE,
        UNIQUE ( column_name [, ... ] ) 
        PRIMARY KEY ( column_name [, ... ] ) 
    );
    column_constraint:
        NOT NULL |
        NULL |
        CHECK ( expression ) |
        DEFAULT default_expr |
        UNIQUE index_parameters |
        PRIMARY KEY index_parameters |...

独立

    CREATE [ UNIQUE | FULLTEXT | SPATIAL ] INDEX index_name
        ON table_name (col_name [length],…) [ASC | DESC]
    DROP INDEX idx_name;
    ALTER INDEX idx_name RENAME TO idx_name1;

### index(btree)
create table 语句不支持

    CREATE INDEX test1_id_index ON test1 (id);

### 复合索引:
只有B-tree、GiST和GIN支持复合索引，其中最多可以声明32个字段:

    CREATE INDEX idx1 ON tb_name(column1, column2);

其中，GIN复合索引不会受到查询条件中使用了哪些索引字段子集的影响，无论是哪种组合，都会得到相同的效率, 因为它是同时索引多个值

### 唯一索引

    CREATE UNIQUE INDEX name ON table (column [, ...]);
    id int   UNIQUE,

### primary key

    id int   PRIMARY KEY,

复合索引：

    user_id integer NOT NULL,
    role_id integer NOT NULL,
    PRIMARY KEY (user_id, role_id),

### foreign key

    CONSTRAINT account_role_role_id_fkey FOREIGN KEY (role_id)
        REFERENCES role (role_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,

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
