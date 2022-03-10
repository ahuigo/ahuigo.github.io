---
title: cassandra 初识
date: 2019-10-03
private: true
---
# cassandra
refer:
3. https://www.datastax.com/blog/maximizing-cache-benefit-cassandra
1. https://teddymaef.github.io/learncassandra/cn/model/cql_and_data_structure.html
2. https://www.infoq.cn/article/j0mfq1cntskbk5rbdpvl

Cassandra一般被认为是满足AP的系统，也就是说Cassandra认为可用性和分区容忍性比一致性更重要。不过Cassandra可以通过调节replication factor和consistency level来满足C

## OLTP
cass 是OLTP(OnLine Transaction Processing)数据库，面向的是row, 而非column(column 是局部有序的), 不适合做大量数据的聚合运算
# key

## Partition Key(row key)
1. row 是按partition key 做hash定位的, 所以不适合做数据聚合
2. select 必须加`Where Partition Key` (通过 HASH 索引定位记录)，除非加`ALLOW FILTERING` (做一次 全量的TABLE SCAN)，

## Clustering Key(column key)
范围查找、Order by 一类的语法都需要使用 Clusterting Key。

在定位的 Partition Key 确定了位置之后，同一 Partition Key 的数据，都是 Clusterting Key 有序存放的，那么通过在这个有序的 Key 列上，无论范围也好、排序也好，都不会需要数据库引擎真正去排序

## Key and Row Cache
参考 https://www.datastax.com/blog/maximizing-cache-benefit-cassandra

cassandra 有两种cache
1. key cache 存储的column key(实际为磁盘的offset, 可避免磁盘寻道)
2. row cache 存储的row 全部数据(只存热数据)

读取row 过程:
1. 先检查row cache， 如果有就返回
2. 再检查key cache, 如果没有就没有了。否则就继续下一步（磁盘读取）
3. 去`SSTables` on disk 读取数据到内存 memtables
4. key cache 中的hit_count++, 如果较热就存储到 `row cache`
5. 返回最row 数据

# install cqlsh
    pip install cql

## connect
    cqlsh 10.0.0.30
    cqlsh --cqlversion=3.4.4 --username=cassandra --password=password host 9042

