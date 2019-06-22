---
title: Postgre SQL function
date: 2019-06-20
---
# Postgre SQL function
## 基本语法
必须指定语言 `LANGUAGE plpsql|sql`, `$$` 是分割符

    CREATE OR REPLACE FUNCTION increment(i integer) RETURNS integer AS $$
            BEGIN
                    RETURN i + 1;
            END;
    $$ LANGUAGE plpgsql; 

也可以不指定`$$`

    CREATE FUNCTION add(integer, integer) 
        RETURNS integer AS 'select $1 + $2;' LANGUAGE SQL IMMUTABLE
        RETURNS NULL ON NULL INPUT;

AS 多个输出:

    CREATE FUNCTION dup(in int, out f1 int, out f2 text)
        AS $$ SELECT $1, CAST($1 AS text) || ' is text' $$
        LANGUAGE SQL;

    SELECT * FROM dup(42);
    
### update delete limit 
pg update /delete 都不支持limit, 建议用array 而不是IN:

    DELETE FROM logtable 
        WHERE id = any (array(SELECT id FROM logtable ORDER BY timestamp LIMIT 10));

或者用FUNCTION

    CREATE or replace FUNCTION  update_status() returns character varying as $$
    declare
    match_ret record;
    begin
        SELECT * INTO match_ret FROM product_child WHERE product_status = 2 LIMIT 1 for update ;
        UPDATE product_child SET status_code = '1' where child_code = match_ret.child_code ;

        return match_ret.child_code ;
        commit;
    end ;
    $$ LANGUAGE plpgsql;

# String

## split 
    # split part
    select split_part('part1-#-part2-#-part3', '-#-', 2);

split array

    > select regexp_split_to_array('a,b,c,d', ',');
    -[ RECORD 1 ]---------+----------
    regexp_split_to_array | {a,b,c,d}
    > select string_to_array('a,b,,c,d', ',,');

help:

    \df+ 'string_to_array'

# array

## loop
    DO
    $do$
    DECLARE
    m   varchar[];
    arr varchar[] := array[['key1','val1'],['key2','val2']];
    BEGIN
    FOREACH m SLICE 1 IN ARRAY arr
    LOOP
        RAISE NOTICE 'another_func(%,%)',m[1], m[2];
    END LOOP;
    END
    $do$
