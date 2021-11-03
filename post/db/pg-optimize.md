---
title: Postgre Optimize Perfermance
date: 2019-10-09
private: 
---
# Postgre Optimize Perfermance

## get table size

    >> select pg_size_pretty(pg_relation_size('public.users'));
    10M

## 慢查询
    select 
    datname as "DBName",
    client_addr as "client_addr",
    client_hostname as "client_hostname",
    backend_start as "backend_start",
    xact_start as "xact_start",
    state as "state",
    query as "query"
    from pg_stat_activity
    where state<>'idle'
    and now()-query_start > interval '1 s' 
    order by query_start ; 

## 连接数
    select datname ,numbackends from pg_stat_database where numbackends > 20;

# index 的性能
https://dreamer-yzy.github.io/2014/12/02/自行测试的1亿条数据中PostgreSQL性能/
