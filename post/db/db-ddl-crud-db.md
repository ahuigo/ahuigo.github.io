# database curd
## database

    $ createdb test1
    > CREATE DATABASE yuzhi100 OWNER myuser;
    > drop database yunzhi100

    \l
        list all databases
    \connect database_name


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