# bind params
http://stackoverflow.com/questions/256754/how-to-pass-arguments-to-addeventlistener-listener-function/36786630#36786630

## bind params via bind
bind params by value(not by Reference)

    var a = 'before'
    function echo(a, b, c, d){
        console.log(a,b,c, d);
    }
    function caller(callback){
        callback(2,3);
    }
    caller(echo.bind(null,a, a));//bind： before, before, 2,3
    a = 'after'

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
    func = function(v){
        console.log(v);
    }
    document.addEventListener('click',wrapEventCallback(func,someVar))
    someVar=2

## bind via event.target

    var someInput = document.querySelector('input');
    someInput.addEventListener('click', myFunc, false);
    someInput.myParam = 'This is my parameter';
    function myFunc(evt) {
      window.alert( evt.target.myParam );
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

	变量的作用域链.

## arguments
如果arguments[0] 存在, name 指针都指向arguments[0]:
否则name 不变

	function a(name){
		arguments[0]='v11';//same as: name='v11'
		console.log(arguments, name);
	}
	a('v1','v2'); //output: ['v11', 'v2'], 'v11'

如果想让 arguments 支持数组函数:

    function f(a){
        [].shift.call(arguments)
        console.log(arguments, a);
    }
    f(1); //[],1
    f(1,2); //[2],2
    f(1,2,3); //[2,3],2
    f(1,2,3,4); //[2,3,4],2

push.apply

    var args = [];
    Array.prototype.push.apply( args, arguments );

slice:

    //注意arguments 中的object/array 还是近引用传值, string 不是
    var params = Array.prototype.slice.call(arguments);
    params.shift();

## function 对象

	new a(); 函数本身就是一个类似php 的 __constructor.
	a.length; //参数数量
