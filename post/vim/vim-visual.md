---
title: Vim visual
date: 2019-05-29
---
# Vim visual
可视选择模式一共有 3种 状态:

	v 普通visual
	V 行选visual
	ctrl+v 矩形块选 #对于矩形选而言，o是垂直切向，O是水平切向

	gv #回到上次的选择的visual

## Visual+Motion

	V<line_number>G
	V<line_number>j
	v/<pattern>/e
	vas
	vap
	V2aB

## 高级用法

	ctrl+v 块选后，对单行的操作会反映到所有行，比如IA行操作
	#选中了文本后，可以改变大小写
	~ 大小写转换
	U  转大写
	u 转小写
	#选中了文本后，以一个字符填充
	rx #这样就把所有字符变成了x了

## 光标切换
处于visual时，还可以控制选择范围的方向

	o 到另一端
	O 左右切换
