---
layout: page
title:	
category: blog
description: 
---
# Preface

> `php -S` 是block 的，不是用于写server-client, 会导致任何一方因为等待对方而超时 `uncaught exception 'Yar_Client_Transport_Exception' with message 'curl exec failed 'Timeout was reached''`

# php-cli

	echo '<?php var_dump($argv);' | php -- arg1 arg2

# traits
实现多重继承

	trait Object{
		protected static $_objects = [];
		/**
		 * @return static
		 */
		static function instance() {
			$className = get_called_class();
			if (empty(self::$_objects[$className])) {
				self::$_objects[$className] = new static();
			}
			return self::$_objects[$className];
		}
	}

继承实例化方法:

	class some{
		use Object{
			instance as in;
			//instance as private;
			//instance as private in;
		}
		use A, B {
			B::smallTalk insteadof A;
			A::bigTalk insteadof B;
			B::bigTalk as talk;
		}
	}

> 一般用基类`extends Instance` 就可以了。
> 如果不需要通过基类全局继承`Instance`，而是子类自己选择是否继承，此时就只能用Traits 实现多继承
> Traits 可以对方法名取别名。

# Yield, Generators 生成器
PHP spl 提供了一个Iterator 迭代器，但是需要自己实现 next/current/key 等方法

现在php 5.5 提供了更方便的Generators - 这是通过Yield 中断实现的

	// define a simple range generator
	function generateRange($start, $end, $step = 1) {
		for ($i = $start; $i < $end; $i += $step) {
			// yield one result at a time
			yield $i;
		}
	}

	foreach (generateRange(0, 1000000) as $number) {
		echo $number;
	}

每当产生一个数组元素, 就通过yield关键字返回成一个, 并且函数执行暂停(interruptible function), 当返回的迭代器的next方法被调用的时候, 会恢复刚才函数的执行, 从上一次被yield暂停的位置开始继续执行, 到下一次遇到yield的时候, 再次返回

	$range = generateRange(1, 1000000);
	var_dump($range); // object(Generator)#1
	var_dump($range instanceof Iterator); // bool(true)

可以看到，生成器继承了迭代器， 所以$range 包含了`next(), current(), key(), rewind(), valid()` 等方法.
但是rewind 方法有限制: `Cannot rewind a generator that was already run`


# foreach list
php 5.5

	foreach($arr as list($a, $b)){
	
	}

# finally

    protected function _initRequestConfig() {
        $this->_requestConfig =
            ['async' => false, 'skip_check' => false, ...];
    }

    public function request() {
		try{
			....
		}finally{
			$this->_initRequestConfig();
		}
    }

> 这在需要做清理工作的时候非常有用

# Arguments

## 可变参数函数(Variadic functions via ...)
不需要func_get_args 了

	function f($req, $opt = null, ...$params) {
		// $params is an array containing the remaining arguments.
		printf('$req: %d; $opt: %d; number of params: %d'."\n",
			   $req, $opt, count($params));
	}

	f(1);
	f(1, 2);
	f(1, 2, 3);
	f(1, 2, 3, 4);
	f(1, 2, 3, 4, 5);

## 参数解包功能(Argument unpacking via ...)

	function add($a, $b, $c) {
		return $a + $b + $c;
	}

	$operators = [2, 3];
	echo add(1, ...$operators);

# Server

	# listen all ip
	php -S 0.0.0.0:8000
	php -S 0:8000

	# listen back
	php -S localhost:8000
	php -S 127.0.0.1:8000

# Reference
php5.6:
http://wulijun.github.io/2014/01/25/whats-new-in-php-5-6.html

http://nikic.github.io/2012/12/22/Cooperative-multitasking-using-coroutines-in-PHP.html
