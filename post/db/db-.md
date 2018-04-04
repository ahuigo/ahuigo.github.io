# 数据库

## CAP定理（CAP theorem）
CAP定理（CAP theorem), 指出对于一个分布式计算系统来说，不可能同时满足以下三点:

1. 一致性(Consistency) (所有节点在同一时间具有相同的数据)
2. 可用性(Availability) (每次请求都能获取到非错的响应——但是不保证获取的数据为最新数据)
3. 分区容忍(Partition tolerance) 系统如果不能在时限内达成数据一致性，就意味着发生了分区的情况，必须就当前操作在C和A之间做出选择

理解CAP理论的最简单方式是：节点组成的网络，因为故障，形成互不相通的区域，即分区P, 此时要在C与A之间做权衡：
1. 当数据只在一个节点存在时，那么分区出现时，其它分区的节点就不可以访问了. 分区P无法容忍的。
2. 提高分区容忍P，就需要越多的节点备份, 节点之间就有C一致性 的问题
3. 提高一致性C, 就需要越多的等待，降低了可用性(响应慢)

## ACID
原子性(Atomicity)
一致性(Consistency)
隔离性(Isolation)
持久性 (Durable)

# 数据库分类

## PostgreSQL
1. 支持bjson, geo, 可代替mongoDB
2. 标准SQL
3. pg 与 mysql/mariaDB，可类比python3 vs python2