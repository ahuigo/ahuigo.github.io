---
layout: page
title:	CAP 理论
category: blog
description: 
---
# Preface
在理论计算机科学中，CAP定理（CAP theorem），又被称作布鲁尔定理（Brewer's theorem），它指出对于一个分布式计算系统来说，不可能同时满足以下三点:

- 一致性（Consistency)（等同于所有节点访问同一份最新的数据副本）
- 可用性（Availability）（对数据更新具备高可用性）
- 容忍网络分区（Partition tolerance）（以实际效果而言，分区相当于对通信的时限要求。系统如果不能在时限内达成数据一致性，就意味着发生了分区的情况，必须就当前操作在C和A之间做出选择[3]。）

http://www.infoq.com/cn/articles/cap-twelve-years-later-how-the-rules-have-changed

# Reference
- [cap]

[cap]: http://zh.wikipedia.org/wiki/CAP%E5%AE%9A%E7%90%86
