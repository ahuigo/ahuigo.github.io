---
title: PG 的GC
date: 2019-12-10
private: true
---
# PG 的GC
## autovacuum 自动清理
> http://www.postgres.cn/docs/9.4/runtime-config-autovacuum.html
这些设置控制自动清理的缺省行为。

    autovacuum (boolean)
        控制服务器是否应该启动autovacuum守护进程。缺省是开启的。然而， track_counts还必须启用自动清理工作。 这个选项只能在postgresql.conf文件里或者是服务器命令行中设置。

## vacuum
> https://www.postgresql.org/docs/9.5/sql-vacuum.html
手动执行

    VACUUM [ FULL ] [ FREEZE ] [ VERBOSE ] [ table_name ]
    VACUUM [ FULL ] [ FREEZE ] [ VERBOSE ] ANALYZE [ table_name [ (column_name [, ...] ) ] ]
    VACUUM [ ( { FULL | FREEZE | VERBOSE | ANALYZE } [, ...] ) ] [ table_name [ (column_name [, ...] ) ] ]