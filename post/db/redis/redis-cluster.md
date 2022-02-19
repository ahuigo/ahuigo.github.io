---
title: redis cluster
date: 2021-06-16
private: true
---
# redis cluster
rediscluster采用了哈希分区的“虚拟槽分区”方式（哈希分区分节点取余、一致性哈希分区和虚拟槽分区）


   RedisCluster采用此分区，所有的键根据哈希函数(CRC16[key]&16383)映射到0－16383槽内，共16384个槽位，每个节点维护部分槽及槽所映射的键值数据

   哈希函数: Hash()=CRC16[key]&16383 按位与

redis用虚拟槽分区原因：解耦数据与节点关系，节点自身维护槽映射关系，分布式存储

## redisCluster的缺陷：
1. 键的批量操作支持有限，比如mset, mget，如果多个键映射在不同的槽，就不支持了
1. 键事务支持有限，当多个key分布在不同节点时无法使用事务，同一节点是支持事务
1. 键是数据分区的最小粒度，不能将一个很大的键值对映射到不同的节点
1. 不支持多数据库，只有0，select 0
1. 复制结构只支持单层结构，不支持树型结构。 