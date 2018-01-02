---
layout: page
title:
category: blog
description:
---
# Preface
基本类型：Undefined、Null、Boolean、Number和String
复杂类型：由基本类型构成

# "use strict";
> ES6 modules are always in strict mode

use strict参考：阮一峰 http://www.ruanyifeng.com/blog/2013/01/javascript_strict_mode.html

必须写在执行语句或者函数体内的第一行

1. 变量必须有var 声明
2. 不允许用with
3. 正常模式下eval 内的变量作用域取决于所在的作用域。strict 模式下，eval 本身是一个作用域
4. function 下的this 是undefined, 而new 生成的obj 内的this 指向自己

## 禁止删除变量
严格模式下无法删除变量。只有configurable设置为true的对象属性，才能被删除。

	"use strict";
　　var x;
　　delete x; // 语法错误
　　var o = Object.create(null, {'x': {
　　　　　　value: 1,
　　　　　　configurable: true
　　}});
　　delete o.x; // 删除成功

## 显式报错

### 对只读变量写入
正常模式下，对一个对象的只读属性进行赋值，不会报错，只会默默地失败。严格模式下，将报错。

	"use strict";
　　var o = {};
　　Object.defineProperty(o, "v", { value: 1, writable: false });
　　o.v = 2; // 报错

### 重名报错

	"use strict";
　　var o = {
　　　　p: 1,
　　　　p: 2
　　}; // 语法错误

# 变量类型
## Number: 1.2345e3; -99; NaN; Infinity; 

## js-str

## Boolean
null == undefined 可相等.
false == 0

但它们与false/0 都不能相等
	null==0 //return false
	undefined==0 //return false
	undefined==false //return false

## Undefined && Null
没有值和空值

	typeof null; "object"
	typeof undefined; "undefined"


# Compare
https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Equality_comparisons_and_sameness

JavaScript 提供三种不同的比较操作符：

    严格相等，使用 ===
    （非严格）相等，使用 ==, （尽量别用，太乱了)
        类型转换
    Object.is （ECMAScript 6 新特性）
        在三等号判等的基础上特别处理了 NaN 、 -0 和 +0 ，保证 -0 和 +0 不再相同，但 Object.is(NaN, NaN) 会返回 true

## ===
非基本类型是不等的, 尽量用类型相等

    new Object() === new Object()
        false
    new Number(1) === new Number(1)
    new Number(1) == new Number(1)
        false

## 非严格相等 ==EDIT
没有什么意义，建议用严格相等！
相等操作符对于不同类型的值，进行的比较如下图所示：

            B
 	 	    Undef	Null	Number	            String	                    Boolean	                        Object
    Undef	true	true	false	            false	                    false	                        IsFalsy(B)
    Null	true	true	false	            false	                    false	                        IsFalsy(B)
    Number	false	false	A === B	            A === ToNumber(B)	        A=== ToNumber(B)	            A=== ToPrimitive(B)
    Boolean	false	false	ToNumber(A) === B	ToNumber(A) === ToNumber(B)	A === B	                        false
    String	false	false	ToNumber(A) === B	A === B	                    ToNumber(A) === ToNumber(B)	    ToPrimitive(B) == A
    Object	false	false	ToPrimitive(A) == B	ToPrimitive(A) == B	        ToPrimitive(A) == ToNumber(B)	A === B

to number:

	[]==[];//false 因为它们指向不同的对象. 这跟php是不一样的.
	[]==0; //true Number({})的值为NaN，而Number([])的值为0 Number(null)为0 Number(undefined) = NaN
	{}==0; //false

to Boolean:

	null==undefined; //true
	0==''==false;//true
    {}==false
    [] == false; //true

	![];!{}//false, 对象取反都为false *******
    {}!=false
	!null;!undefined;!'';!0; //true


在上面的表格中，

1. ToNumber(A) 尝试在比较前将参数 A 转换为数字，这与 +A（单目运算符+）的效果相同。通过尝试依次调用 A 的A.toString 和 A.valueOf 方法，将参数 A 转换为原始值。

2. 根据 ECMAScript 规范，所有的对象都与 undefined 和 null 不相等。
但是大部分浏览器允许非常窄的一类对象（即，所有页面中的 `document.all` 对象），在某些情况下，充当效仿 undefined 的角色。
因此，IsFalsy(Object) 值为 true ，当且仅当 Object 效仿 `undefined`。在其他所有情况下，`Object != undefined/null`。

`==`类型不同时的转换规则：

    如果一个值是null，另一个值是undefined，则相等
    如果一个值是数字，则把另一个值转换成数字，进行比较
    如果一个值是true，则把true转换成1再进行比较；如果任意值是false，则把false转换成0再进行比较
    如果一个是对象，则转成基础类型再比较(valueOf先于toString)
    剩下的都是字符串了

关于比较运算符<、|、>、|、<、=、|、>、=, >=, <=

    如果一个值是null, 除了null >= null, 都为false
    如果一个值是undefined, 除了undefined>= undefined 都为false
    如果一个值是数字/boolean, 都转成数字
    如果一个是对象，则转成基础类型再比较(valueOf先于toString)

## is
Object.is 与== 只有两个不同

    NaN is NaN  // true
    +0  is -0   // false

    NaN == NaN  // false
    +0  == -0   // true


# type check

## typeof
用于判断数据类型及function, object

    undefined、boolean、number,  string
    object
    function

array/null 被视为对象, 所以:

    Object.prototype.toString.call( someVar ) === '[object Array]'
    return Array.isArray(v);
    v instanceof Array
    null === null

未声明的变量，只能执行typeof 操作

    typeof var;//undefined

null 是空对象，undefind 派生自null:

    typeof null;//object 空对象

string

    if (typeof myVar === 'string' || myVar instanceof String)

## via Object.prototype.toString
用于判断对像类别更统一

	Object.prototype.toString.call(1)
	"[object Number]"
	"[object Arguments]"

    var args = [];
    Array.prototype.push.apply( args, arguments );
    [].shift.call(arguments)

to string:

	String(value)
	value + ""
	undefined + ""
	'0'+1
		'01'

# type convert
在JavaScript中,一共有两种类型的值:原始值(primitives)和对象值(objects).

1. 原始值有:undefined, null, 布尔值(booleans), 数字(numbers),还有字符串(strings).
2. 其他的所有值都是对象类型的值,包括数组(arrays)和函数(functions).

强制类型转换:

	Boolean(value) - 把给定的值转换成 Boolean 型；
	Number(value) - 把给定的值转换成数字（可以是整数或浮点数）；
	String(value) - 把给定的值转换成字符串；

类型转换
http://www.cnblogs.com/ziyunfei/archive/2012/09/15/2685885.html

加法运算符会触发三种类型转换:
    将值转换为原始值,转换为数字,转换为字符串,这刚好对应了JavaScript引擎内部的三种抽象操作:ToPrimitive(),ToNumber(),ToString()

## ToPrimitive()
通过ToPrimitive()将值转换为原始值

JavaScript引擎内部的抽象操作ToPrimitive()有着这样的签名:

    ToPrimitive(input, PreferredType?)

可选参数PreferredType可以是Number或者String,它只代表了一个转换的偏好,转换结果不一定必须是这个参数所指的类型,但转换结果一定是一个原始值.如果PreferredType被标志为Number,则会进行下面的操作来转换输入的值 (§9.1):

    1. 如果输入的值已经是个原始值,则直接返回它.
    2. 否则,如果输入的值是一个对象.则调用该对象的valueOf()方法.如果valueOf()方法的返回值是一个原始值,则返回这个原始值.
    3. 否则,调用这个对象的toString()方法.如果toString()方法的返回值是一个原始值,则返回这个原始值.
    4. 否则,抛出TypeError异常.

如果PreferredType被标志为String,则转换操作的第二步和第三步的顺序会调换.
如果没有PreferredType这个参数,则PreferredType的值会按照这样的规则来自动设置:Date类型的对象会被设置为String,其它类型的值会被设置为Number.

## to Boolean
- What are "truthy" and "falsy" values?
if(value)/Boolean(value) 中被转换成true/false 的value

it's easier to identify all of the falsy values. These are:

    false // obviously
    0     // The only falsy number
    ""    // the empty string
    null
    undefined
    NaN

truthy values:

    [] {}
    [new] Boolean(false)
    new Boolean()
    new Object()

special, 有些object 与`== false` 相比较时, 成立

    false == [] //true
    false == new Boolean()  //true

    false == new Object()  //false

## 原始值转换成字符串
原始值：

    数字、字符串、布尔值、null、undefined
    value + ''
    String(null)

    undefined --> "undefined"
    null      --> "null"
    true      --> "true"
    false     --> "false"
    0         --> "0"
    -0        --> "-0"
    NaN       --> "NaN"
    Infinity  --> "Infinity"
    -Infinity --> "-Infinity"
    1         --> "1"

## 原始值转换成数字
除了字符串，大部分原始值都会有固定的转换结果，如下：

    undefined  --> NaN
    null       --> 0
    true       --> 1
    false      --> 0

字符串转换成数字，会有以下的特点：

    以数字表示的字符串可以直接转换成数字
    允许字符串开头跟结尾带有空格
    在开始和结尾处的任意非空格符都不会被当成数字直接量的一部分，转换结果变成NaN

结果如下：

    +"one"  --> NaN
    +"u123" --> NaN
    +"123abc" --> NaN
    +" 123" --> 123
    +"123 " --> 123
    +" 12 " --> 12
    +" 12.5e3 " --> 1250

## 原始值转换成对象
原理：原始值通过调用String()、Number()、Boolean()构造函数，转换成他们各自的包装对象

但是null和undefined信仰比较坚定，就是不想转成对象，从而，当将它们用在期望是一个对象的地方都会抛出一个错误throws TypeError

注意：只是在转换的过程中会抛出Error，在显性创建对象的时候，不会报错

# Array
sort + unique

  myData = myData.sort().filter(function(el,i,a){return i==a.indexOf(el);})

sort()方法会直接对Array进行修改，它返回的结果仍是当前Array

  myData.sort(function(i,j){return i-j;}); //从小到大
  myData.sort(function(i,j){return i<j? -1:1;}); //从小到大>

# 加法

有下面这样的一个加法操作.

    value1 + value2

在计算这个表达式时,内部的操作步骤是这样的 (§11.6.1):

1.将两个操作数转换为原始值 (下面是数学表示法,不是JavaScript代码):

    prim1 := ToPrimitive(value1)
    prim2 := ToPrimitive(value2)

2.PreferredType被省略,因此Date类型的值采用String,其他类型的值采用Number.
3.如果prim1或者prim2中的任意一个为字符串,则将另外一个也转换成字符串,然后返回两个字符串连接操作后的结果.
4.否则,将prim1和prim2都转换为数字类型,返回他们的和.

## 2.1 预料到的结果

两个空数组相加时,结果是我们所预料的:

    > [] + []
    ''

[]会被转换成一个原始值,首先尝试valueOf()方法,返回数组本身(this):

    > var arr = [];
    > arr.valueOf() === arr
    true

这样的结果不是原始值,所以再调用toString()方法,返回一个空字符串(是一个原始值).因此,[] + []的结果实际上是两个空字符串的连接.

将一个空数组和一个空对象相加,结果也符合我们的预期:

    > [] + {}
    > '' + {}
    '[object Object]'

类似的,空对象转换成字符串是这样的.

    > String({})
    '[object Object]'

所以最终的结果是 "" 和 "[object Object]" 两个字符串的连接.

下面是更多的对象转换为原始值的例子,你能搞懂吗:

    > 5 + new Number(7)
    12
    > 6 + { valueOf: function () { return 2 } }
    8
    > "abc" + { toString: function () { return "def" } }
    'abcdef'

##2.1 意想不到的结果
如果加号前面的第一个操作数是个空对象字面量,则结果会出乎我们的意料(下面的代码在Firefox控制台中运行):

    > {} + {}
    NaN

这是怎么一回事?原因就是JavaScript引擎将第一个{}解释成了一个空的代码块并忽略了它.
NaN其实是后面的表达式+{}计算的结果 (加号以及后面的{}).这里的加号并不是代表加法的二元运算符,而是一个一元运算符,作用是将它后面的操作数转换成数字,和Number()函数完全一样.例如:

    > +"3.65"
    3.65

转换的步骤是这样的:

    +{}
    Number({})
    Number({}.toString())  // 因为{}.valueOf()不是原始值
    Number("[object Object]")
    NaN

为什么第一个{}会被解析成代码块呢?原因是,整个输入被解析成了一个语句,如果一个语句是以左大括号开始的,则这对大括号会被解析成一个代码块.所以,你也可以通过强制把输入解析成一个表达式来修复这样的计算结果:

    > ({} + {})
    '[object Object][object Object]'

另外,一个函数或方法的参数也会被解析成一个表达式:

    > console.log({} + {})
    [object Object][object Object]

经过前面的这一番讲解,对于下面这样的计算结果,你也应该不会感到吃惊了:

    > {} + []
    0

在解释一次,上面的输入被解析成了一个代码块后跟一个表达式+[].转换的步骤是这样的:

    +[]
    Number([])
    Number([].toString())  // 因为[].valueOf()不是原始值
    Number("")
    0

有趣的是,Node.js的REPL在解析类似的输入时,与Firefox和Chrome(和Node.js一样使用V8引擎)的解析结果不同.下面的输入会被解析成一个表达式,结果更符合我们的预料:

    > {} + {}
    '[object Object][object Object]'
    > {} + []
    '[object Object]'
