---
title: Posgtre Var Expression
date: 2019-06-20
private:
---
# define variable
    variable_name data_type [:= expression];
    vSite varchar DEFAULT 'TechOnTheNet.com';

example:

    DO $$ 
    DECLARE
        counter    INTEGER := 1;
        payment    NUMERIC(11,2) := 20.5;
        first_name VARCHAR(50) := 'John';
        last_name  VARCHAR(50) := 'Doe';
        mid  integer:= (select max(id) from oauth_tokens);
    BEGIN 
        RAISE NOTICE '% % % has been paid % USD', counter, first_name, last_name, payment;
    END $$;

# select into variable
    CREATE or replace FUNCTION get_userid(username text) RETURNS int
    AS $$
        DECLARE userid int;
        BEGIN
            -- 二选一
            -- SELECT id INTO userid FROM myusers WHERE name = username; 
            SELECT id FROM myusers WHERE name = username into userid;
            RETURN userid;
        END
    $$ LANGUAGE plpgsql;

# print var(raise)
    DO $$ 
    DECLARE
       created_at time := NOW();
    BEGIN 
       RAISE NOTICE '%', created_at;
       PERFORM pg_sleep(10);
       RAISE NOTICE '%,%', created_at,created_at;
    END $$;

# loop query

## loop record(for-in)

    DO $$DECLARE r record;
    BEGIN
        FOR r IN SELECT table_schema, table_name FROM information_schema.tables
                WHERE table_type = 'VIEW' AND table_schema = 'public'
        LOOP
            EXECUTE 'GRANT ALL ON ' || quote_ident(r.table_schema) || '.' || quote_ident(r.table_name) || ' TO webuser';
        END LOOP;
    END$$;

# inner variable
### define via set
    my_db=> \set myvar 5
    my_db=> SELECT :myvar;
    my_db=> SELECT :myvar  + 1 AS incrvar;

注意，变量相当于宏替换，字符定义要加引号

    \set myvar $$'hello '$$
    SELECT :myvar||'world';

### defeine via with
    db> WITH myconstants (var1, var2) as (
        values (5, 'foo')
    ) SELECT var1,var2 FROM myconstants

### via session
    set session my.vars.id = '1';
    set session my.vars.id = 1; -- 两者等价，都是text
    select * from myusers where id = current_setting('my.vars.id')::int;

    select pg_typeof(current_setting('my.vars.id')); 
        text
