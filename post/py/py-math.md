---
layout: page
title:
category: blog
description:
---
# Preface

# number

    0x61
    0o77
    0b11

## operator

    2**5	math.pow(2,5)
    5//2	floor(5,2)

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
	>>> "12.34".replace('.','',1).isdigit()
	True
	>>> "12.3.4".replace('.','',1).isdigit()
	False

Also for negative numbers just add lstrip():

	>>> '-12'.lstrip('-')
	'12'

## random

	import random
	random.randint(1, 20)
		20
	random.random() 0~1
		0.1234

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


## random

	import random
	random.randint(3,8)

## math operator

	print x**2; # x^2

## floor

    import math
    math.ceil(x)
    math.floor(x)
    round(x, 2)
