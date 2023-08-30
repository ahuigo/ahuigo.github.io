---
title: aliyun log search
date: 2023-08-24
private: true
---
## aliyun log search 入口
查询方法(https://help.aliyun.com/zh/sls/user-guide/query-and-analyze-logs)
1. 左侧搜索sls 或 log service ，进入日志控制台 https://sls.console.aliyun.com/lognext/profile
2. 在Project列表区域，单击目标Project(按集群分的)
3. 在日志存储 > 日志库页签中，单击目标Logstore。

## 查询语法

### fulltext
    Method:Get* and not status:200

### sql
    * | select host,client_ip,url,COUNT(*) as count from log where url like '/p/product/%' GROUP BY host,client_ip,url ORDER BY count DESC LIMIT 1000000

## 导出