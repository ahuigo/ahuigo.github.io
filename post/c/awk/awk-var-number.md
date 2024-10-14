---
title: awk number
date: 2024-09-30
private: true
---
# 四则、幂
支持+、-、*、/、%、++、–、+=、-=等诸多操作；

	gawk 'BEGIN{i=9;j=1; i+=j;print i}'
	gawk 'BEGIN{i=9;j=1; i+=j;print i>j}'

支持==、!=、>、=>、~（匹配于）等诸多判断操作；

## 幂
Exponentiation; x raised to the y power. ‘2 ^ 3’ has the value eight; the character sequence ‘**’ is equivalent to ‘^’. (c.e.)
	awk 'BEGIN{print (1.5^2)}'

	x ^ y
	x ** y

sqrt

	print sqrt(4)

## 四则


	- x
	Negation.

	+ x
	Unary plus; the expression is converted to a number.

	x * y
	x / y
	int(x/y); floor

Division; because all numbers in awk are floating-point numbers, the result is not rounded to an integer—‘3 / 4’ has the value 0.75. (It is a common mistake, especially for C programmers, to forget that all numbers in awk are floating point, and that division of integer-looking constants produces a real number, not an integer.)

	x % y

Remainder; further discussion is provided in the text, just after this list.

	x + y

Addition.

	x - y

Subtraction.



# 函数
## triangle

	print sin(1)

## rand
	print int(rand()*100);
## float
默认显示float 时，awk 会对float 4舍5入：

	awk 'BEGIN{printf("%f\n", 111199989/100)'

## ceil floor

    int(1.5)
    ceil(3/8)
    function ceiling(x) {
        return (x == int(x)) ? x : int(x)+1
    }

you could also write a `round(2.5)` function.