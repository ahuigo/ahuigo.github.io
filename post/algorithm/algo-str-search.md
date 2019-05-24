---
title: 字符串搜索算法KMP
date: 2019-02-28
---
# 字符串搜索算法KMP
容易想到的搜索算法是O(N*M)
KMP 则是O(N) 复杂度

搜索`ahuigo` 时，当匹配到`,`, 我们可以跳过`ahui`

    ahui, let's go! ahuigo  n=4, ","!="ahuigo"[4]
    ahui__

    ahui, let's go! ahuigo  n=0, ","!="ahuigo"[0]
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

如果搜索`ababc`, 当遇到不匹配的`c`, n就不能直接归0了

    abababc         n=5, "a"!="ababc"[4]
    abab_

    abababc         n=2, "a"=="ababc"[2]
      aba__
        |

搜索`ababc`时, 如果我们需要遇到不匹配的字符，n 应该设置的值可以提前计算

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
         S....SX+suffix
    SX...Sx     ? x!=X
         7?
         SX...Sx + suffix
    # if S.endwith(Sx) => S=lx...l
    (lx...l)X...(lx...l)x
                      7 3
                      (lx...l)X...(lx...l)x + suffix

Str 满足：

    SX...Sx
    (lx...l)X...(lx...l)x+suffix

e.g.

    S=abx--ab
    abx--abX.....abx--abx   x!=X 3
                 1234567
                 abx--abX...abx--abx
    abx--abX.....abx--abx   x!=X 3  S[:6], S[:5], S[:4], S[:3]=abx
                 12345673
                      abx--abX...abx--abx


code:

    def gen_match_table(needle):
        m=[0]
        n=0
        for i, c in enumerate(needle):
            if i==0:
                continue
            if c==needle[n]:
                n+=1
                m.append(n)

            # abx--abX.....abx--abx   x!=X 3  S[:6], S[:5], S[:4], S[:3]=abx
            #              12345673
            #              abx--abX...abx--abx
            else:
                lastn = n
                partial_needle = needle[:i+1]
                n = 0
                for j in range(lastn, 0, -1):
                    # S[:6] S[5]
                    if needle[0:j] == partial_needle[-j:]:
                        n = j
                        break
                m.append(n)
        return m

    print(gen_match_table('abx--abX.....abx--abx'))