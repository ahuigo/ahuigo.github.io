
# Func list
这里罗列的是顶层函数（全局函数）

### 转码:
常规字符: 字母 数字 下划线

	encodeURI()	把字符串编码为 URI。
		encodeURI("http://www.google.com/a file with spaces.html"); //转码所有非常规URI字符转码: '|" Ò' 等等
	encodeURIComponent()	把字符串编码为 URI 组件(utf8)。(所有URI特殊字符 将被转码)
		encodeURIComponent('中国 ')
			%E4%B8%AD%E5%9B%BD%20
        decodeURIComponent
	escape()	对字符串进行编码(unicode)。Don't use it, as it has been deprecated since ECMAScript v3.
        escape('中国 ');
            "%u4E2D%u56FD%20"
        unescape('%20');
	str.replace(/'/g, "\\'");//addslashes

	eval()	计算 JavaScript 字符串，并把它作为脚本代码来执行。

## Number

	数值范围:Number.MIN_VALUE~Number.MAX_VALUE (一般是5e-324~1.79769e+308)
	parseInt('0x10', [进制]) //number or NaN
	parseFloat(var) //number or NaN
	Number(undefined);//NaN
	Number(null);//0
	(10).toString(16);//'a'
	num.toExponential([小数位数]);// 科学计数法
	num.toPrecision([有效位数]); //据最有意义的形式来返回数字的预定形式或指数形式

### Number

	num.toFixed(2); //两位小数, 四舍五入
	(3.555).toFixed(2);// 3.56

	php+mysql: round(3.55,2)

## hex2str & str2hex

	function str2hex(str) {
		var hex = '';
		for(var i=0;i<str.length;i++) {
			hex += ('0'+str.charCodeAt(i).toString(16)).substr(-2);
		}
		return hex;
	}
	function hex2str(hex) {
		var str = '';
		for (var i = 0; i < hex.length; i += 2)
			str += String.fromCharCode(parseInt(hex.substr(i, 2), 16));
		return str;
	}

## Math

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