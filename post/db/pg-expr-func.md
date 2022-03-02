---
title: pg func
date: 2021-10-28
private: true
---
# pg func
## return int
    CREATE OR REPLACE FUNCTION some_f(_tbl regclass, OUT result integer)
    LANGUAGE plpgsql AS $func$
    BEGIN
        EXECUTE format('SELECT (EXISTS (SELECT FROM %s WHERE id = 1))::int', _tbl)
        INTO result;
    END
    $func$;

eg2:

    create or replace function f(n int) 
    returns int as $$ 
    begin 
        n:=5; 
        return n; 
    end; 
    $$language 'plpgsql';

## return table

    create function find_film_by_id(
       id int
    ) returns film 
    language sql
    as 
    $$
      select * from film 
      where film_id = id;  
    $$;

使用：

    select find_film_by_id(3);
