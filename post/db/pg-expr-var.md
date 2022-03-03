---
title: Posgtre Var Expression
date: 2019-06-20
private:
---
# pg var

## define variable
    variable_name data_type [:= expression];

example:

    DO $$ 
    DECLARE
        counter    INTEGER := 1;
        first_name VARCHAR(50) := 'John';
        last_name  VARCHAR(50) := 'Doe';
        payment    NUMERIC(11,2) := 20.5;
    BEGIN 
        RAISE NOTICE '% % % has been paid % USD', counter, first_name, last_name, payment;
    END $$;

### print var(raise)
    DO $$ 
    DECLARE
       created_at time := NOW();
    BEGIN 
       RAISE NOTICE '%', created_at;
       PERFORM pg_sleep(10);
       RAISE NOTICE '%', created_at;
    END $$;


## 写值

### For-In 写值

    DO $$DECLARE r record;
    BEGIN
        FOR r IN SELECT table_schema, table_name FROM information_schema.tables
                WHERE table_type = 'VIEW' AND table_schema = 'public'
        LOOP
            EXECUTE 'GRANT ALL ON ' || quote_ident(r.table_schema) || '.' || quote_ident(r.table_name) || ' TO webuser';
        END LOOP;
    END$$;

### set variable
    Variables
    \prompt [TEXT] NAME    prompt user to set internal variable
    \set [NAME [VALUE]]    set internal variable, or list all if no parameters
    \unset NAME            unset (delete) internal variable


