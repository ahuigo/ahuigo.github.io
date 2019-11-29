---
title: Postgre Optimize Perfermance
date: 2019-10-09
private: 
---
# Postgre Optimize Perfermance

## get table size

    >> select pg_size_pretty(pg_relation_size('public.users'));
    10M

# index 的性能
https://dreamer-yzy.github.io/2014/12/02/自行测试的1亿条数据中PostgreSQL性能/