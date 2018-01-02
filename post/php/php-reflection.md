---
layout: page
title:	php 的反射
category: blog
description:
---
# Preface
php的反射可以实现对自身代码的控制，这使得php具备一定的元编程的能力

	class A{
		public $var;
		protected $_var;
		private $_var;

		static $static_var;

		public function func(){ }
		protected function _func(){ }
		private function __func(){ }
		static function sta_func(){}
	}

通过类反射ReflectionClass，我们可以得到A类的以下信息：

	常量 Contants
	属性 Property Names
	方法 Method Names静态
	属性 Static Properties
	命名空间 Namespace
	类是否为final或者abstract

> private 不限制反射

# ReflectionClass, 反射一个类

	$class = new ReflectionClass('A');//建立类的反射类

它含有的方法

    ->getName()
    ->getProperties()
    ->isUserDefined()
    ->isInternal()

## file

    ->getFileName()
    ->getStartLine()
    ->getEndLine()

## instance

	$instance  = $class->newInstanceArgs($args);//相当于实例化ClassName 类

## 获取成员

	$props = $class->getProperties(ReflectionProperty::IS_PRIVATE | ReflectionProperty::IS_PUBLIC);
	 	$props[0]->getName();
	 	$props[0]->getDocComment();
	$methods = $class->getMethods(ReflectionProperty::IS_PRIVATE | ReflectionProperty::IS_PUBLIC);
		$methods[0]->getName();
		$methods[0]->name;
		$methods[0]->getDocComment();
		$methods[0]->invoke($instance, $params);//相当于$instance->method($params)

# ReflectionObject

	ReflectionObject::export($obj);

# ReflectionMethod, 反射一个类方法

	ReflectionMethod::export('classA', 'func');
	ReflectionMethod::export(new classA, 'func');

get ReflectionMethod

	new ReflectionMethod(classA, 'func');
    $r->getMethods()
    $r->getMethod('func')

method:

    $method->invoke($instance, $param)

属性:

    $method->isPublic()
    $method->isAbstract()
    $method->isConstructor()
    $method->isReturnReference()

## get code of method

	class a{
		/**
		 * test
		 */
		function b($name){
			echo "$name\n";
		}
	}
	class ReflectionVclass extends ReflectionClass{
		function getMethodCode($name, $comment = false){
			$fun = $this->getMethod($name);
			$fileName = $fun->getFileName();

			$file = new SplFileObject($fileName);
			$start = $fun->getStartLine();
			$end = $fun->getEndLine();
			$file->seek($start-1);

			$i=0;
			$str = $comment ? $fun->getDocComment() : '';
			while($i++ < $end+1 - $start){
				$str .= $file->current();
				$file->next();
			}
			return $str;
		}
	}
	$a = new ReflectionVclass(new a);
	$a = new ReflectionVclass('a');
	echo $a->getMethodCode('b');

# ReflectionParameter

    $method->getParameters()
    $method->getParameter('param') undefined

$param:

    $param->getName()
    $param->getDeclaringClass() ReflectionClass
    $param->getClass() ReflectionClass - if param is object
    $param->isPassedByReference()

# ReflectionFunction

	echo ReflectionFunction::export('func',true);

## invokeArgs
There is a difference in performance when `using call_user_func_array` vs. calling the `function` directly, but it's not that big (`around 15x slower`). Unless you're using it thousands of times, you won't notice it.

To answer your question, you can build one yourself:

    function call($fn, array $args = array()){

      $numArgs = count($args);

      if($numArgs < 1)
        return $fn();

      if($numArgs === 1)
        return $fn($args[0]);

      if($numArgs === 2)
        return $fn($args[0], $args[1]);

      // ...

      return call_user_func_array($fn, $args);
    }

There's also `ReflectionFunction::invokeArgs` (and `ReflectionMethod::invokeArgs`):

    $reflector = new ReflectionFunction($fn);
    return $reflector->invokeArgs($args);
