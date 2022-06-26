---
title: Postgre expression
date: 2019-09-08
private: true
---
# execute command
    EXECUTE command-string [ INTO [STRICT] target ] [ USING expression [, ... ] ];

## with format
https://stackoverflow.com/questions/35559093/how-to-use-variable-as-table-name-in-plpgsql

## execute with format
return single field(one row)

    CREATE OR REPLACE FUNCTION listusers(OUT name varchar) AS $$
    BEGIN
        EXECUTE FORMAT('select name from %I where %I<=%L','myusers', 'name', 'zhui') into name;
    END$$ LANGUAGE plpgsql;
    select name from listusers();

return multiple fields(one row)

    CREATE OR REPLACE FUNCTION listusers() RETURNS RECORD AS $$
    DECLARE 
        ret RECORD;
    BEGIN
        EXECUTE FORMAT('select name,age from %I where %I<=%L','myusers', 'name', 'zhui') into ret;
        return ret;
    END$$ LANGUAGE plpgsql;
    select name from listusers() as (name varchar, age int);

return rows:

    CREATE OR REPLACE FUNCTION listusers() RETURNS SETOF myusers AS $$
    BEGIN
        RETURN QUERY EXECUTE FORMAT('select * from %I where %I<=%L','myusers', 'name', 'zhui');
    END$$ LANGUAGE plpgsql;

## execute with using variables
`$1` 代表变量

    CREATE OR REPLACE FUNCTION f1(a int,b int, OUT o int)
    RETURNS int AS $$
    begin 
        execute 'select $1+$2' INTO o USING a+1,b;
    end; 
    $$language 'plpgsql';

## quote_ident(双引号)

    EXECUTE 'UPDATE ' || quote_ident(r.table_name) || 'SET ...

# PERFORM
1. PERFORM 是表达式
The PERFORM statement is used for function calls, when functions are not used in assignment statement. 
2. Execute 是执行的字符串
The EXECUTE is used for evaluation of dynamic SQL - when a form of SQL command is known in runtime.

The PERFORM statements execute a parameter and forgot result.

    -- direct call from SQL
    SELECT foo();

    -- in PLpgSQL
    DO $$
    declare b int;
    BEGIN
        SELECT foo(); -- is not allowed
        PERFORM foo(); -- is ok
        SELECT foo() into b; -- is ok
    END;
    $$;

PERFORM 是不要结果的select

    DO $$
    BEGIN
        perform 'name from myusers';-- like `SELECT 'name from users'` but forgot result.
        PERFORM name FROM myusers; -- like: select name from users;
    END $$;

