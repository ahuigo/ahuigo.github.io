---
layout: page
title:	傅里叶变换
category: blog
description: 
---
# Preface

今天看到一篇韩昊写的好文 [傅里叶分析之掐死教程](http://zhuanlan.zhihu.com/wille/19763358)，生动形象的讲解了傅里叶的本质： 将时域变换到频域。非常有陈皓的文风，极好的马桶教程。

过去学的东西，都快忘光了，在此做个备录吧。
傅里叶变换(Fourier Transform): 将时间变化映射到频域（复域的虚轴 0+bj）变化。从时间的连续性看，又分为连续傅里叶和离散傅里叶。
拉普拉斯变换(Laplace Transform): 将连续间变化映射到复域（a+bj）变化。它是对连续傅里叶变换的推广（可以分析不稳定不收敛的信号）。 
Z 变换(Z Transform): 将离散的时间变化映射到整个复域变化。它是对离散傅里叶变换的推广（可以分析不收敛的离散信号）。 

从基的观点上看，
Fourier Transform 是将正弦函数作为基;
Laplace Transform 是将幅度指数变化的正弦函数作为基;
Z Transform 是将周期变化的离散序列作为基。
