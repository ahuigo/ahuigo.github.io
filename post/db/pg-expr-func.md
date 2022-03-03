---
title: pg func
date: 2021-10-28
private: true
---
# define func

## 基本语法
必须指定语言 `LANGUAGE plpsql|sql`, `$$` 是分割符

    CREATE OR REPLACE FUNCTION increment(i integer) RETURNS integer AS $$
            BEGIN
                    RETURN i + 1;
            END;
    $$ LANGUAGE plpgsql; 

## return select
note： RETURNS NULL ON NULL INPUT;

    CREATE FUNCTION add(integer, integer) 
        RETURNS integer AS 'select $1 + $2;' LANGUAGE SQL IMMUTABLE
        RETURNS NULL ON NULL INPUT;

AS 多个输出:

    CREATE FUNCTION dup(in int, out f1 int, out f2 text)
        AS $$ SELECT $1, CAST($1 AS text) || ' is text' $$ LANGUAGE SQL;

    SELECT * FROM dup(42);
    
## return OUT variable
    CREATE OR REPLACE FUNCTION f2(_tbl regclass, OUT result integer) 
    AS $$
    BEGIN
        EXECUTE format('SELECT (EXISTS (SELECT FROM %s WHERE label = 1))::int', _tbl) INTO result;
    END $$ LANGUAGE plpgsql;


## return variable

    create or replace function f(n int) 
    returns int as $$ 
    begin 
        n:=5; 
        return n; 
    end; 
    $$language 'plpgsql';

## return variable(multiple)

    create function find_film_by_id(
       id int
    ) returns film 
    as $$
      select * from film 
      where label = id;  
    $$ language sql;

使用：

    select find_film_by_id(3);
    select * from find_film_by_id(3) ;

# ddl func
## list func

    \df     list all func
    \df string_to_array
    \df+ string_to_array
    \df+ 'string_to_array'

    \sf[+]  FUNCNAME       show a function's definition
    \df[anptw][S+] [PATRN] list [only agg/normal/procedures/trigger/window] functions
    \dF[+]  [PATTERN]      list text search configurations

## drop func
    \h DROP FUNCTION
    DROP FUNCTION [IF EXISTS] name

# 应用
## update delete limit 
pg update /delete 都不支持limit

可以基于id 有限删除

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
