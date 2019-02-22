---
title: 单链表判圈之Floyd算法
date: 2018-09-26
---
# 单链表是否有环之龟兔算法(tortoise-hare)
Floyd判圈算法(Floyd Cycle Detection Algorithm), 也叫龟兔算法(tortoise-hare)
![cycle](/img/cycle-detection.png)

检测单链表上的环分为三个问题：
1. 单链表上是否有环
2. 环的长度是多少
3. 环的起点在哪里？

通常我们所想到的方法是，遍历 并通过hash 表判断是否能回到起点. 这种算法的空间消耗比较大。还有一种龟兔算法(tortoise-hare), 能在不消耗空间的情况下解决这一问题。

# 基本思想

## 是否有环，及环的长度
如果链表存在环，那么 龟 和 兔 从链表起点出发，每次龟走一步，走两步(step=2)，那么Tortoise 到达环的起点时，经过m步。龟比兔多跑：`S_tortorise - S_hare = -m`, 

假设环长度`s`, 兔子要追上龟这`-m`，龟就要再跑`s-m`步，准确的说是`k=-m mod s` 步

    s-m     //if s-m >=0
    2s-m    //elif 2s-m >=0
    3s-m    //elif 3s-m >=0
    .....

龟跑 $ns-m$ 次后，龟兔必定相遇。此时，

- 龟走了: $S_{tortoise} = m+(ns-m) = ns$
- 兔走了: $S_{hare} = 2S_{tortoise}$

如果他们能相遇，我们就能确定链表有环, 且长度`s=m+k`

## 环的起点+环的长度
还剩下一个问题是：环的起点在哪里？再分析一下当龟兔相遇时(`ns-m`)，大家再走m 步就到起点了，可是m 是未知的呢。其实不用理会m
1. 让龟回到起点，兔留在原地
2. 然后大家同时走，每次都走一步(step=1)。大家一定能在`环的起点`相遇。得到走过的步数就是`m`
3. 此时乌龟继续走到上次龟兔相遇的点，会再走k步(`k=ns-m`). 

# 步长与相遇的关系
两人的步长相差Delta 同时从同一点出发绕圈s跑，相遇胡条件是：

    ns mod Delta == 0

两人的步长相差Delta, 相距s1, 同时绕圈s跑，相遇的条件是：

    (ns+s1) mod Delta == 0

对于tortoise-hare 之间的Delta=1, 满足条件。
