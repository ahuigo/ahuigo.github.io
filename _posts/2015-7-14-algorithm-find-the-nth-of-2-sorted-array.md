---
layout: page
title:	查找两有序数组中第N 大的值
category: blog
description: 
---
# Preface

# 问题
A B 两个递增有序数组, 将两数组中的元素合并到一起。请找到其中第N，N+1 大的数

> Find the n'th max number of 2 sorted array!

			p1
	A ------+----------

			p2
	B ------+----------

# 算法
使用二分法, 设A 长度是An, B 长度是Bn。

1. 先初始化:
	p1 指向A 数组的n/2, p2 指向B 数组的n/2;
	Al=0, Ar=An-1; Bl=0, Br=Bn-1;

2. 然后不断按以下规则判断并做二分切割, 直到找到第N大的值

判断规则如下：

	当p1 < p2
		当p2 <= p1r && p2l <= p1 (两点相邻, 当没有p1r，p2l也判断相邻)
			p1 + p2 = N, 则p1，p2 分别是第N,N+1 大的元素
			p1 + p2 < N,
				Al=p1, p1=(Al+Ar+1)/2
					p1 == Al(不能右移了)
						则第N、N+1 大的数字出现B 数组上的（N-An-1), (N-An)
					p1 <> Al
						再继续比较
			p1 + p2 > N,
				Br=p2, p2=(Bl+Br)/2
					p2 == Br(不能左移了)
						则第N、N+1 大的数字出现A 数组上的（N-1), N
					p2 <> Br
						再继续比较
		当p2, p1(不相邻)
			p1 + p2 = N
				Al=p1, p1=(Al+Ar+1)/2
					p1 == Al(不能右移了)
						则第N、N+1 大的数字出现B 数组上的（N-An-1), (N-An)
				p1 <> Al
					继续
			p1 + p2 < N
				Al=p1, p1=(Al+Ar+1)/2
					p1 == Al(不能右移了)
						则第N、N+1 大的数字出现B 数组上的（N-An-1), (N-An)
				p1 <> Al
					继续
			p1 + p2 > N
				Br=p2, p2=(Bl+Br)/2
					p2 == Br(不能左移了)
						则第N、N+1 大的数字出现A 数组上的（N-1), N
				p2 <> Br
					继续
	当p1 = p2 与p1<p2 一样
	当p1 > p2 与p1<p2 相反的过程

# 随机打乱一个数组

	len = length(arr)
	for i=0; i< len-1; i++ 
		p = rand(0, len-i-1)	
		swap_pos(p, len-i-1)
