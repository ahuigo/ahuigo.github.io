---
layout: page
title:	php spl 学习
category: blog
description:
---
# Preface
SPL(Standard PHP Library) 标准库是php 自带的extension `php -m | grep SPL`，它提供了：常用的数据结构如栈，队列，堆, 数组, 以及这些数据结构的迭代器。如果需要还可自己扩展这些SPL.

SPL 主要被看作使Object(各路数据结构封装) 模仿Array 的Interfaces 和 Classes.

# Interface

在对象的基础上 为支持迭代运算符foreach, php 提供了


- Iterator
	Interface for external iterators or objects that can be iterated themselves internally.
	提供了自定义遍历的方法：`current,key,next,valid,rewind`
	它属于低层Iterator ，只提供了遍历的方法而非实现，难以对关联数组或对象属性作遍历. 也不能在foreach 做引用传值(An iterator cannot be used with foreach by reference)
- IteratorAggregate
	Interface to create an external Iterator.
	此接口为支持对属性的遍历，提供了将Object 自动重载为 外部Iterator 的方法: 自动调用 `getIterator`, 它需要借助重载类`new ArrayIterator|ArrayObject`
	它属于高层Iterator ，提供了遍历的实现，可以在foreach 做引用传值

> foreach 对象时，默认遍历的是scope 所能访问到的成员属性

为了支持基于对象的下标运算符`[]`, php 提供了 ArrayAccess

- ArrayAccess

## Iterator & IteratorAggregate
这两个接口都继承了 internal engine interface ，叫Traversable. 它提供了类似Array 统一的遍历(traversable)对象元素的方式: foreach，而不需要了解对象的具体实现。
但是这个接口不能被php 类继承，只能被 Iterator & IteratorAggregate 继承。

Iterator/IteratorAggregate 迭代器是SPL 的一部分，它指的是一种设计模式(Design Pattern). Wikimedia 中说：
Iterator is a design pattern in which iterators are used to access the elements of an aggregate object sequentially without exposing its underlying representation".

Example

	class myData implements IteratorAggregate {
		public $property1 = "Public property one";
		public $property2 = "Public property two";
		public $property3 = "Public property three";

		public function __construct() {
			$this->property4 = "last property";
		}

		public function getIterator() {
			return new ArrayIterator($this);
		}
	}

	//foreach 时，getIterator 会被自动调用
	$obj = new myData;
	foreach($obj as $key => &$value) {
		var_dump($key, $value);
	}

> 通过getIterator 实现的foreach 是可以按Reference 传值的。但是通过Iterator 的自己实现的current 是不可以在foreach 按 reference 传值的. current 是无法确定参数的值的

### DataIterator
这个迭代类是我自己定义的，它实现了遍历多维数组中的指定的字段

	class DataIterator implements Iterator{
		private $data;
		function __construct($data, $keys){
			$this->data = $data;
			$this->keys = explode(',', $keys);
		}
		function current(){
			$v = $this->data[$this->pos];
			foreach($this->keys as $k){
				$v = $v[$k];
			}
			return $v;
		}
		private $pos = 0;
		function valid(){
			return isset($this->data[$this->pos]);
		}
		function next(){
			$this->pos++;
		}
		function rewind(){
			$this->pos = 0;
		}
		function key(){
			return $this->pos;
		}
	}
	$arr = [
		['statuses'=>['user'=>['id'=>1]]],
		['statuses'=>['user'=>['id'=>2]]],
	];
	$mblogs = new DataIterator($arr, 'statuses,user,id');
	foreach($mblogs as $pos=>$uid){
		echo "uid:$uid\n";
	}

以上迭代器实现还是比较麻烦，直接返回数据简单方便

	function dataIterator($arr, $keys){
		$data = [];
		$keys = explode(',', $keys);
		foreach($arr as $v){
			foreach($keys as $k){
				$v = $v[$k];
			}
			$data[] = $v;
		}
		return $data;
	}


## ArrayAccess
在使用对象属性时，类似 `__set`, `__get` 方法。为了让对象支持数组下标操作符，也就是操作 `$obj['key']`, php 提供了类似的魔术方法

	interface ArrayAccess {
		abstract public boolean offsetExists ( mixed $offset ); //isset($obj['key'])
		abstract public mixed offsetGet ( mixed $offset );		//$obj['key']
		abstract public void offsetSet ( mixed $offset , mixed $value )	//$obj[] = 1
		abstract public void offsetUnset ( mixed $offset )	//unset($obj['key'])
	}

ArrayAccess 没有提供foreach 支持，如果需要的话需要借助 IteratorAggregate:


	class Article implements ArrayAccess, IteratorAggregate {
	 .....
	 function getIterator() {
	   return new ArrayIterator($this);
	 }
	}

## Other
以下接口功能都可以基于以上接口实现，所以，它们不太重要

### RecursiveIterator
如果需要在Iterator over Iterator recursively, 那么就需要这个接口了，它继承Iterator 并增加了`getChildren(void), hasChildren(void)`

	class MyRecursive implements RecursiveIterator{
		function __construct($arr){
			$this->data = $arr;
		}
		function hasChildren(){
			return is_array($this->data[$this->pos]);
		}
		function getChildren(){
			return $this->data[$this->pos];
		}
		....
	}
	$arr = new MyRecursive([[1,2],[3,4]]);
	foreach($arr as $k => $v){
		if($arr->hasChildren()){
			var_dump($v);
		}
	}

这货需要通过在子类中实现`hasChildren`,`getChildren` 等方法，因为RecursiveIteratorIterator，RecursiveRegexIterator 需要这些方法


	class MyRecursiveIterator implements RecursiveIterator {
		private $_data;
		private $_position = 0;

		public function __construct(array $data) {
			$this->_data = $data;
		}

		public function valid() {
			return isset($this->_data[$this->_position]);
		}

		public function hasChildren() {
			return is_array($this->_data[$this->_position]);
		}

		public function next() {
			$this->_position++;
		}

		public function current() {
			return $this->_data[$this->_position];
		}

		public function getChildren() {
			return new self($this->_data[$this->_position]);
		}

		public function rewind() {
			$this->_position = 0;
		}

		public function key() {
			return $this->_position;
		}
	}

	$arr = array( 4, 5 ,6,  array(10, 20, 30),);
	$i = new RecursiveIteratorIterator(new MyRecursiveIterator($arr));

	foreach($i as $k=>$v){
		var_dump(["$k"=>$v]);
	}

### SeekableIterator
基于Iterator 提供了seek($index)

	SeekableIterator extends Iterator {
		abstract public void seek ( int $position )
	}

### Countable
提供count 方法

	Countable {
		abstract public int count ( void )
	}


以`arrayObject` 为例子

# Classes
查看spl 内置哪些类

	var_dump(spl_classes());

对象而言，无论是支持foreach 迭代运算符(Iterator)还是下标运算符(Access). 都需要自己实现接口要求的 abstract 方法. 其实 SPL 已经提供了实现了这些方法的类：



这个类原型是 DirectoryIterator extends SplFileInfo implements SeekableIterator . 你可自己基于Iterator 写出来

## ArrayObject
This class allows objects to work as arrays.

arrayObject 内部有一个隐含的数组(storage), :

	ArrayObject implements IteratorAggregate , ArrayAccess , Serializable , Countable

1. 构造器支持对象和数组
1. ArrayAccess(下标)
2. IteratorAggregate (create an external Iterator), 注意不是Iterator）
2. exchangeArray
2. 隐含了`__array` 这样的魔法函数(php 目前还不支持此魔法);
3. asort()/ksort()/usort()/natsort()等;setIteratorClass();

	class data extends arrayObject{
		function set(){
			$this->exchangeArray(['key'=>1]);
		}
		function offsetSet($k, $v){
			parent::offsetSet($k, $v);
		}
		function get(){
			return $this->getArrayCopy();
			//return (array)$this;
		}
	}
	$a = new data();
	$a->set();
	echo $a['key'];//1
	print_r((array)$a);//key=>1

## ArrayIterator
ArrayIterator 与ArrayObject 相比，缺少exchangeArray().
除此之外，它们的功能是一样的. 另外，如果参数做类型检查时要求使用 ArrayIterator，就不可用 ArrayObject

## CachingIterator
This object supports cached iteration over another iterator.

它提供了hasNext 方法

	$object = new CachingIterator(new ArrayIterator([1,2,3]));
	foreach($object as $value) {
		echo $value;
		if($object->hasNext()) {
			echo ',';
		}
	}


## FilterIterator
FilterIterator 提供了fiter. 只extends IteratorIterator (construct 会接受Iterator, 它继承 OuterIterator, `Recursive*Iterator` 的构造器接受 ), 不支持ArrayAccess(需要的话还需要implements)

	class LengthFilterIterator extends FilterIterator {
		public function accept() {
			// Only accept strings with a length of 10 and greater
			return strlen(parent::current()) > 10;
		}
	}

## DirectoryIterator
DirectoryIterator 针对目录的迭代类

	foreach (new DirectoryIterator('../moodle') as $i => $fileInfo) {
		if($fileInfo->isFile())
		echo $fileInfo->getFilename() . "\n";
	}

via RecursiveIteratorIterator(Recursive):

	$files = new RecursiveDirectoryIterator('.');//不是递归的
	$files = new RecursiveIteratorIterator(new RecursiveDirectoryIterator('.'), RecursiveIteratorIterator::SELF_FIRST);
	foreach($files as $pathname => $fileInfo){
		if($fileInfo->isFile()){echo $pathname."\n";}
	}

via RecursiveIteratorIterator(filter key(filename) with Regex):

	$Directory = new RecursiveDirectoryIterator('.');
	$Iterator = new RecursiveIteratorIterator($Directory);
	$Regex = new RegexIterator($Iterator, '/\.php$/i', RegexIterator::GET_MATCH); // It matches against (string)$fileobj
	foreach($Regex as $pathname=>$matches){
		echo "$pathname\n";
		var_export($matches);
	}

	RecursiveRegexIterator::GET_MATCH
		like $matches in preg_match
	RecursiveRegexIterator::MATCH
		get $fileObj

via shell

	for i in `ls .` ;do {  echo $i abc} done

## SplFileObject
和DirectoryIterator 一样，继承了SplFileInfo
它用于遍历行，支持foreach/seek()/valid()/current(); 包括换行符`0x0a`

	//获取行[$start,$end)
	$file = new SplFileObject("b.php");
	$file->seek($start);//start from 0 line
	$i=0;
	while($i++< $end - $start){
		$str .= $file->current();
		$file->next();
	}

`$i ` 从0 开始, 且最后`$line` 为空字符: `explode("\n", $str)` 但包括"\n":

	foreach($file as $i=>$line){
		echo "$i:$line\n";
	}

fgets

	$handle = fopen("inputfile.txt", "r");
	if ($handle) {
		while (($line = fgets($handle)) !== false) {
			// process the line read.
		}
		fclose($handle);
	}

> 最后有一个空白符, 即换行符

	$handle = null;//close

## RegexIterator
It is used to filter another iterator based on a regular expression.

	$a = new ArrayIterator(array('test1', 'test2', 'test3'));
	$i = new RegexIterator($a, '/^(test)(\d+)/', RegexIterator::REPLACE);
	$i->replacement = '$2:$1';
	var_export(iterator_to_array($i));

Output:

	array (
	  0 => '1:test',
	  1 => '2:test',
	  2 => '3:test',
	)

## iterator_to_array
Copy the iterator into an array.

	$iterator = new ArrayIterator(array('recipe'=>'pancakes', 'egg', 'milk', 'flour'));
	var_dump(iterator_to_array($iterator, $use_keys=true));

## RecursiveIteratorIterator & RecursiveArrayIterator
- RecursiveIteratorIterator 递归迭代Iterator
- RecursiveArrayIterator	产生一个可递归的Iterator
- RecursiveDirectoryIterator	产生一个可递归的Iterator

	$array = array(
		array('name'=>'butch', 'sex'=>'m', 'breed'=>'boxer'),
		array('name'=>'fido', 'sex'=>'m', 'breed'=>'doberman'),
	);

	foreach(new RecursiveIteratorIterator(new RecursiveArrayIterator($array)) as $key=>$value) {
		echo $key.' -- '.$value."\n";
	}

## SplQueue

- enqueue($) == push($)
- dequeue() like shift()
- pop()
- isEmpty()

Example

	$q = new SplQueue();
	$q->push(1);
	$q->push(2);
	$q->push(3);
	$q->pop();
	print_r($q);


# SPL function

## Class

	class_implements — Return the interfaces which are implemented by the given class or interface
	class_parents — Return all parent classes of the given class
	class_uses — Return the traits used by the given class

	spl_autoload_register ($autoload_function , $throw = true , $prepend = false  )
			 用于代替只支持一个func 的 __autoload($class)
			func 不用返回true/false. spl 自动判断是否成功加载了类, 不成功则依次调用func2 func3...
			无论是在前，还是在后，它会让__autoload 失效

常量:

	class a{
		const KEY='a';
		funcction get($key = 'KEY'){
			echo constant('self::' . $key);
		}
	}
	//or
	echo (new ReflectionClass('a'))->getConstant('KEY')

运行时：

	get_class ([ object $object = NULL ] ); //the calssName of $object or current class
	get_called_class(void); //the "Late Static Binding" class name
    get_parent_class('subclass' or $subObject)

	get_class_methods() - Gets the class methods' names
	get_class_vars() - Get the default properties of the class
        get_object_vars()

	is_subclass_of($obj, 'MyClass');
	is_subclass_of('subclass', 'MyClass');

## Object

### instance of

	var_dump($obj instanceof MyClass);

### Spl Object property 对象成员属性

	public function export() {
        foreach (get_object_vars($this) as $k => $v) {
            $this->$k = $v;
        }
    }
	public function import($arr) {
		foreach($arr as $k=>$v){
			$this->$k = $v;
		}
	}

> 	get_object_vars will only find non-static properties
	get_object_vars will only find accessible properties according to scope

#### property_exists

	$this->protected_property = null;
	property_exists($this, 'protected_property');//true
	isset($this->protected_property);//false

	array_key_exists('v', $GLOBALS);//$v=null;

### caller name

	public function getCallerName(){
        return debug_backtrace( DEBUG_BACKTRACE_IGNORE_ARGS, 3)[2]['function'];
    }

# Exception

	LogicException (extends Exception)
		BadFunctionCallException
			BadMethodCallException
		DomainException
		InvalidArgumentException
		LengthException
		OutOfRangeException

	RuntimeException (extends Exception)
		OutOfBoundsException
		OverflowException
		RangeException
		UnderflowException
		UnexpectedValueException

    class EExcetion extends Exception{
        function __construct($err, $errno, $data){
        }
    }

# Reference
- [spl 学习]

[spl 学习]:
http://www.ruanyifeng.com/blog/2008/07/php_spl_notes.html
