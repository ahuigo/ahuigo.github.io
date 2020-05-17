---
title: ruby iter
date: 2020-05-17
private: true
---
# Ruby 迭代器(iterator)
Ruby 有两种迭代器，each 和 collect。
## Ruby each 迭代器
each 迭代器返回数组或哈希的所有元素。

    ary = [1,2,3,4,5]
    ary.each do |i|
        puts i
    end

    hash = {k:1}
    hash.each{|k, v| p k,v}
    hash.each{|pair| p pair[0],pair[1]}

## Ruby collect/map 迭代器

    a = [1,2,3,4,5]
    b = a.collect{ |x|x }
