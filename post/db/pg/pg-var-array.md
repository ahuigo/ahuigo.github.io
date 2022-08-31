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
    SELECT ARRAY(SELECT unnest(phones) ORDER BY 1)

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

# update array

update all array:

    UPDATE stus SET phones = '{"(408)-589-5843"}' WHERE ID = 3;

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

# Array function

## array length

第二个参数代表维度1维数组

    select array_length(string_to_array(name, 'o'), 1) - 1
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

### expand array

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

### array_agg

    ahuigo=# SELECT name, array_agg(phone) AS ps FROM   stus group by 1;
    ahui     | {NULL,NULL,3,4,4,5}

agg 可能为null

    select array_agg(phone) is not NULL from t;

array_agg with distinct

    ahuigo=# SELECT name, array_agg(distinct phone::char) AS ps FROM   stus group by 1;
    ahui     | {3,4,5,NULL}

array_agg 后判断集合

    // select 与 having 中的`array_agg()` 不会重复计算
    SELECT name, array_agg(distinct phone) AS ps FROM   stus group by 1 having 3=any(array_agg(distinct phone));

## compare

### is empty array

array_length() requires two parameters, the second being the dimension of the
array:

    array_length(id_clients, 1) > 0

compare it to an empty array:

    id_clients = '{}'

That's all. You get:

    TRUE .. id_clients is empty
    NULL .. id_clients is NULL
    FALSE .. any other case
