---
title: pg ddl meta
date: 2022-02-24
private: true
---
# namespace
列出 namespace的oid

    select * from pg_namespace limit 100;
        oid |      nspname       | nspowner(所有者) |     nspacl
    --------+--------------------+-----------------+-------------------------------------------
        14  | pg_catalog         |       10 | 
        220 | public             |       10 | 

# 序列表
pg_class



## list sequence of public
`pg_class.relkind='S'` 代表`id_seq` 

    # via pg_class
    SELECT pc.oid,relname seqname FROM pg_class pc, pg_namespace pn where pc.relnamespace=pn.oid and relkind='S' and pn.nspname='public';

    # via information_schema.sequences
    SELECT sequence_name FROM information_schema.sequences where sequence_schema='public';

relkind 清单

    select   CASE 'r' WHEN 'r' THEN 'table' WHEN 'v' THEN 'view' WHEN 'm' THEN 'materialized view' WHEN 'i' THEN 'index' WHEN 'S' THEN 'sequence' WHEN 's' THEN 'special' WHEN 'f' THEN 'foreign table' WHEN 'p' THEN 'partitioned table' WHEN 'I' THEN 'partitioned index' ELSE 'other' END as "Type";

## list seq with tablename
list table with default seq:

    SELECT scope_schema,table_name,column_default FROM information_schema.columns WHERE column_default LIKE 'nextval%' where table_schema='public';

list real seq_name:

    DO $$
    declare row record;
    BEGIN
        FOR row IN SELECT table_name,column_name,column_default FROM information_schema.columns WHERE column_default LIKE 'nextval%' LOOP
            RAISE NOTICE '%,%,%', row.table_name,row.column_name, substring(row.column_default, $dd$'(\w+)'::regclass$dd$);
        END LOOP;
    END $$;

## fix all sequence:

    DO $$
    declare 
        row record;
        maxid int;
        seq_name text;
    BEGIN
        FOR row IN SELECT * FROM information_schema.columns WHERE  table_schema='public' and column_default LIKE 'nextval%' LOOP
            seq_name := substring(row.column_default, $dd$'(\w+)'::regclass$dd$);
            EXECUTE FORMAT('select max(%I) from %I', row.column_name, row.table_name) into maxid;
            IF maxid notnull THEN
                EXECUTE FORMAT('select setval(%L, %L)', seq_name, maxid);
            END IF;
        END LOOP;
    END $$;


# database
    select oid,datname from pg_database;

## size of database
    select pg_database.datname, pg_size_pretty(pg_database_size(pg_database.datname)) AS size from pg_database;

# meta tables
## tables 表
几种方式：

    select * from pg_tables where schemaname='public';

    # or
    select table_schema,table_name from information_schema.tables tab where tab.table_schema='public';
    SELECT ('"' || table_schema || '"."' || table_name || '"') AS table_name FROM information_schema.tables;

    # or (relkind='r' 指关系表) 
    SELECT pc.oid,relname tablename FROM pg_class pc, pg_namespace pn where relkind='r' and pc.relnamespace=pn.oid and pn.nspname='public';


## 约束表 table_constraints

    select tco.table_name,tco.constraint_name,tco.constraint_type from information_schema.table_constraints tco limit 100;
    select tco.table_name,tco.constraint_name,tco.constraint_type from information_schema.table_constraints tco where tco.table_name='current_workflows';

## 索引表 pg_indexes
    SELECT tablename, indexname, indexdef FROM pg_indexes WHERE schemaname = 'public' ORDER BY tablename, indexname;

## `key_column_usage` 表:

    select kcu.table_name,kcu.column_name from information_schema.key_column_usage kcu limit 10;

## 表大小 `pg_stat_user_tables`
查看各表大小：

    select table_name, pg_relation_size(table_name) from information_schema.tables where table_schema = 'public' order by 2;
    select table_name, pg_total_relation_size(table_name) from information_schema.tables where table_schema = 'public' order by 2;
    select relname, pg_size_pretty(pg_total_relation_size(relid)) from pg_stat_user_tables where schemaname='public' order by pg_relation_size (relid) desc;
        users | 200MB

注意：https://stackoverflow.com/questions/41991380/whats-the-difference-between-pg-table-size-pg-relation-size-pg-total-relatio

    pg_table_size =  pg_relation_size (main+fsm+vm+init) + toastSize(大数据行外存储)
    pg_total_relation_size = pg_table_size + pg_indexes_size 

### toast 技术
TOAST是“The Oversized-Attribute Storage Technique”（超尺寸属性存储技术）的缩写，主要用于存储一个大字段的值。

数据是按页存储的(默认的大小为8KB)。PG不允许一行数据跨页存储。那么对于超长的行数据，PG就会启动TOAST，将大的字段压缩或切片成多个物理行存到另一张系统表中（TOAST表），这种存储方式叫行外存储。

## 综合应用
### list all tables with primary key and unique
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
