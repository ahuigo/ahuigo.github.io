---
title: Copy List with Random Pointer
date: 2019-02-20
---
# Copy List with Random Pointer
复制带随机指针的链表问题：
https://www.kancloud.cn/kancloud/data-structure-and-algorithm-notes/73016


## 解法1: 借助map 表(两次hash遍历)

1.第一次遍历：直接copy + `map(oldNode) = newNode`

    RandomK------
    ^           |
    |           v
    A ->B ->C ->D<--|
    |   |   |   |   |
    A'->B'->C'->D'  |
    |               |
    ----------------

2.第二次遍历：利用map, `newNode.randomK = map[newNode.randomK]`

你也可以合并两次遍历为一次，只不过当`map[newNode.randomK]` 不存在时，需要创建新的空newNode。

## 解法2: 利用oldNode.next 代替 map
解法2 避免了map 开销
1.第一次遍历：直接copy + `old.next = newNode, newNode.next=old.next`

    RandomK------
    ^           |
    |           v
    A ->B ->C ->D<--|
    | / | / | / |   |
    A'  B'  C'  D'  |
    |               |
    ----------------

2.第二次遍历：恢复newlist 的randomK

    A'.randomK = A.randomK.next 

2.第3次遍历：恢复oldlist/newlist 的next

    A' = A.next
    A.next = A'.next
    A'.next = A'.next.next