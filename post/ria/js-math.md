---
title: JS Math
date: 2018-10-04
---
# Math

	E	返回算术常量 e，即自然对数的底数（约等于2.718）。
	LN2	返回 2 的自然对数（约等于0.693）。
	LN10	返回 10 的自然对数（约等于2.302）。
	LOG2E	返回以 2 为底的 e 的对数（约等于 1.414）。
	LOG10E	返回以 10 为底的 e 的对数（约等于0.434）。
	PI	返回圆周率（约等于3.14159）。
	SQRT1_2	返回返回 2 的平方根的倒数（约等于 0.707）。
	SQRT2	返回 2 的平方根（约等于 1.414）。

## isNaN

    > Number.isNaN(undefined)
    false
    # The global isNaN() function, converts the tested value to a Number, then tests it.
    > isNaN(undefined)
    true

## mod
    5%10 === 5
    -1%10 === -1
    -11%10 === -1

## math.pow

    2**10
    Math.pow(2,10)

## factorial + combinations
    function factorial(n, r = 1) {
        while (n > 1) r *= n--;
        return r;
    }
    function combinations(n,r){
        let s = 1;
        let i = r;
        while(i<n) s*=++i;
        return s/factorial(n-r)
    }

## round/floor/ceil+(toFixed)
py+php+mysql: round(3.55,2)

    //四舍五入
	num.toFixed(2); //两位小数, 
	(3.555).toFixed(2);// 3.56
    +(1/3).toFixed(2)

    //四舍五入
	Math.round(1.5); //2
	Math.round('1.5'); //2
	Math.round(1.4); //1

	Math.floor(1.5); //1
	Math.floor(Math.random()*20);
	Math.ceil(1.5);	//2


	num.toExponential([小数位数]);// 科学计数法
	num.toPrecision([有效位数]); //据最有意义的形式来返回数字的预定形式或指数形式

### 取整数floor

    ~~3.16 
    2.6 | 0
    2.6 >> 0

parseInt

    +'123.6' 123.6

## random
随机字符

    Math.random().toString(36).substring(2) // 11位

用正则魔法实现：

    var test1 = '1234567890'
    var format = test1.replace(/\B(?=(\d{3})+(?!\d))/g, ',')
    console.log(format) // 1,234,567,890

非正则的优雅实现：

    function formatCash(str) {
        return str.split('').reverse().reduce((prev, next, index) => {
                return ((index % 3) ? next : (next + ',')) + prev
        })
    }
    console.log(formatCash('1234567890')) // 1,234,567,890

## to Number
数值范围:Number.MIN_VALUE~Number.MAX_VALUE (一般是5e-324~1.79769e+308)

    '123.3'*1
    +'-123.3'
    ''+21234
    +new Date


    Number('1.2e5')
	Number(undefined);//NaN
	Number(null);//0

	parseInt('0x10', [进制]) //number or NaN
    parseInt('11234'); 不要用于map
    parseInt('111',2);//7
	parseFloat(var) //number or NaN


	(10).toString(16);//'a'