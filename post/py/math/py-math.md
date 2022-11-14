---
title: Python 的math 语法
priority:
---
# number

    0x61
    0o77
    0b11

## random
`[0,1)` 小数

	import random
	random.random() 0~1
		0.1234

包含`[3,8]` 的整数

	random.randint(3,8)
        8

包含`[3,8)` 的整数

	random.randrange(3,8)
		7
	random.randrange(8) 0-7
		7

密码强随机

	os.urandom(24)
	b'\xfd{H\xe5<\x95\xf9\xe3\x96.5\xd1\x01O<!\xd5\xa2\xa0\x9fR"\xa1\xa8'
    # head -c 24 /dev/urandom

    import os,base64
    base64.b64encode(os.urandom(24)).decode()

## nan
    >>> import math
    >>> x = float('nan')
    >>> math.isnan(x)
    True

## floor/ceil/round

    import math
    math.ceil(x)
        负数： -(-5//2) == math.ceil(5/2)
    math.floor(x) == x//1
        正数：math.floor(5/2) == 5//2	
    round(x, 2) # 小数点后两位, 四舍五入
		'%.2f'%x
	'%.3e' % 53.3432 # 有效位数，四舍五入

## operator

    2**5	math.pow(2,5)

## number type

	int('1')
	float('1')
	round(1.7333,2)
	range(1,10 [,step])

## isNumber
For int use this:

	>>> "1221323".isdigit()
	True

But for float we need some tricks ;-). Every float number has one point...

	>>> "12.34".isdigit()
	False

Also for negative numbers just add lstrip():

	>>> '-12'.lstrip('-')
	'12'

## range

### range int

	list(range([start=0,] end, [step]))
    list(range(0, 19, 2))
    0 2 4...

## min,max

    max([3,9,2])

# arithmetic

## math
https://docs.python.org/3.2/library/math.html

    import math
    math.pow(x,y)
        x**y
    math.exp(y)
        e**y
    math.log(x[, base])¶
        default base is e
        calculated as log(x)/log(base).
    math.log10(x)¶
    math.sqrt(x)¶

## math operator

	print x**2; # x^2
    math.factorial(5) == 120
