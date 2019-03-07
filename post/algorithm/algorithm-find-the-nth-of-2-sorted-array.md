---
title: 查找两有序数组中第N 大的值
date: 2016-09-26
update: 2019-03-06
---
# 查找两有序数组中第N 大的值
问题:
> A B 两个递增有序数组, 将两数组中的元素合并到一起。请找到其中第N大的数

Find the n'th max number of 2 sorted array!

# 二分法思路
a,b数组，令i1,j1=0 指第一个值, i,j是可能为第N大的值: i+j+2=N

	  i1		i          i2
	a ----------+-----------
	  j1    j     j2
	b ------+------

a. 如果是求N(N>=2)大的数可以这么做：只需要保证i+j+2=N 就可以

    i=min(i2,N-2)
    j=N-2-i

如果求中间数，那么:

    i = floor[(i1+i2)/2]
    j = floor[(j1+j2)/2]

b. 只讨论a[i]<=a[j] 的情况

	  i1		i          i2
	a ----------+===========
	  j1    j     j2
	b ======+------

b.1. 截断：太长的部分不可能成为第N大的数，就去掉

    delta>0:
	  i1		i     i2
	a ----------35=====
	  j1    j     j2
	b ======4------

    delta = min(i2-i, j-j1)
    if delta>0:
        i2=i+delta
        j1=j-delta

b.2. 临界判断 与非临界判断

    if delta==0:
        # delta = 0:
        # a:1     2
        # b:3
        if i<i2 and b[j]>a[i+1]:
            return a[i+1]
        else:
            return b[i]
    elif a[i]<=b[j]<=a[i+1]:
        return b[j]
    else:
        pass

b.3. 判断的失败，就重新二分分割：

	            i1    i2
	a           +======
	  j1    j2
	b ======+
    i=i1
    i=i1+ceil(delta/2)
    j=j2
    j=j2-ceil(delta/2)

b.4. 重新的回到b.

# 算法实现
略