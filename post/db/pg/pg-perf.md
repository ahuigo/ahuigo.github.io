---
title: Postgre Optimize Perfermance
date: 2019-10-09
private: 
---
# Postgre Optimize Perfermance
## Some perf tips
https://blog.crunchydata.com/blog/five-tips-for-a-healthier-postgres-database-in-the-new-year

1. Set a statement timeout
   1. ALTER DATABASE mydatabase SET statement_timeout = '60s';
1. Ensure you have query tracking CREATE EXTENSION pg_stat_statements;
1. Log slow running queries
1. Improve your connection management(connection pool )
1. Find your goldilocks range for indexes

## slow logs
### config slow logs
全局config

    #1. vim /opt/homebrew/var/postgres/postgresql.conf
    log_min_duration_statement = 5000 # log if >5s
    #2. reload config
    > SELECT pg_reload_conf();

只修改单数据库的log conf：

    ALTER DATABASE test SET log_min_duration_statement = 5000;

测试一个slow sql：

    SELECT pg_sleep(10);

查询慢日志: todo
### 慢查询(实时)
超过1s的当前正在运行的sql:

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

## get table size

    >> select pg_size_pretty(pg_relation_size('public.users'));
    10M


## 连接数
    select datname ,numbackends from pg_stat_database where numbackends > 20;

# index 的性能
https://dreamer-yzy.github.io/2014/12/02/自行测试的1亿条数据中PostgreSQL性能/
