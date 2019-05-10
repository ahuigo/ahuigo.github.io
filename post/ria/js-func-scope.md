---
title: Js 中的this scope
date: 2018-10-04
---
# Js 中的this scope
一般this 是使用的时候才确定指向:

    function A(){
        this.name='ahui'
    }
    A.prototype.say=()=>console.log(this.name)
    (new A).say()

1. 方法调用: this向当前的 object


    function getAge() {
        return this.birth;
    }

    var xiaoming = {
        birth: 1990,
        age: getAge
    };
    //or xiaoming.age=getAge


## this in module
Within module: `this` is `{}`, not `global===window`

## 单独调用函数的情况(坑)
你只需要记住谁调用的，this就指向谁，也就是.前面的对象，假如没有.，默认补一个window.;
1. strict 指向undefined, 否则指window. 
2. Lexical this 指向闭包(es6), 闭包是定义所在的this

分情况举例

a. 如果单独调用函数，比如getAge()，此时，该函数的this指向全局对象，也就是window。

    getAge(); //window

b. 方法变函数单独调用，指向window

    var xiaoming = {
        birth: 1990,
        age: function(){return this}
    };
    age=xiaoming.age
    age();//window

c. 对像方法内部：单独函数定义及调用，this 指window 

    var xiaoming = {
        name: '小明',
        birth: 1990,
        age: function () {
            function getAgeFromBirth() {
                console.log(this)
            }
            return getAgeFromBirth();
        }
    };
    xiaoming.age(); //window

d. 回调方法内: window, (除非改arrow lexical this)

    var xiaoming = {
        name: '小明',
        birth: 1990,
        call(func){
            func()
        },
        age: function () {
            this.call(()=>console.log(this))
        }
    };
    xiaoming.age(); 

## Lexical this 是闭包this
Lexical 闭包是定义处是this

    var xiaoming = {
        name: '小明',
        birth: 1990,
        call(func){
            func()
        },
        age: function () {
            this.call(()=>{                       //声明的时候就绑定了this
                [1].map(v=>console.log(v, this)); //xiaoming
            })
        }
    };

    xiaoming.age(); 

Lexical this 是定义处是window

    let someObj = {
        a() {
            console.log(this);
        },
        b: () => {
            console.log(this);
        }
    }
    someObj.a(); //someObj
    someObj.b(); // window

改匿名函数还是window

    var xiaoming = {
        name: '小明',
        birth: 1990,
        call(func){
            func()
        },
        age: function () {
            this.call(function(){                 // 不是lexical, 传this=window (modified)
                [1].map(v=>console.log(v, this)); //lexical this 收到的还是window
            })
        }
    };
    xiaoming.age(); 

## 修改this
修改方法1: that=this:

        var that = this; // 在方法内部一开始就捕获this
        function getAgeFromBirth() {
            return y - that.birth; // 用that而不是this
        }

修改方法2: 用剪头函数固定this (闭包):

    var xiaoming = {
        name: '小明',
        birth: 1990,
        age: function () {
            console.log(this); //xiaoming
            var fn = () => this;
            return fn();
        }
    };
    xiaoming.age()===xiaoming; //true

## modify this scope

    function fn(){
        console.log(this)
    }
    var xiaoming = {
        birth: 1990,
        age: function (fn) {
            fn.apply(this)
        }
    };
    xiaoming.age(fn);

### call/apply
用call/apply改变方法的this指向它所传的对象, 详见继承

    function foo() { console.log(arguments); }

    // 2. trough Function.call()
    foo.call(this, 1, 2, 3);

    // 3. trough Function.apply()
    var args = [1, 2, 3];
    foo.apply(this, args);

对普通函数调用，我们通常把this绑定为null。

    Math.max.apply(null, [3, 5, 4]); // 5

# var scope
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


# Lexical arguments
    function square() {
    let example = () => {
        let numbers = [];
        for (let number of arguments) {
        numbers.push(number * number);
        }

        return numbers;
    };

    return example();
    }

    square(2, 4, 7.5, 8, 11.5, 21); // returns: [4, 16, 56.25, 64, 132.25, 441]