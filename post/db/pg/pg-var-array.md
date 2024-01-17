---
title: Posgtre Var
date: 2019-06-20
private:
---

# define array

    CREATE TABLE stus (
        id serial PRIMARY KEY,
        name VARCHAR (100),
        phone INT,
        phones INT [],
        names TEXT [],
        owners varchar(30)[]
    );

## init array

    select array[1,2];
        {1,2}
    select array['a','b'];
    select array['a',1]; # error

二维数组

    DECLARE
        m   varchar[];
        arr varchar[] := array[['key1','val1'],['key2','val2']];

### array from select

    // sort array
    SELECT ARRAY(SELECT unnest(phones) ORDER BY 1) -- order by first column

    // covert text[] to integer[]
    SELECT ARRAY(SELECT CAST(unnest(array['200','301']::text[]) AS integer));


## empty array

    ALTER TABLE t1 add friends text[] DEFAULT array[]::varchar[];

转换为特定类型的数组

    array[]::varchar[]
    '{}'::text[]

# insert array

    INSERT INTO stus (name, names) VALUES ( 'John Doe', ARRAY [ 'john1', 'john2' ]);

or use bracket to insert:

    INSERT INTO stus (name, phones) VALUES ( 'ahui', '{111,222}');
    INSERT INTO stus (name, names) VALUES ( 'alex', '{"alex1","alex2"}');
    INSERT INTO stus (name, names) VALUES ( 'alex', '{alex1,alex2}');

## array_append
    UPDATE table_name
    SET array_field = array_append(array_field, 'new_element')
    WHERE condition;

# update array

update all array:

    UPDATE stus SET phones = '{"(408)-589-5843"}' WHERE ID = 3;
    update users set reviewers=array['alex','ahuigo'] where id=1;

update one array element:

    UPDATE stus SET phones[2] = '(408)-589-5843' WHERE ID = 3;

# read array

## via index

select first phone number(不是从0开始)

    > SELECT phones[1] FROM stus;
    > SELECT names FROM stus;
    {"alex1","alex2"}

    where phones[0] is null

## loop

    DO
    $do$
    DECLARE
        m   varchar[];
        arr varchar[] := array[['key1','val1'],['key2','val2']];
    BEGIN
        FOREACH m SLICE 1 IN ARRAY arr LOOP
            RAISE NOTICE 'another_func(%,%)',m[1], m[2];
        END LOOP;
    END
    $do$

## 集合判断

注意, 不存在的值(null), 永远为false, 比如`phone[0]` 不存在

    where phones[0]=ANY(array[1,2])
    where NOT phones[0]=ANY(array[1,2])

### in subquery

IN is equivalent to = ANY:
https://www.postgresql.org/docs/current/functions-subquery.html#FUNCTIONS-SUBQUERY-ANY-SOME

    expression operator ANY (subquery)

select any

    select 1 in (select 1);
    select 1=any(select 1);

    select 1=any(array[1,2]);
    select 1 in (1,2);

where in:

    where phones[1]=111
    where code in ('1','2')
    where code=any(ARRAY['1','2'])
    # 不能用 where '1' in codes

any array

    where '182'=ANY(names);
    where 182=ANY(phones);

### all array

`NOT IN` is equivalent to `<> ALL`/`!=ALL`.

    expression operator ALL (subquery)

全不包含:

    SELECT id != ALL('{1,2,3}'::int[])
    SELECT id <> ALL('{1,2,3}'::int[])
    SELECT NOT value_variable = ANY('{1,2,3}'::int[])
    SELECT value_variable != ANY('{1,2,3}'::int[])

### like any

    SELECT 'abc' LIKE ANY('{"ab%","def"}')

### insersection 交集

    SELECT ARRAY[1,4,3] && ARRAY[2,1] -- true
    where (phones && ARRAY['1234','1235'])

### concat并集

    select  ARRAY[1,2,3] || ARRAY[4,5,6]

### 子集

    select ARRAY[1,4,3] @> ARRAY[3,1]; -- true

## 其它operator

    Operator	Description	                Example	                                Result
    =	        equal	                    ARRAY[1.1,2.1,3.1]::int[] = ARRAY[1,2,3]	t
    <>	        not equal	                ARRAY[1,2,3] <> ARRAY[1,2,4]	            t
    <	        less than	                ARRAY[1,2,3] < ARRAY[1,2,4]	                t
    >	        greater than	            ARRAY[1,4,3] > ARRAY[1,2,4]	                t
    <=	        less than or equal	        ARRAY[1,2,3] <= ARRAY[1,2,3]	            t
    >=	        greater than or equal	    ARRAY[1,4,3] >= ARRAY[1,4,3]	            t
    @>	        contains	                ARRAY[1,4,3] @> ARRAY[3,1,3]	            t
    <@	        is contained by	            ARRAY[2,2,7] <@ ARRAY[1,7,4,2,6]	        t
    &&	        overlap (insersection)	    ARRAY[1,4,3] && ARRAY[2,1]	                t
    ||	        array-to-array concat       ARRAY[1,2,3] || ARRAY[4,5,6]	            {1,2,3,4,5,6}
    ||	        array-to-array concat   	ARRAY[1,2,3] || ARRAY[[4,5,6],[7,8,9]]	    {{1,2,3},{4,5,6},{7,8,9}}
    ||	        element-to-array concat     3 || ARRAY[4,5,6]	                        {3,4,5,6}
    ||	        array-to-element concat     ARRAY[4,5,6] || 7	                        {4,5,6,7}

## submatch`<~~`

参考 pg-expr-operator 定义operator

    // create function reverse_like (text, text) returns boolean language sql as $$ select $2 like $1 $$;
    create or replace function reverse_like (text, text) returns boolean language sql as
    $$ select $2 like $1 $$ immutable parallel safe;

    create operator <~~ ( function =reverse_like, leftarg = text, rightarg=text );

    SELECT 'ab%' <~~ ANY('{"abc","def"}');
    SELECT not 'ab%' <~~ ALL('{"abc","def"}');

## 集合索引
> where entity_ids && '{"67505","69284"}' 能用集合索引
> where '67505'=any(entity_ids) 不能用集合索引

为了加速集合交集运算，我们给字段加GIN 索引(或GIST索引，有类型限制)

    $ CREATE INDEX manual_task_info_entity_ids_gin_idx ON table USING gin(entity_ids);

可以看到用上了索引：`manual_task_info_entity_ids_gin_idx`

    $ EXPLAIN select a.id from task_infos a where a.space_id = 1 and entity_ids && '{"67505","69284"}'
     Bitmap Heap Scan on manual_task_infos a  (cost=19.06..72.40 rows=17 width=8)
       Recheck Cond: (entity_ids && '{67505,69284}'::text[])
       Filter: (space_id = 1)
       ->  Bitmap Index Scan on manual_task_info_entity_ids_gin_idx  (cost=0.00..19.06 rows=48 width=0)
             Index Cond: (entity_ids && '{67505,69284}'::text[])

但是如果输入array非常长（上万个元素），求交集就无法用上GIN 索引

    $ EXPLAIN select a.id from task_infos a where a.space_id = 1 and entity_ids && '{"67505","69284",...,"27501"}'
     Seq Scan on manual_task_infos a  (cost=0.00..40545.43 rows=51245 width=8)
        Filter: ((entity_ids && '{67505,69284,27501,27067,2....}'))

此时可以考虑使用bloomFilter 过滤器、Elasticsearch等, 
或者使用JOIN，将ARRAY拆分成单个元素, 再求交集`entity_ids && ARRAY[ids.id]` 就可以利用索引了(Note: JOIN表的数量也不能太大，否则JOIN也会很慢)

    # CREATE TEMP TABLE ids AS ( SELECT unnest(ARRAY[...]) as element);
    $ EXPLAIN WITH ids(id) AS ( VALUES('67505'),('69284'), ...)
    select a.id from manual_task_infos a JOIN ids ON entity_ids && ARRAY[ids.id] where  a.space_id = 1 ;
        Nested Loop  (cost=27.18..713748.04 rows=9425121 width=8)
       ->  Values Scan on "*VALUES*"  (cost=0.00..89.80 rows=7184 width=32)
       ->  Bitmap Heap Scan on manual_task_infos a  (cost=27.18..86.22 rows=1312 width=40)
             Recheck Cond: (entity_ids && ARRAY["*VALUES*".column1])
             Filter: (space_id = 1)
             ->  Bitmap Index Scan on manual_task_info_entity_ids_gin_idx  (cost=0.00..26.85 rows=3570 width=0)
                   Index Cond: (entity_ids && ARRAY["*VALUES*".column1])

# Array function

## array length
第二个参数代表维度1维数组

    select array_length(string_to_array(name, 'o'), 1) + 100;
    select array_length(string_to_array('a,b,c', ','), 1);
    where phones is null

## split string

    # 2是最后一个(不是从0开始)
    SELECT string_to_array('ordno-#-orddt-#-ordamt', '-#-');
    SELECT split_part('par1-#-par2-#-part3', '-#-', 2);
        part2

## array_to_string

    select array_to_string(array[1,2], ',');

## sort array

sort intarray only

    CREATE EXTENSION intarray;
    SELECT sort( ARRAY[4,3,2,1] );

A function that works for any array type is:

    CREATE OR REPLACE FUNCTION array_sort (ANYARRAY)
    RETURNS ANYARRAY LANGUAGE SQL
    AS $$
        SELECT ARRAY(SELECT unnest($1) ORDER BY 1)
    $$;

## 聚合array

### expand array(反聚合unnest)

    > WITH T(id, uids)
    AS (SELECT 1,array[1,2] UNION ALL
        SELECT 2,array[3,4]
    )
    SELECT unnest(uids) uid,id FROM T ;
    // output
    uid | id 
    -----+----
    1 |  1
    2 |  1
    3 |  2
    4 |  2

    ahuigo=# select 'item' name,unnest(array[1,2]) b;
    name | b
    ------+---
    item | 1
    item | 2

### join array(string_agg)

    ahuigo=# select name,phone from stus;
    John     |      
    ahui     |     3
    ahui     |     4
    ahuigo=# SELECT name, string_agg(phone::char, ', ') AS phonelist FROM   stus GROUP  BY 1; -- 1代表select 第一个 name
    John     | 
    ahui     | 3, 4

string_agg with distinct:

    SELECT name, string_agg(distinct phone::char, ', ') AS phonelist FROM   stus GROUP  BY 1;

string_agg with order by

    string_agg(phone::char, ', ' order by phone desc)

### array_agg(unnest反向)

    > SELECT name, array_agg(phone) AS ps FROM stus group by 1;
    ahui     | {NULL,NULL,3,4,4,5}

agg 可能为null

    select array_agg(phone) is not NULL from t;

array_agg with distinct(unique)

    ahuigo=# SELECT name, array_agg(distinct phone::char) AS ps FROM   stus group by 1;
    ahui     | {3,4,5,NULL}

array_agg 后判断集合

    // select 与 having 中的`array_agg()` 不会重复计算
    SELECT name, array_agg(distinct phone) AS ps FROM   stus group by 1 having 3=any(array_agg(distinct phone));

### merge array
合并array：

    select array_agg(c) from (
        select unnest(column_name) from table_name
    ) as dt(c);

或者使用 AGGREGATE

    CREATE AGGREGATE array_cat_agg(anyarray) (
        SFUNC=array_cat,
        STYPE=anyarray
    );

    WITH v(a) AS ( VALUES (ARRAY[1,2,3]), (ARRAY[4,5,6,7]))
    SELECT array_cat_agg(a) FROM v;
## 转换为特定类型的数组
利用CAST 类型转换，将text[] 转换成 integer[]:

    SELECT ARRAY(SELECT CAST(unnest(array['200','301']::text[]) AS integer));

这在alter column 时很方便： https://dba.stackexchange.com/a/331422/279664

    -- func--
    CREATE OR REPLACE FUNCTION convert_text_array_to_int_array(text[])
    RETURNS integer[] AS $$
        SELECT ARRAY(SELECT CAST(unnest($1) AS integer));
    $$ LANGUAGE SQL IMMUTABLE;

    ALTER TABLE apis ALTER COLUMN codes DROP DEFAULT;
    ALTER TABLE t ALTER COLUMN codes TYPE integer[] USING convert_text_array_to_int_array(codes);
    ALTER TABLE apis ALTER COLUMN codes SET DEFAULT '{}';


## compare

### is empty array

array_length() requires two parameters, the second being the dimension of the
array:

    array_length(id_clients, 1) > 0
    SELECT array_length('{{1,2,3},{4,5,6}}'::integer[][] , 2); -- 3
    SELECT array_length('{}'::integer[] , 1); -- null

compare it to an empty array:

    id_clients = '{}'
    id_clients is NULL

That's all. You get:

    select array[]::text[]='{}'; //true
    select array[]::text[] is NULL; //false
    select array[]::text[]=NULL; //null (不能这样比较, 用等号永远得到空集)

    select null::text[]='{}'; //null
    select null::text[] is NULL; //true
