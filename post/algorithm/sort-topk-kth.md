---
title: 查找数组中的中值
date: 2019-02-14
---
# 查找数组中的中值
This is a question about find k'th number in an array.

    def find_kth(arr, k):
        p = 0
        q = len(arr)
        i = partition_arr(arr, 0) # partion array with arr[0]
        if i+1 == k:
            return arr[k]
        elif i+1<k:
            return find_kth(a[i+1:], k-i-1)
        else:
            return find_kth(a[:i], k)


Time Complex:  
1. lucky: T(n)=T(n/b)+O(n) = O(n)
1. unlucky: T(n)=T(n-1)+O(n) = O(n^2)

Normally case: T(n)<=

    T(max{0,n-1})+O(n)  if 0,n-1 split
    T(max{1,n-2})+O(n)  if 1,n-2 split
    .....
    T(max{n-1,0})+O(n)  if n-1,0 split

assume split case is independent, then 令

    T_k=1   if k,n-k-1 split
    T_k=0   other

Then Time Complex Expected:

$$
E(T(n))  <= \displaystyle\sum_{k=0}^{n-1}{E[t_k] \{E[T(max(k, n-k-1))]+O(n)\} }\\
= \frac{1}{n}\displaystyle\sum_{k=0}^{n-1}{E[T(max(k, n-k-1))]}+O(n)\\
<= \frac{2}{n}\displaystyle\sum_{k=n/2}^{n-1}{E[T(k)]}+O(n)\\
$$

Use Substitution: declare $T(k)<=ck$ for all large n. Then

$$
T(n)<=\frac{2}{n}\displaystyle\sum_{k=n/2}^{n-1}{ck}+O(n)\\
<=\frac{2c}{n}{\frac{3}8n^2}+O(n)\\
=cn-(\frac{1}4cn-O(n))<=cn\\
$$

