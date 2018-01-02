---
layout: page
title:
category: blog
description:
---
# Preface

# priority
`!` 优先级更高(php)

    php > var_dump(!1===0);
    bool(false)
    php > var_dump(!(1===0));
    bool(true)


## left logic order

	{1 or 2} and 3 # 3? 左序为先
	1 or {2 and 3} # 1? 右序为先
	true || false && echo yes; # true || 只会截断 最近的表达式
	0 and 1 or 2

shell 逻辑测试符是从左开始以最短的语句为子语句。python/js 都是如此

	hash git || echo 'Err: git is not installed.' && exit 3
	# 等价于
	{ hash git || echo 'Err: git is not installed.' } && exit 3

应该写成：

	hash git || { echo 'Err: git is not installed.' ; exit 3; }
	if && do1 || do2

shell 没有三元运算符：不过可以这样

	{ cmd && r=true } || r=false
	if $r; then
		echo true
	fi

