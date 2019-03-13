---
title: 数据库CAP 理论 与事务
date: 2018-09-27
---
# CAP定理（CAP theorem）
CAP定理（CAP theorem), 指出对于一个分布式计算系统来说，不可能同时满足以下三点:

1. 一致性(Consistency) (所有节点在同一时间具有相同的数据)
2. 可用性(Availability) (每次请求都能获取到非错的响应——但是不保证获取的数据为最新数据)
3. 分区容忍(Partition tolerance) 系统如果不能在时限内达成数据一致性，就意味着发生了分区的情况，必须就当前操作在C和A之间做出选择

理解CAP理论的最简单方式是：节点组成的网络，因为故障，形成互不相通的区域，即分区P, 此时要在C与A之间做权衡：
1. CP: 保证C 一致性，各个分区不可以写数据，失去的可用性A。 一般使用严格的法定数协议 (paxos, raft, zab)或者2PC协仪。有 MongoDB， HBase， Zookeeper等
1. AP: 保证A 可用性，各个分区可以写数据，失去的一致性C. 有 Couch DB，Cassandra，Amazon Dynamo等

## 事务ACID
原子性(Atomicity)
一致性(Consistency)
隔离性(Isolation)gT
持久性 (Durable)

# 一致性协议
todo参考:
https://zhuanlan.zhihu.com/p/25933039
https://juejin.im/post/5aa3c7736fb9a028bb189bca
https://www.jianshu.com/p/7ef9c48164e3

为了使基于分布式系统架构下的所有节点在进行事务提交时保持一致性而设计的协议. 分两类：
1. 中心化协议：引入了协调者-参与者
    1. 一阶段提交：协调者发送提案给参与者执行，当某参与者出现问题时就不好办了
    1. 二阶段提交：
    2. 三阶段提交：
2. 非中心化自治性的一致性协议：paxos(zk为实现)、raft

## 2PC(Two-phaseCommit)
下述流程图简单示意了二阶段提交算法中协调者和参与者之间的通信流程

        协调者                                              参与者
                                QUERY TO COMMIT
                    -------------------------------->
                                VOTE YES/NO           prepare*/abort*
                    <-------------------------------
    commit*/abort*                COMMIT/ROLLBACK
                    -------------------------------->
                                ACKNOWLEDGMENT        commit*/abort*
                    <--------------------------------  
    "*" 所标记的操作意味着此类操作必须记录在稳固存储上.[1]


当一个事务跨多个节点时， 为了让参与者(Cohort)知道别的节点(Cohort)是否成功，就引入了协调者(Coordinator):
1. PreCommit Phase: 协调者发送提案发给给参与者准备提交, 并`等待`所有的参与者反馈投票
    1. Cohort 收到PreCommit后会写Undo/Redo
    2. Cohort 如果此事务执行成功，返回Yes，否则返回NO
    3. Cohort 等待Commit phase 的指令
2. Commit Phase: 当所有参与者返回或任一参与者超时后, 协调者发出commit/rollback
    1. 成功: 当协调者节点从所有参与者节点获得的相应消息都为"同意"时：
        1. 参与者节点正式完成操作，并释放在整个事务期间内占用的资源。
            1. Cohort 超时都没有收到commit，就会造成不一致。3PC 就提出了超时自动Commit(但3PC还是无法解决分区不一致)
        1. 参与者节点向协调者节点发送"完成"消息。
        1. 协调者节点收到所有参与者节点反馈的"完成"消息后，完成事务。
    2. 失败: 如果任一参与者节点在第一阶段返回的响应消息为"终止"，或者 协调者节点在第一阶段的询问超时
        1. 参与者节点利用之前写入的Undo信息执行回滚，并释放在整个事务期间内占用的资源。
        1. 参与者节点向协调者节点发送"回滚完成"消息。
        1. 协调者节点收到所有参与者节点反馈的"回滚完成"消息后，取消事务。

### 2PC vs 3PC
1. 超时机制（在2PC中，只有协调者拥有超时机制，即如果在一定时间内没有收到cohort的消息则默认失败）。
2. 3PC 插入了CanCommit 确认提交条件
3. 结果
    1. 2PC 则会因为任一点超时就状态`回滚`、`状态阻塞更严重`、还有协调者与参考者同时挂导致的不一致问题
    1. 3PC 只是让2PC 的Cohort 状态在超时`继续`走下去，但是引入了分区不一致的问题。


### 2PC 的Coordinator问题明细
> 参考 忘净空 链接：https://www.jianshu.com/p/7ef9c48164e3
其中1-5的一致性不会被破坏或者可以解决，而6就是3PC想解决的问题。挂掉后，会有选新Coordinator
1. Coordinator在发出Prepare消息之前出错，全部Cohort出错（回滚undo）
1. Coordinator在发出Prepare消息之前出错，部分Cohort出错（全部回滚undo）
1. Coordinator在发出Prepare消息之后出错，全部Cohort出错（回滚undo）
1. Coordinator在发出Prepare消息之后出错，部分Cohort出错（全部undo)
1. Coordinator在发出Commit消息之后出错，全部Cohort出错（没有不一致）
1. Coordinator在发出Commit消息之后出错，部分Cohort出错（比如，只有一Cohort收到commit指令，进行实际操作，而他执行之后又出错了。那么即便没有出错的Cohort选出了一个新的Coordinator，他也无法获知此项操作的最终结果是commit还是abort）

在CommitPhase 阶段发生的问题时：(commit 后就不能回滚了)
1. 协调者正常：某个Cohort 超时或异常返回，再次向所有的Cohort 发送rellback(基于undo 日志)
1. 协调者不正常：正常发出DoCommit, 协调者中断。会启动新的Coordinator 默认之前事务没有问题
   1. 所有的参与者都收到DoCommit并执行成功：新的Coordinator 不用管 没有不一致的问题(刷新请求查看最新数据)
   1. 所有的参与者没有收到DoCommit：新的Coordinator 不用管，没有不一致性的问题（刷新请求）
   1. `部分`的参与者收到DoCommit: 新的Coordinator 不用管，就有一部分成功、一部分失败
        1. 3PC 就提出了超时自动Commit(但3PC 在发生分区时，部分节点会因收到rollback 导致分区不一致)
        2. 2PC 方案修复: 新coordinator 引入修复程序：遍历出所有的节点，找出不一致，然后：
           1. 全部回滚
           2. 全部补齐, 这两个是二选一的难题

## 3PC(Three-phaseCommit)
CC BY 3.0, https://en.wikipedia.org/w/index.php?curid=16452453
![](/img/arch/Three-phase_commit.png.png)

1. CanCommit阶段: 确定Cohort具备基本的完成Commit条件, (像2PC的PreCommit, 但是不执行事务)
    1. 协调者发送CanCommit请求
    2. 参与者如果可以提交就返回Yes响应，否则返回No响应。
        1. 如何判断是否可以提交不同的算法有不同的机制
    3. 参与得进入等待preCommit的状态
        2. Timeout的话，参与者就abort 退出事务状态（还没有执行过事务, 没有undo/redo）
2. PreCommit阶段: 
    1. 如果Coordinator从所有的Cohort获得的反馈都是Yes响应，那么就会进行事务的PreCommit：
        1. 发送预提交请求。Coordinator向Cohort发送PreCommit请求，并进入Prepared阶段。
        2. 事务预提交。Cohort接收到PreCommit请求后，会执行事务操作
           1. 并将undo和redo信息记录到事务日志中。
        3. 响应反馈。如果Cohort成功的执行了事务操作，则返回ACK响应
            1. (Cohor 没有收到preCommit超时后也会自动中断)
        4. Cohort开始等待最终Commit 指令
            1. Timeout 就自动提交commit事务
    2. 如果任何一个Cohort发送了No响应，或者等待超时后，Coordinator那么就中断事务：
        1. 发送中断请求。向所有Cohort发送abort请求。
        2. 中断事务。所有Cohor 执行事务的中断。(Cohor 没有收到preCommit超时后也会自动中断)
        3. 响应反馈No
3. DoCommit阶段: 可以分为以下两种情况。
    1. 执行提交
        1. 发送提交请求。
           1. Coordinator接收到Cohort发送的ACK响应，那么他将从预提交状态(Prepared)进入到提交状态。并向所有Cohort发送doCommit请求。
        2. 事务提交。
           1. Cohort接收到doCommit请求之后，执行正式的事务提交。并在完成事务提交之后释放所有事务资源。
           2. Cohort 超时没有收到doCommit 也会自动提交。既然能走到二阶段的话，那自动提交出问题的概率很小。所以3PC没有解决`有分区不一致的情况`
        3. 响应反馈。
            事务提交完之后，向Coordinator发送ACK响应。
        4. 完成事务。Coordinator接收到所有Cohort的ACK响应之后，完成事务。
    2. 中断事务
        1. 发送中断请求。Coordinator向所有Cohort发送abort请求
        2. 事务回滚。Cohort利用其在阶段二记录的undo信息来执行事务的回滚操作，并在完成回滚之后释放所有的事务资源。
        3. 反馈ACK消息
        4. 中断事务。Coordinator 执行事务的中断。

## Paxos & Raft 
来源： [S 先生@喔家ArchiSelf][CAP理论与分布式系统设计]( https://mp.weixin.qq.com/s?__biz=MzAwOTcyNzA0OQ==&mid=2658972342&idx=1&sn=e613eff26d6ffccf0641510aae0a4acb)
![](/img/arch/arch-cap-proto.png)

2PC/3PC 引入的协调者有单点问题，无法应对分区问题。这时不得不提到Paxos了

1. Paxos 论证了自治性的一致性协议的可行性，但是paxos实现比较复杂，只有zk实现了zab协议。
2. Raft 则是对Paxos做的精简的分布式一致性复制协议。

Raft 图解
http://raftconsensus.github.io/
http://thesecretlivesofdata.com/raft/?from=timeline
