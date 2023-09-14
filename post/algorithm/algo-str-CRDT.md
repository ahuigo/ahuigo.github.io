---
title: CRDT 算法
date: 2023-09-11
private: true
---
# CRDT 算法
协同编辑算法有两种：
2. OT： 这是中心化的算法
    1. 它要求op操作满足交换率 `transform(client_op, server_op)` 与 `transform(server_op, client_op)`结果是一致的
    2. 当用户op操作比较多的话，transform会非常慢, 因为每个op操作都要与其它操作进行转换
1. CRDT（Conflict-free Replicated Data Type, 无冲突复制类型): 这是分布式的算法, 是2006年被提出的conflict free 算法
    2. CRDT有两种主要类型：状态同步CRDT（State-based CRDT）和操作同步CRDT（Operation-based CRDT）
