---
title: pg ddl meta
date: 2022-02-24
private: true
---
# pg ddl meta

## list all tables
all索引表 information_schema.table_constraints

    > select tco.table_name,tco.constraint_name,tco.constraint_type from information_schema.table_constraints tco limit 1000;
    > select tco.table_name,tco.constraint_name,tco.constraint_type from information_schema.table_constraints tco where tco.table_name='current_workflow'

all tables: information_schema.tables

    > select tab.table_name,tab.table_schema,table_type from information_schema.tables tab where tab.table_schema='public' group by tab.table_name,tab.table_schema,tab.table_type;

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
