---
title: Mysql why not use Null
date: 2019-10-03
---
# Mysql Null 的问题
1. Mysql**难以优化引用可空列查询**，它会使索引、索引统计和值更加复杂。
2. 可空列**需要更多的存储空间**，还需要mysql内部进行特殊处理。可空列被索引后，每条记录都需要`一个额外的字节`标识是否为null，
    1. 可以 用explain select ... 查看key_len 大小
3. mysql 的Null 只能使用IS NOT NULL 比较

另外：
1. NULL值可以被有意义的值表示
2. Null 容易混淆
    1. `null >1 , null <=1, null = null`  都不成立(包括postgre)
    1. 应该用is null
