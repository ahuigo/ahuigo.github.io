# this scope
函数的this: 函数所在object

## 被传递的函数
其里面的this 均表示window.(jquery event call 改变了这个this)

无论它是匿名:

	str = new String('xx');
	str.func = function(f){
		f();
	}
	str.exec = function(){
        anonymousFunc = function(){console.log(this)}
		this.func(anonymousFunc);
	}
	str.exec()

还是对象函数, 或者全局函数

	str = new String('xx');
	str.func = function(f){
		f();
	}
	str.objFunc = function(){
		console.log(this);
	}
	str.func(str.objFunc)

## 被调用的函数
this 是指向定义处的this

### call/apply
用call/apply改变方法的this指向它所传的对象, 详见继承

	func.call(obj)

    function foo() { console.log(arguments); }

    // 1. directly
    foo(1, 2, 3);

    // 2. trough Function.call()
    foo.call(this, 1, 2, 3);

    // 3. trough Function.apply()
    var args = [1, 2, 3];
    foo.apply(this, args);

## var scope
匿名函数/被传递函数中的scope 是定义所在的scope:
global -> caller -> callback(anonymous)

	v="I'm global";
	function call(callback){
		var v="I'm call";
		callback();
	}
	function caller(){
		var v="I'm caller";
		call(function(){console.log(v)});
	}
	caller();//I'm caller

    dump = function(){console.log(v)}
	function caller1(){
		var v="I'm caller1";
		call(dump);
	}
    caller1(call); // I'm in global

普通函数中的scope 是定义所在的scope:

	v="I'm global";
	function call(callback){
		console.log(v);
	}
	function caller(){
		var v="I'm caller";
		call();
	}
	caller();//I'm global

### for scope
for scope 遵守var scope
全局:
(function(){ for(var i=0;i<4; i++){console.log(i);}})()
局部:
(function(){ for(i=0;i<4; i++){console.log(i);}})()