---
title: pg ddl meta
date: 2022-02-24
private: true
---
# pg ddl meta

## meta tables
tables 表

    select tab.table_name from information_schema.tables tab limit 10;
    select tab.table_name,tab.table_schema,table_type from information_schema.tables tab where tab.table_schema='public' group by tab.table_name,tab.table_schema,tab.table_type;

索引表 table_constraints

    select tco.table_name,tco.constraint_name,tco.constraint_type from information_schema.table_constraints tco limit 100;
    select tco.table_name,tco.constraint_name,tco.constraint_type from information_schema.table_constraints tco where tco.table_name='current_workflows';

key_column_usage 表:

    select kcu.table_name,kcu.column_name from information_schema.key_column_usage kcu limit 10;

## list all tables with primary key and unique
    select tab.table_schema,
        tab.table_name,
        tco.constraint_name as key_name,
        string_agg(kcu.column_name, ', ') as key_columns
    from information_schema.tables tab
    left join information_schema.table_constraints tco
            on tco.table_schema = tab.table_schema
            and tco.table_name = tab.table_name
            and tco.constraint_type in ('PRIMARY KEY', 'UNIQUE')
    left join information_schema.key_column_usage kcu 
            on  kcu.constraint_name = tco.constraint_name
            and kcu.constraint_schema = tco.constraint_schema
    where tab.table_schema not in ('pg_catalog', 'information_schema')
        and tab.table_type = 'BASE TABLE'
    group by tab.table_schema,
            tab.table_name,
            tco.constraint_name
    order by tab.table_schema,
            tab.table_name;
