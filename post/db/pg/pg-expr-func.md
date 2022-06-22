---
title: pg func
date: 2021-10-28
private: true
---
# define func

## 基本语法
必须指定语言 `LANGUAGE plpsql|sql`, `$$` 是分割符

    CREATE [ OR REPLACE ] FUNCTION
        name ( [ [ argmode ] [ argname ] argtype [ { DEFAULT | = } default_expr ] [, ...] ] )
        [ RETURNS rettype | RETURNS TABLE ( column_name column_type [, ...] ) ]
      { LANGUAGE lang_name
        | ROWS result_rows
        | SUPPORT support_function
        | SET configuration_parameter { TO value | = value | FROM CURRENT }
        | AS 'definition'
        | AS 'obj_file', 'link_symbol'
        | sql_body
      } ...

## return OUT variable
    CREATE OR REPLACE FUNCTION f2(_tbl regclass, OUT result integer) 
    AS $$
    BEGIN
        EXECUTE format('SELECT (EXISTS (SELECT FROM %s WHERE label = 1))::int', _tbl) INTO result;
    END $$ LANGUAGE plpgsql;

AS 多个输出:

    CREATE FUNCTION dup(in int, out f1 int, out f2 text)
        AS $$ SELECT $1, CAST($1 AS text) || ' is text' $$ LANGUAGE SQL;

    SELECT * FROM dup(42);

## return value with sqlbody

    create or replace function f(n int) 
    returns int as $$ 
    begin 
        -- n:=5; 
        return n; 
    end; 
    $$language 'plpgsql';

## return value with definition
note： RETURNS NULL ON NULL INPUT;

    CREATE FUNCTION add(integer, integer) 
        RETURNS integer AS 'select $1 + $2;' LANGUAGE SQL IMMUTABLE
        RETURNS NULL ON NULL INPUT;

## return rows with sqlbody
### single row

    CREATE OR REPLACE FUNCTION listfilm() RETURNS film AS $$
        SELECT * FROM film where code<'code3';
    $$ LANGUAGE sql;

### specify fields
指定为record(one row)

    CREATE OR REPLACE FUNCTION listfilm(OUT code varchar(9), OUT label real) RETURNS record AS $$
            SELECT code, label FROM film where code<'code3';
    $$ LANGUAGE sql;

    -- 使用时可以指定record 的field name
    select * from listfilm() as (code varchar, label real);

multiple rows

    CREATE OR REPLACE FUNCTION listusers() RETURNS TABLE(name varchar, age int) AS $$
        SELECT name,age FROM myusers where name<'zhui';
    $$ LANGUAGE sql;
    select name from listusers();

### multiple rows

    CREATE OR REPLACE FUNCTION listfilm() RETURNS SETOF film AS $$
        SELECT * FROM film where code<'code3';
    $$ LANGUAGE sql;

    select code from listfilm();

## return void
    CREATE OR REPLACE FUNCTION f1(n int)
    RETURNS void AS $$
    begin 
        execute 'select 1';
    end; 
    $$language 'plpgsql';

## for loop iter
见pg-expr-condition.md

## arguments
`$1`,`$2` 是参数变量

    CREATE or replace FUNCTION add(integer, integer) 
        RETURNS integer AS 'select $1 + $2' LANGUAGE SQL;

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
