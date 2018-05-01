# Math

	E	返回算术常量 e，即自然对数的底数（约等于2.718）。
	LN2	返回 2 的自然对数（约等于0.693）。
	LN10	返回 10 的自然对数（约等于2.302）。
	LOG2E	返回以 2 为底的 e 的对数（约等于 1.414）。
	LOG10E	返回以 10 为底的 e 的对数（约等于0.434）。
	PI	返回圆周率（约等于3.14159）。
	SQRT1_2	返回返回 2 的平方根的倒数（约等于 0.707）。
	SQRT2	返回 2 的平方根（约等于 1.414）。

	(1.5).fixed(2); //1.50
	Math.round(1.5); //2
	Math.round('1.5'); //2
	Math.round(1.4); //1
	Math.floor(1.5); //1
	Math.ceil(1.5);	//2
	Math.floor(Math.random());


## to Number
数值范围:Number.MIN_VALUE~Number.MAX_VALUE (一般是5e-324~1.79769e+308)

    '123.3'*1
    +'-123.3'


    Number('1.2e5')
	Number(undefined);//NaN
	Number(null);//0

	parseInt('0x10', [进制]) //number or NaN
    parseInt('11234'); 不要用于map
    parseInt('111',2);//7
	parseFloat(var) //number or NaN


	(10).toString(16);//'a'

### round(toFixed)
py+php+mysql: round(3.55,2)

	num.toFixed(2); //两位小数, 四舍五入
	(3.555).toFixed(2);// 3.56

	num.toExponential([小数位数]);// 科学计数法
	num.toPrecision([有效位数]); //据最有意义的形式来返回数字的预定形式或指数形式