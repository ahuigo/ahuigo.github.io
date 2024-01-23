---
date: 2017-07-11
title: js 的函数
---
# async
## generator
    function* foo() {
        yield 11
        yield 12
        return 22;//没用
    }
    f=foo()
    f.next(); // {value: 11, done: false}
    f.next(); // {value: 12, done: false}
    f.next(); // {value: 22, done: true}
    f.next(); // {value: undefined, done: true}

    [...foo()] // [11,12]

###  iterator
    let fibonacci = {
      [Symbol.iterator]() {
        let pre = 0, cur = 1;
        return {
          next() {
            [pre, cur] = [cur, pre + cur];
            return { done: false, value: cur }
          }
        }
      }
    }
    for (var n of fibonacci) { }


# define arrow func 

    (参数1, 参数2, …, 参数N) => { 函数声明 }
    (参数1, 参数2, …, 参数N) => 表达式（单一）
    //相当于：(参数1, 参数2, …, 参数N) =>{ return 表达式; }

    // 当只有一个参数时，圆括号是可选的：
    (单一参数) => {函数声明}
    单一参数 => {函数声明}

    // 没有参数的函数应该写成一对圆括号。
    () => {函数声明}

高级语法

    //加括号的函数体返回对象字面表达式：
    参数=> ({foo: bar})

    //支持剩余参数和默认参数
    (参数1, 参数2, ...rest) => {函数声明}
    (参数1 = 默认值1,参数2, …, 参数N = 默认值N) => {函数声明}

    //同样支持参数列表解构
    let f = ([a, b] = [1, 2], {x: c} = {x: a + b}) => a + b + c;
    f();  // 6
    f([2,3],{x:100}) // 105

see js-var.md

## define + exec

    !function(){return 0}()
    (function(){return 0})()
    (()=>0)()

## define from source

    var f = new Function('a', 'alert(a)');
    f('jawil');

# arguments
如果arguments[0] 存在, name 指针都指向arguments[0]内存:
否则name 不变

	function a(name){
		arguments[0]='v11';//same as: name='v11'
		console.log(arguments, name);
	}
	a('v1','v2'); //output: ['v11', 'v2'], 'v11'

arguments本身不是Array, 如果想让 arguments 支持数组函数:

    function f(a){
        [].shift.call(arguments)
        console.log(arguments, a);
    }
    f(1); //[],1
    f(1,2); //[2],2
    f(1,2,3); //[2,3],2
    f(1,2,3,4); //[2,3,4],2

注意arguments 还是近引用传值, 修改前要copy 一下

    !function(){
        var params = Array.prototype.slice.call(arguments); // copy
        params.shift();
        console.log([params, arguments, 'ahui'])
    }(1,2,3)

## default arg

    function a(arg1=1, arg2=2){
        console.log(arg1,arg2)
        console.log(arguments)
    }
    a(undefined,3); //1,3

## 解构 Destructuring, unpacking
### destruct bind arguments
    f.bind(null,...arguments)()
    f.bind(null,...[1,2,3])()

### 解构赋值(不要求数量一致`_`)
> rust:用模式匹配 解构赋值 元组 https://course.rs/basic/compound-type/tuple.html
> go: _,b, _ = funcA()
> py-var.md: `name, *_, (*_, year) = ('Bob', 20, 50, (11, 20, 2000))`

析构array

    var [x, y, z] = ['hello', 'JavaScript', 'ES6'];
    let [, , z] = ['hello', 'JavaScript', 'ES6']; // 忽略前两个元素，只对z赋值第三个元素
    var [x, y, ...z] = ['hello', 'JavaScript', 'ES6','ES7']; #a,b,c, *arg
    var {a,...other} = {a:1,b:2,c:3}

    [...Array(5).keys()]; //0,1,2,3,4,5
    Array.from({length: 5}, (x,i) => i);

    //default
    var [a = 1] = [];

#### 析构 dict:
    //剩余参数
    {...dict} ;

    let {name, age, pass, ...rest} = {name:'ahui',pass:'pass',age:10}; //不存在就是undefined

    // 别名与默认值
    var {id:uid} = {id:1}; // uid=id
    var {uid=0} = {}

    //multiple level
    var {a:{b}} = {a:{b:2}}
    b===2

### 解构命名参数
无效(除非python):

    > function f(a, b=1){console.log(a,b)}
    > f(b=23, a=3)
    23 3

### 解构传值dict

    function buildDate({year, month, day, hour=0, minute=0, second=0}={}) {
        return new Date(year + '-' + month + '-' + day + ' ' + hour + ':' + minute + ':' + second);
    }
    buildDate({ year: 2017, month: 1, day: 1 });

没有python 多传值的麻烦

    buildDate({ more: 'hahah', year: 2017, month: 1, day: 1 });

### 解构传值 ...(rest parameter, variadic function)
> 类似golang的variadic function `func(args ...*Stu)`

unpack func args: rest 当参数不足时为`[]`

    function foo(a, b, ...rest) {
        console.log('a = ' + a);
        console.log('b = ' + b);
        console.log(rest);
    }

    foo(1, 2, 3, 4, 5);
    foo(...[1, 2, 3, 4, 5]) === foo(1,2,...[ 3, 4, 5])
    // a = 1
    // b = 2
    // Array [ 3, 4, 5 ]

unpack array:

    function foo ([a,b]){
        console.log(a,b)
    }
    foo([1,2])

unpack dictionary:

    function foo({a,b, ...rest}){
        console.log(a,b, rest)
    }
    foo({b:1,a:2})

# bind params
http://stackoverflow.com/questions/256754/how-to-pass-arguments-to-addeventlistener-listener-function/36786630#36786630

## bind params via bind
bind params by value(not by Reference)

    var a = 'before'
    function echo(a, b, c, d){
        console.log(this, [a,b,c, d]);
    }
    caller = echo.bind(null,a, a); //bind this = obj ? obj:window;
    a = 'after'
    caller(2,3); //window: [before, before, 2,3]

## bind params via anonymous func's closure
You could pass somevar by value(not by reference) via a javascript feature known as [closure][1]:

    var someVar=1;
    func = function(v){
        console.log(v);
    }
    document.addEventListener('click',function(someVar){
        return function(){func(someVar)}
    }(someVar));
    someVar=2

In generic, you could write a common wrap function such as wrapEventCallback

    function wrapEventCallback(callback){
        var args = Array.prototype.slice.call(arguments, 1);
        return function(e){
            callback.apply(this, args)
        }
    }
    var someVar=1;
    document.addEventListener('click',wrapEventCallback(v=>console.log(v),someVar))
    someVar=2

## bind via event.target

    var someInput = document.querySelector('input');
    someInput.addEventListener('click', myFunc, false);
    someInput.myParam = 'This is my parameter';
    function myFunc(evt) {
      window.alert( evt.target.myParam );
    }

## bind with jquery
    $("some selector").click({param1: "Hello", param2: "World"}, func);
        function func(e){
            e.data.param1
        }

# empty object
js

    Object.keys(obj).length === 0 && obj.constructor === Object

jQuery:

    jQuery.isEmptyObject({}); //

# Function 函数

## anonymous func
You can define a anonymous function via named function:
Example:


	//factorial
    (function(n){
    	var self = function(n){
    		//call self
			return n > 0 ? (self(n-1) * n) : 1;
    	}
    	return self;
    })()

## static variable 静态作用域
可以构造一个:

	a = function(){
		var self=a;
		self.name = 1;//static variable
	}
	a.name=1;//函数静态变量

## 闭包
privat 变量:

    function create_counter(initial) {
        var x = initial || 0;
        return {
            inc: function () {
                x += 1;
                return x;
            }
        }
    }

    var c1 = create_counter();
    c1.inc(); // 1

或者:

    x=1
    f1=(function(x){return ()=>x})(x)
    f2=()=>x

    x=2; 
    f1(); //1
    f2(); //2


## function 对象

	new a(); 函数本身就是一个类似php 的 __constructor.
	a.length; //参数数量


## eval

    i=0
    j=eval('i=1'); // i==j==1

# decorator,装饰

    var count = 0;
    var oldParseInt = parseInt; // 保存原函数

    window.parseInt = function () {
        count += 1;
        return oldParseInt.apply(null, arguments); // 调用原函数
    };

another example:

    function  cacheMethod(cls, methodName) {
        func = cls.prototype[methodName]
        cls.prototype[methodName] = function(...arg) {
            if(!this.cached){
                this.cached={}
            }
          if (!this.cached[arg]) {
            this.cached[arg] = func.call(this, ...arg)
          }
          return this.cached[arg];
        }
      }
    
    class F{
        foo(a,b){
            console.log(a,b)
            return a+b
        }
    }
    console.log(F.prototype)
    cacheMethod(F, 'foo')
    
    f = new F()
    console.log(f.foo(1,2))
    console.log(f.foo(1,2))
    console.log(f.foo(1,2))

