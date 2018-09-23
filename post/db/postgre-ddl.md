# FUNCTION
pg update /delete 都不支持limit, 建议用array 而不是IN:

    DELETE FROM logtable 
        WHERE id = any (array(SELECT id FROM logtable ORDER BY timestamp LIMIT 10));

或者用

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

# crud
## database

    $ createdb test1
    > CREATE DATABASE yuzhi100 OWNER myuser;
    > drop database yunzhi100

    \l
        list all databases
    \c database_name
        \connect database_name
    SELECT current_database();


## table

### create

    CREATE TABLE playground (
        id serial PRIMARY KEY,
        uid int UNIQUE,
        name varchar (50) NOT NULL,
        location varchar(25) check (location in ('north', 'south', 'west', 'east',  'northwest')),
        install_date date
    );

describe table and sequence:

    \d
    \dt [<table>]

### drop

    drop TABLE [IF EXISTS ] xxx

## Alter
ALTER TABLE table_name `<action>`:

    column:
        ADD COLUMN column_name VARCHAR;
        DROP COLUMN column_name;
        ALTER COLUMN location TYPE VARCHAR,
            ALTER COLUMN asset_no TYPE INT USING asset_no::integer;
            ALTER COLUMN column_name [SET DEFAULT value | DROP DEFAULT]
            ALTER COLUMN column_name [SET NOT NULL| DROP NOT NULL]
        RENAME COLUMN column_name TO new_column_name;

    check:
        ADD CHECK (target IN ('_self', '_blank', '_parent', '_top'));
    tablename:
        RENAME TO new_table_name;
    constraint:
        ADD CONSTRAINT constraint_name constraint_definition