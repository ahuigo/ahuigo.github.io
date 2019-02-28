---
title: 字符串搜索算法KMP
date: 2019-02-28
---
# 字符串搜索算法KMP
容易想到的搜索算法是O(N*M)
KMP 则是O(N) 复杂度

搜索`ahuigo` 时，当匹配到`,`, 我们可以跳过`ahui`

    ahui, let's go! ahuigo
    ahui__

    ahui, let's go! ahuigo
        ahui__

search `ahuigo` 的伪代码如下 


    n = 0
    for c in string:
        if c=='ahuigo'[n]:
            n+=1
        else:
            n=1 if c=='ahuigo'[0] else 0
        if n == len('ahuigo'):
            return True

我们看到：
1. n 很关键，代表已经匹配的字符数
2. 没有匹配成功n 归0，再重新匹配一次

如果搜索`ababc`, n就不能直接归0了, 我们需要提前计算n：

    ababc   
    0a

    ababc       b!=a ->0
    00ababc

    ababc       a==a +1
    001babc

    ababc       b==b +1
    0012abc

    ababc       c!==a 0
    00120ababc

a!=b 一定是0? 不一定哦


    s....   s
            s....s
    s....   s+x
             s2+x....s
             s=s2+x +....+ s2

    abx12ab.....abx12ab
                abx12ab....abx12ab
                1234567....abx12ab

    abx12ab.....abx12abx
                     abx12ab....abx12ab
                       312ab....abx12ab