---
title: pg partial index
date: 2021-07-25
private: true
---
# pg partial index
## partial index
要创建符合例子的索引，使用像下面这样的命令：

    CREATE INDEX access_log_client_ip_ix ON access_log (client_ip)
    WHERE NOT (client_ip > inet '192.168.100.0' AND
            client_ip < inet '192.168.100.255');

一个可以使用这个索引的典型的查询像这样：

    SELECT *
    FROM access_log
    WHERE url = '/index.html' AND client_ip = inet '212.78.10.32';

一个不能使用这个索引的查询是：

    SELECT *
    FROM access_log
    WHERE client_ip = inet '192.168.100.23';

## partial time 

    CREATE INDEX current_workflow_close_time_ix ON current_workflows(close_time)
    WHERE (close_time < '0001-02-02');

### explain 分析
参考： PgSQL · 最佳实践 · EXPLAIN 使用浅析 http://mysql.taobao.org/monthly/2018/11/06/

未使用索引

    => explain select * from current_workflows where close_time<'0001-03-01' and status='' limit 20;
    Limit  (cost=0.00..4.47 rows=20 width=109)
    ->  Seq Scan on current_workflows  (cost=0.00..11182.56 rows=50083 width=109)
            Filter: ((close_time < '0001-03-01 00:00:00+08:05:43'::timestamp with time zone) AND (status = ''::text))


使用索引：

    => explain select * from current_workflows where close_time<'0001-02-01' and status='' limit 20;
    Limit  (cost=0.29..3.49 rows=20 width=109)
    ->  Index Scan using current_workflow_close_time_ix on current_workflows  (cost=0.29..8010.40 rows=50083 width=109)
            Index Cond: (close_time < '0001-02-01 00:00:00+08:05:43'::timestamp with time zone)
            Filter: (status = ''::text)

## partial key 

    CREATE INDEX ON current_workflows(close_time) 
        WHERE (close_time < '0001-02-02');