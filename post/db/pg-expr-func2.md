---
title: pg sql
date: 2020-08-25
private: true
---
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

## notice

    raise notice '% % % has been paid % USD', counter, first_name, last_name, payment;

# execute
    DO $$
    DECLARE r record;
    BEGIN
        FOR r IN SELECT table_name 
                    FROM information_schema.tables
                    WHERE table_catalog = 'public'
        LOOP
            EXECUTE format('UPDATE %I SET id = 10 WHERE id = 15', r.table_name);
        END LOOP;
    END $$;

核心:

    EXECUTE 'UPDATE ' || quote_ident(r.table_name) || 'SET ...

# echo & format

    do $$ 
    declare
        first_name varchar(50) := 'John';
        str varchar(100) := format('ahui' 'Im %I', first_name);
    begin 
        raise notice 'Value: %', str;
    end $$;