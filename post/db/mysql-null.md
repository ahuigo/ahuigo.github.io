---
title: Mysql why not use Null
date: 2019-10-03
---
# Mysql Null 的问题
1. Mysql**难以优化引用可空列查询**，它会使索引、索引统计和值更加复杂。
2. 可空列**需要更多的存储空间**，还需要mysql内部进行特殊处理。可空列被索引后，每条记录都需要一个额外的字节，还能导致MYisam 中固定大小的索引变成可变大小的索引。
3. mysql 的Null 只能使用IS NOT NULL 比较

别外：
1. NULL值可以被有意义的值表示
2. Null 容易与容易混淆