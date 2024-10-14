---
title: shell math
date: 2024-09-30
private: true
---
# Caculation cmd
### expr
expr 算式:

	x=`expr $x + 1` ; #$x 与 + 与 1 之间必须有空格, 否则被expr视为字符串

### bc expression
	x=`echo $x^3 | bc`; #bc 较expr限制少, 支持大量的数学符号(而expr 仅支持+-*/%)

### let
let 数学式:

	let x=$x+1;echo $x; # let 没有返回值的

### 双括号(())
1. 支持-+*/%
2. 支持随机数

	echo $((RANDOM%100))
