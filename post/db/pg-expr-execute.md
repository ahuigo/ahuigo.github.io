---
title: Postgre expression
date: 2019-09-08
private: true
---
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

## quote_ident

    EXECUTE 'UPDATE ' || quote_ident(r.table_name) || 'SET ...

# variable as table
https://stackoverflow.com/questions/35559093/how-to-use-variable-as-table-name-in-plpgsql

    CREATE OR REPLACE FUNCTION f_test()
      RETURNS void AS
    $func$
    DECLARE
       v_table text;
    BEGIN
       FOR v_table IN
          SELECT table_name  
          FROM   information_schema.tables 
          WHERE  table_catalog = 'my_database' 
          AND    table_schema = 'public'
          AND    table_name NOT LIKE 'z_%'
       LOOP
          EXECUTE format('DELETE FROM %I v WHERE v.id > (SELECT max(id) FROM %I)'
                        , v_table, 'z_' || v_table);
       END LOOP;
    END
    $func$  LANGUAGE plpgsql;

# pg sql
## execute dnamic command

    EXECUTE 'SELECT count(*) FROM '
        || quote_ident(tabname)
        || ' WHERE inserted_by = $1 AND inserted <= $2'
    INTO c
    USING checked_user, checked_date;

A cleaner approach is to use format()'s %I specification for table or column names (strings separated by a newline are concatenated):

    EXECUTE format('SELECT count(*) FROM %I '
        'WHERE inserted_by = $1 AND inserted <= $2', tabname)
        INTO c
        USING checked_user, checked_date;

## select 语句
在begin/end 内，select 必须输出保存

    SELECT offer_id FROM users into idx;
    SELECT setval('oauth_tokens_id_seq', mid+100, true) into a;

或者用PERFORM：

    PERFORM offer_id FROM users;
    PERFORM setval('oauth_tokens_id_seq', mid+100, true);