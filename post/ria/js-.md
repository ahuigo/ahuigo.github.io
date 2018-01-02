---
layout: page
title:	js notes
category: blog
description:
---
# Preface
本文参考: [](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript)

# todo
https://leanpub.com/exploring-es6/read
https://es6.ruanyifeng.com/
javascript 一站式
http://www.liaoxuefeng.com/wiki/001434446689867b27157e896e74d51a89c25cc8b43bdb3000

前端工程：
https://github.com/fouber/blog/blob/master/201508/01.md?from=timeline&isappinstalled=0

# TOC
- js-scope

# Expression
## Condition 

	switch(n) { case 1: code break;}
	带类型匹配

## break label

	break [label]; 不支持break numer

	function foo () {
		dance:
		for(var k = 0; k < 4; k++){
			for(var m = 0; m < 4; m++){
				if(m == 2){
					break dance;
				}
			}
		}
	}

## 迭代
	for(i in obj){obj[i]...} // PropertyIsEnumerable
	for(i=0;i<5;i++){...}

# Variable
[p/js-var](/p/js-var)


# 运算符

## 一元

	delete variable
	delete obj.name

## Bits Operation 位运算

	num & num
	num | num
	~num 取反
	num ^ num	//xor
	#左右位移(有符号)
	1<<2 # 1<<34 == 1<<2
	a>>32 === a>>0 === a;
		#有符号右移(符号位不变)
		-4>>1; -2
		-4>>2; -1
		-4>>3; -1
		-4>>4; -1

		#有符号左移==无符号左移等价(但符号位会变)
		-1<<2; -4
		-1<<31 ; -2147483648
		1<<30 ; 1073741824
		1<<31 ; -2147483648

		#无符号移右移(高位变成0), 符号位会变,输出无符号数
		> -1>>>1; 2147483647
		> -1>>>0; 4294967295
		> -1>>>32; 4294967295

		#不存在有符号移左移
		1<<<3

## 逻辑

	!var
	var && var
		逻辑 AND 运算并不一定返回 Boolean 值：
			如果一个运算数是对象，另一个是 Boolean 值，返回该对象。
				1 && obj //return obj
				0 && obj // return 0
				obj1 && obj2 //return obj2(if obj1不为空)
			如果某个运算数是 null
				1 && null //return null
				0 && null //return 0
			如果某个运算数是 NaN
				1 && NaN //return NaN
				0 && NaN //return 0
	var || var
		逻辑 OR 运算并不一定返回 Boolean 值(同上)

# Object

## keys
list forEach

	Object.keys({a:1, b:2})
		["a", "b"]
	Object.keys(obj).forEach(function(key){
		console.log(key, obj[key])
	})

## has key value

	if('key' in myObj){ }

	function hasValue(obj, key, value) {
		return obj.hasOwnProperty(key) && obj[key] === value;
	}

## extend

	Object.prototype.extend = function(defaults) {
		for (var i in defaults) {
			if(i in this){ //if(!this[i]) 
				this[i] = defaults[i];
			}
		}
	};

## 判断原型

	obj instanceof funcname// 函数原型名

## Property 属性

.constructor(指向函数)
	对创建对象的函数的引用（指针）。对于 Object 对象，该指针指向原始的 Object() 函数。

.Prototype(指向对象原型)
	对该对象的对象原型的引用。对于所有的对象，它默认返回 Object 对象的一个实例。

.hasOwnProperty('property')
	判断对象是否有某个特定的属性

.IsPrototypeOf(object)
	判断该对象是否为另一个对象的原型。

.propertyIsEnumerable
	判断给定的属性是否可以用 for...in 语句进行枚举。

## value

	Object.prototype.hasOwnValue = function(val) {
		for(var prop in this) {
			if(this.hasOwnProperty(prop) && this[prop] === val) {
				return true;
			}
		}
		return false;
	};

### Object.defineProperty()

	obj[name] = value;
	//or
    Object.defineProperty(obj, name, { value: value, writable: false });

Example1，在ES5 中Prototype 可以用来将定义魔法属性，可以实现类似 PHP 类的`__get`, `__set`

	Number.prototype = Object.defineProperty(
	  Number.prototype, "double", {
		get: function (){return (this + this)}
	  }
	);
	(3).double;//6
	3['double'].double;//6
	3..double;//6 第一个点被解析为小数点，第二个点被解释为操作符

对原始类型做对象操作时，js 会用原始类型的对象wrapper 把变量包装一下，然后在临时对象上操作。

	var a=3; //是数值，不是数值对象
	a.key=1; //js 数据类型的对象wrapper 会将a 包装为临时的数值对象. 相当于`(new Number(a)).key=1`
	a.key;//undefined 因为临时对象不存在了

## 创建对象

1. obj = new Object();
2. person={firstname:"John"};
3. obj = new func(param1, param2);

## 本地对象

	Object
	Function
	Array
	String
	Boolean
	Number
	Date
	RegExp
	Error
	EvalError
	RangeError
	ReferenceError
	SyntaxError
	TypeError
	URIError

## 定义对象的模式

### 工厂方式(deprecated)
工厂方式的点是:
1. 每次new factory 都会创建单独的函数
2. 太复杂

	function factory(v1, v2){
		obj = new Object();
		obj.param1 = v1;
		obj.param2 = v2;
		obj.func = function(){};
		return obj;
	}
	obj = factory(1,2)

### 构造方式(deprecated)
只避免了factory 的第二个缺点: 复杂性

1. 每次都会生成新的function.

	function construction(v1,v2){
		this.p1 = v1;
		this.p2 = v2;
		this.func = function(){}; //为避免重复的func, 可在外部定义
	}
	obj = new constructor(1,2)

### 原型方式(deprecated)
没有工厂方法的缺点，但产生了新的缺点：

- 不能传参数

	function Car() {
	}
	Car.prototype.color = "blue";
	Car.prototype.showColor = function() {
	  alert(this.color);
	};
	(new Car) instanceof Car;//true;
	(new Car) instanceof Object;//true;
	(new Car) instanceof Number;//false;

### 静态的构造原型混合
- 构造: 放私有的属性
- 原型: 放公共的属性

> 批评静态构造函数原型混合方式的人认为，在构造函数内部找属性，在其外部找方法的做法不合逻辑: 所以就有一种动态 构造/原型混合

#### 动态构造原型混合

	function Car(color){
		//private
		this.color=color;

		//public(prototype)
		//if (typeof Car._initialized === "undefined") {
		if (Car._initialized === undefined) {
			var self = Car;
			self._initialized = true;//非prototype 的_initialized 不会被继承，但是它相当于Car 内的静态变量
			self.prototype.showColor = function() {
			  console.log(this.color);
			};
		}
	  }
	}

## Extends 继承

### 对象冒充
ClassB 继承 ClassA

	function ClassA(color){
		this.color = color;
	}
	function ClassB(color, num){
		this.method = ClassA; //ClassB就冒充了ClassA中的this
		this.method(color)
		delete this.method;

		this.method = ClassA1; //ClassB就冒充了ClassA1中的this(可以多重继承的)
		this.method(num);
		delete this.method;

		this.color = value; //Notice; 会覆盖前面的属性. 请确保属性名不冲突
	}
	new ClassB('red', 5);

### Call()

	function sayColor(sPrefix,sSuffix) {
		alert(sPrefix + this.color + sSuffix);
	};

	var obj = new Object();
	obj.color = "blue";

	sayColor.call(obj, "The color is ", "a very nice color indeed.");// saycolor中的this会指向obj, obj对象就冒充了saycolor.

#### 用call 实现继承

	function ClassB(sColor, sName) {
		//this.newMethod = ClassA;
		//this.newMethod(color);
		//delete this.newMethod;
		ClassA.call(this, sColor);//执行时，this冒充了ClassA

		this.name = sName;
		this.sayName = function () {
			alert(this.name);
		};
	}

### apply 方法冒充继承
apply与call方法类似, 除了参数调用形式不一样.

	function sayColor(sPrefix,sSuffix) {
		alert(sPrefix + this.color + sSuffix);
	};

	var obj = new Object();
	obj.color = "blue";

	sayColor.apply(obj, new Array("The color is ", "a very nice color indeed."));

#### apply 实现继承.

	function ClassB(sColor, sName) {
		//this.newMethod = ClassA;
		//this.newMethod(color);
		//delete this.newMethod;
		ClassA.apply(this, arguments);//arguments === new Array(sColor);

		this.name = sName;
		this.sayName = function () {
			alert(this.name);
		};
	}

还有一个bind 方法，但函数使用bind 时，函数不会执行 `var get = request.bind(this, 'GET', arg2, ... );` request 就不会执行。

它主要用于定制一个新的 requset 的函数，并默认函数的this 及定制参数:
https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Function/bind


### 原型链（prototype chaining）
用prototype 对象去继承.
缺点: 不能控制被继承类的传参(一般都不会传参数)

	function ClassA() {
	}

	ClassA.prototype.color = "blue";
	ClassA.prototype.sayColor = function () {
		alert(this.color);
	};

	function ClassB() {
	}

	ClassB.prototype = new ClassA(); //继承了啦.

### 混合方式
对象冒充: 不能冒充静态成员(prototype public)
原型链: 因为prototype 是公共的, 所以传argument(private)就不合适了.故产生了apply/call + 原型的混合方式.

	function ClassA(color) {
		this.color = color;
		if(ClassA.init === undefined){
			ClassA.init = true;
			ClassA.prototype.sayColor = function () {
				console.log(this.color);
			};
		}
	}

	function ClassB(sColor, sName) {
		var self = ClassB;
		if( self.init === undefined){
			self.init = true;
			//self.prototype = new ClassA(); //1. 原型链冒充 原类的静态成员(prototype). 最好别传new ClassA(sColor),因为sColor应该是每个对象私有的.
			self.prototype = Object.create(ClassA.prototype)
		}
		ClassA.call(this, sColor);// 2. 再冒充ClasA对象.
		this.name = sName;
	}

用Call 继承属性方法初始化，用`Object.create` 继承公共属性与方法
再来一个例子：

	//Shape - superclass
	function Shape() {
	  this.x = 0;
	  this.y = 0;
	}

	Shape.prototype.move = function(x, y) {
		this.x += x;
		this.y += y;
		console.info("Shape moved.");
	};

	// Rectangle - subclass
	function Rectangle() {
	  Shape.call(this); //call super constructor.
	}

	Rectangle.prototype = Object.create(Shape.prototype);

	var rect = new Rectangle();

	rect instanceof Rectangle //true.
	rect instanceof Shape //true.

	rect.move(1, 1); //Outputs, "Shape moved."

# profile
- [js profile]

[js profile]: http://kb.cnblogs.com/page/501177/
