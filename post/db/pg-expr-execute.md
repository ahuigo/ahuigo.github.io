---
title: Postgre expression
date: 2019-09-08
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

核心:

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