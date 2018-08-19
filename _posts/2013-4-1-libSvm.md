---
layout: page
title:	LibSvm	
category: blog
description: 
---

# SVM

支持向量机（Support vector machine）是在统计学习理论的基础上发展起来的新一代学习算法，它在文本分类、手写识别、图像分类、生物信息学等领域中获行较好的应用。  
如果你还没有忘记大学微积分/线代/概统...，可以试着点击以下链接：

* [支持向量机SVM（一）]
* [SVM入门（一）至（三)]
* [支持向量机通俗导论] by july&pluskid

# Libsvm

如果你只是想知道如何使用Libsvm,或者不想花时间学习一门新课程，那么Libsvm可以满足你——它是svm算法的实现工具，并且为各种语言(php/python/...)和工程软件（matlab/octave）,都提供了扩展支持。下面是相关链接：

* [libSVM 简易入门]
* [libsvm]主页
* [libsvm tools]详细介绍

谷歌了一下libsvm for php，发现一款php-svm 的php扩展（其实[libsvm]主页就提到了）。由google+ 的ianbarber提供包维护。
不过这个包并不支持64位的，其中的README 有介绍如何手动下载和编译、安装（wget\make\make install）:

* [php-svm]

[支持向量机SVM（一）]: http://www.cnblogs.com/jerrylead/archive/2011/03/13/1982639.html
[libSVM 简易入门]: http://blog.csdn.net/wuwuwuwuwuwuwuwu/article/details/8120885
[libsvm]: http://www.csie.ntu.edu.tw/~cjlin/libsvm/
[php-svm]: https://github.com/ianbarber/php-svm/
[libsvm tools]: http://www.csie.ntu.edu.tw/~cjlin/libsvmtools/

[SVM入门（一）至（三)]: http://www.blogjava.net/zhenandaci/archive/2009/02/13/254519.html
[支持向量机通俗导论]: http://blog.csdn.net/v_july_v/article/details/7624837
