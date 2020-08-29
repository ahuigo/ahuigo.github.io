---
title: pg sql
date: 2020-08-25
private: true
---
# 参考
http://www.postgres.cn/docs/9.3/plpgsql-structure.html

# pg sql
    [ <<label>> ]
    [ DECLARE
        declarations ]
    BEGIN
        statements
    END [ label ];

# BEGIN END

    DO $$
    DECLARE myvar integer = 5;
    BEGIN
        CREATE TEMP TABLE tmp_table ON COMMIT DROP AS
            -- put here your query with variables:
            SELECT * 
            FROM yourtable
            WHERE id = myvar;
    END $$;

    SELECT * FROM tmp_table;

# declare

    do $$ 
    declare
        counter    integer := 1;
        first_name varchar(50) := 'John';
        last_name  varchar(50) := 'Doe';
        payment    numeric(11,2) := 20.5;
    begin 
        raise notice '% % % has been paid % USD', 
            counter, 
            first_name, 
            last_name, 
            payment;
    end $$;
