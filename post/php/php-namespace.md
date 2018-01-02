---
layout: page
title:	php 命名空间
category: blog
description: 
---
# Preface

命名空间namespace 的作用是:

- 解决类名/函数名/常量名冲突
- 将很长的标识符名称创建一个别名

# Usage

	namespace my\name; // 参考 "定义命名空间" 小节

	class MyClass {}
	function myfunction() {}
	const MYCONST = 1;

	$a = new MyClass;
	$c = new \my\name\MyClass; // 参考 "全局空间" 小节

	$a = strlen('hi'); // 参考 "使用命名空间：后备全局函数/常量" 小节

	$d = namespace\MYCONST; // 参考 "namespace操作符和__NAMESPACE__常量” 小节

	$d = __NAMESPACE__ . '\MYCONST';
	echo constant($d); // 参考 "命名空间和动态语言特征" 小节

# Define Namespace
命名空间：

	<?php
	namespace MyNamespace1;
	some code...;

	namespace MyNamespace2;
	some code...;

定义命名空间之前，不能有任何*非命名空间代码*，也不能有任何*非php代码*(空白符也不行)

# Namespace Classes
命名空间的使用分三类

## Namespace 

## Unqualified name 非限定名称
foo()，被解释为`currentnamesapce\foo`

	namespace Bar\Proj;
	foo();//Resolve to Bar\Proj\foo

非限定名称 - 后备全局函数/常量：

1. 对于类名来说，在局部标识中找不到会报错
1. 对于函数名/常量名来说，在局部标识中找不到, 就去全局空间查找

为什么会这样？因为为了避免strlen 这些常见的全局函数加前缀"\", 对于: `new mysqli()` 这种类名来说，可以加全局的`\\`

## Qualified name 限定名称
subnamespace\foo()，被解释为`currentnamesapce\subnamespace\foo`

	namespace Bar\Proj;
	Master\foo();//Resolve to Bar\Proj\Master\foo

`namesapce` 关键字相当于 currentnamespace(看起来多此一举呢):

	namespace\foo();		//Resolve to Bar\Proj\foo
	namespace\Master\foo();	//Resolve to Bar\Proj\Master\foo

## Full qualified name 完全限定名称
`\currentnamespace\foo()`，被解释为`currentnamesapce\foo`

	namespace Bar\Proj;
	\Master\foo();//Resolve to Master\foo

	$a = \strlen('hi'); // calls global function strlen

# Namespace in variable
如果标识是存放到变量，那么标识会被解释为字面意思(即实际访问的是字面变量)

	namespace NamespaceName;
	funciton foo(){}
	
	//success
	$a = 'NamesapceName\foo';//Resolve to Namespace\foo
	$a();
	
	//failed
	$a = 'foo';//Resolve to foo
	$a();

变量标识 应该使用`__NAMESPACE__`：

	namespace My;
	function foo(){}

	$a = __NAMESPACE__ . '\foo';
	$a();
	
# Aliasing/importing
php 允许使用别名和导入 外部*完全限定名称*:

	namespace foo;
	use My\Full\Classname as Another;

	// this is the same as `use My\Full\NSname as NSname`
	use My\Full\NSname;

	//Mutiple use statements combined
	use My\Full\Classname as Another, My\Full\NSname;

	$obj = new namespace\Another; // instantiates object of class foo\Another
	$obj = new Another; // instantiates object of class My\Full\Classname
	NSname\subns\func(); // calls function My\Full\NSname\subns\func
	
	// importing a global class
	use ArrayObject;

# include/require 
include/require 不影响当前命名空间，当前命名空间也不会影响包含文件内代码的命名空间
include 不会发生错误停止运行?

# PSR-4
PSR-4 用于代替PSR-0. 规则如下：

	Fully Qualified Class Name	Namespace Prefix	Base Directory			Resulting File Path
	\Aura\Web\Response\Status	Aura\Web			/path/to/aura-web/src/	/path/to/aura-web/src/Response/Status.php


与PSR-0 相比： Underscores have no special meaning in any portion of the fully qualified class name.
