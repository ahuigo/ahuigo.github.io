---
layout: page
title: Google Heap Profiler
category: blog
description: 
---
# Preface
本文参考: http://blog.csdn.net/jhzhou/article/details/7245992

Google Heap Profiler，大致有三类功能：

1. 可以分析出在程序的堆内有些什么东西
2. 定位出内存泄露
3. 可以让我们知道哪些地方分配了比较多的内存

大概的原理就是使用tcmalloc 来代替malloc calloc new等等，这样Google Heap Profiler就能知道内存的分配情况，从而分析出内存问题。

# Create dump
首先需要把tcmalloc链接到我们需要分析的程序中， 当然我们也可以动态load 这个lib，但是为了简单起见，还是推荐大家链接这个lib到自己的程序中。

链接之后，我们接下来的任务就是得到内存分析的dump文件，我们有两种方法：

## 静态dump方法：
直接定义一个环境变量HEAPPROFILE 来指定dump profile文件的位置，如：/tmp/test.log,它将会在/tmp/目录下生成很多类似/tmp/test.log.0003.heap文件名的文件

	env HEAPPROFILE="/tmp/test.log" /test/testprog

# 动态dump方法：
我们可以调用Google Heap Profiler的API来控制什么时候dump出内存的profiler文件，这样更加灵活，为此，我们必须包含heap-profiler.h这个头文件。

	HeapProfilerStart() 用来开始内存分析
	HeapProfilerStop().  用来终止内存分析

这样就只会在开始和结束之间产生dump profiler文件。

选项

	 HEAP_PROFILE_ALLOCATION_INTERVAL

程序内存每增长这一数值之后就dump 一次内存，默认是1G （1073741824）

	 HEAP_PROFILE_INUSE_INTERVAL

程序如果一次性分配内存超过这个数值dump 好像默认是100K

# Analyse Dump

## View Dump
查看dump 文件

	pprof --pdf /test/testProg /tmp/test.log.0001.heap

就是以pdf的形式来显示这个dump文件，当然我们也可以使用其他的格式来显示。

	--text              Generate text report
	--callgrind         Generate callgrind format to stdout
	--gv                Generate Postscript and display
	--evince            Generate PDF and display
	--web               Generate SVG and display
	--list=<regexp>     Generate source listing of matching routines
	--disasm=<regexp>   Generate disassembly of matching routines
	--symbols           Print demangled symbol names found at given addresses
	--dot               Generate DOT file to stdout
	--ps                Generate Postcript to stdout
	--pdf               Generate PDF to stdout
	--svg               Generate SVG to stdout
	--gif               Generate GIF to stdout
	--raw               Generate symbolized pprof data (useful with remote fetch)

这就是所有可支持的格式。

> pprof 依赖`dot`,要安装 `yum install graphviz -y`

我们也可以专门focus在一些包含某些关键字的路径上，也可以忽略相关的路径

	--focus
	--ignore
	pprof --pdf --focus=CData /test/testProg /tmp/test.log.0001.heap

## Compare Dump
为了知道在某一段时间内的内存分布情况，或者需要了解某段时间内有没有内存泄露，我们就需要用到diff我们的dump文件

	pprof --pdf --base /tmp/test.log.0001.heap /test/testProg /tmp/test.log.0101.heap

比较了第1个dump文件与第101个文件的差异，结果以pdf的形式显示
