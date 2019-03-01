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
2. 没有匹配成功n 归0，再重新匹配

如果搜索`ababc`, n就不能直接归0了, 我们需要提前计算

    ababc       n(a,ababc)=0
    0a

    ababc       b!=a n(ab,ababc)=0
    00ababc

    ababc       a==a +1 n(aba,ababc) = 1
    001babc

    ababc       b==b +1 n(abab,ababc) = 2
    0012abc

    ababc       c!==a 0
    00120
        ababc

a!=b 一定是n=0? 不一定哦

    len(S)=7  len(lx)=3
    S....Sx
         7
         S....SX
    SX...Sx     ? x!=X
         7?
         SX...Sx   
    # if S.endwith(Sx) => S=lx...l
    (lx...l)X...(lx...l)x
                      7 3
                      (lx...l)X...(lx...l)x

Str 满足：

    SX...Sx
    (lx...l)X...(lx...l)x

e.g.

    S=abx--ab
    abx--abX.....abx--abx   x!=X 3
                 1234567
                 abx--abX...abx--abx
    abx--abX.....abx--abx   x!=X 3  S[:6], S[:5], S[:4], S[:3]=abx
                 12345673
                      abx--abX...abx--abx
