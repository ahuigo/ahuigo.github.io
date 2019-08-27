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

use distinct:

    SELECT DISTINCT ON (cname) cname , wmname, MAX(avg)  FROM makerar GROUP BY cname;

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

delete and keep top 2 row(order by peg) with group by industry

    DELETE FROM stock where id in 
        (select id  FROM (
            SELECT
                ROW_NUMBER() OVER (PARTITION BY industry ORDER BY peg) AS r, stock.*
            FROM
            stock) x WHERE x.r > 2
        )

#### DISTINCT
In PostgreSQL this is typically simpler and faster (more performance optimization below):

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

# var

## type

SELECT pg_typeof(your_variable);
json_typeof(var)

类型转换

    var::int
    var::jsonb
    var::text::jsonb

## 默认值

    COALESCE(variable,0)
    COALESCE(counters->>'bar','0')::int

## timestamp

   select date '2001-09-28' + integer '7'
   select created_at + interval '1' day * day_field as deadline
   select created_at + interval '1' hour * hour_field as deadline

   select created_at + hour_field as deadline //not work

## string
1. 字符串，只能用`'` 为边界，双引号是用于关键字的(e.g. table_name)

postgre 不支持\ 转义 

    select '\\'; #按字面输出
    select '\''; #error 

插入单引号

    select 'ahui''s blog'; 
    select 'a''b' # 不支持 ’a\'b' 

### concat
    select 'a:'||'b'||1.2 as bb;
    select concat('a:','b', 1.2)
    select concat(key1,key2)

join:

    CONCAT_WS(separator,str_1,str_2,...);

join group:

    string_agg(actor, ', ') AS actor_list
    SELECT movie, string_agg(actor, ', ' ORDER BY actor) AS actor_list FROM   tbl GROUP  BY 1;


### string length

    CHAR_LENGTH(name)
    REPLACE(name, 'substring', '')

## array

    select array[1,2];
    select array['a','b'];
    select array['a',1]; # error

### array length

    select array_length(string_to_array(name, 'o'), 1) - 1

## jsonb
https://www.postgresql.org/docs/current/static/functions-json.html

### 定义
jsonb 即可以直接使用 json 字符串, 插入取出时自动转换成`::jsonb` 得到jsonb 类型

    select '{"key":123}'
    select concat('{"key":',123,'}')::jsonb;
    select '1' intger
    select '"1"' char

### increment
1. with ||jsonb, 只适合第一层级, 更好的办法是使用jsonb_set(col, path, data)
2. `->>` 将jsonb 转换成text, 转成数字还需要`::int`, 并且`::`与`+`优先级都高于`->>`

    UPDATE users SET counters = counters || '{"bar": 314}'::jsonb WHERE id = 1;
    UPDATE users SET counters = counters || CONCAT('{"bar":', COALESCE(counters->>'bar','0')::int + 1, '}')::jsonb WHERE id = 1;
    UPDATE users SET counters = jsonb_set(counters, '{bar}', CONCAT(COALESCE(counters->>'bar')::int + 1)::jsonb) WHERE id = 1;

### 使用:

    []->int	 Get JSON array(0, -3)          '[{"a":"foo"},{"b":"bar"},{"c":"baz"}]'::json->2
    {}->'text' Get JSON object field by key   '{"a": {"b":"foo"}}'::json->'a'
    []->>int	as text                     '[1,2,3]'::json->>2	3
    {}->>'text'	as text                     '{"a":1,"b":2}'::json->>'b'	2
    # 多级路径path
    {}[]#>'{k1,k2}' Get JSON object	        '{"a": {"b":{"c": "foo"}}}'::json#>'{a,b}'	{"c": "foo"}
    {}[]#>>'{k1,k2}'Get JSON object as text	'{"a":[1,2,3],"b":[4,5,6]}'::json#>>'{a,2}'	3

其它：

    a @> b  check a include b
    a <@ b  check a is included by b
    dic?'b' check b key exists
    dic?|array('b','a') check any [a,b] exists
    dic?&array('b','a') check all [a,b] exists
    a||b merge
    dic-'key'  delete
    dic-'{k1,k2}' del
    arr-2       del 2nd valume
    #-path      del by path

path:

    '{1,kl2,kl3,kl4,5}'

### merge
merge jsonb via `||`:

    UPDATE users SET counters = counters || CONCAT('{"foo":', COALESCE(counters->>'foo','0')::int + 27, '}')::jsonb WHERE id = 1;

add jsonb via `jsonb_set`:

    jsonb_set('{"bar":1,"x":{}}'::jsonb, '{x,y}', 1::text::jsonb);
    {"x": {"y": 1}, "bar": 1}