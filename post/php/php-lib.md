---
layout: page
title:	php 知识库
category: blog
description:
---
# Preface
关于php 的函数

# todo
https://github.com/AnewG/Modern-php?files=1

# Configration
可以用parse_ini_file()函数解析INI配置文件

	$phpini = `php -qr "echo php_ini_loaded_file();"`

# Data Type

	ctype_alnum
	ctype_digit
	ctype_alpha
	in_numeric

	settype(&$var, $type);
	gettype($var);

	php > echo ctype_digit('1234'); 1
	php > echo ctype_digit(1234); 1
	php > echo ctype_digit('1234.5'); false
	echo is_numeric('1234.3');//true


# filter

## Validate Filter
https://github.com/Respect/Validation

	var_dump(filter_var('bob@example.com', FILTER_VALIDATE_EMAIL));
	var_dump(filter_var('http://example.com', FILTER_VALIDATE_URL, FILTER_FLAG_PATH_REQUIRED));//false
	FILTER_VALIDATE_IP
	FILTER_VALIDATE_FLOAT
	FILTER_VALIDATE_INT
	FILTER_VALIDATE_REGEXP

### Sanitize filters

	var_dump('<a>hello</a>', FILTER_SANITIZE_STRING); //hello, like strip_tags
	FILTER_SANITIZE_EMAIL 去掉和邮件地址无关的字符
	FILTER_SANITIZE_NUMBER_INT 去掉和INT 无关的字符
	FILTER_SANITIZE_SPECIAL_CHARS 去HTML 特殊字符 `<>&'"` 编码

# Const

	const N = 1
	get_defined_constants(true)['user']
	get_defined_constants(true)['Core']
	get_defined_constants(true)['xdebug']

# Object

## instance

	/**
     * @return static
     */
    public static function instance() {
        $className = get_called_class();
        if (self::$objects[$className] === null) {
            self::$objects[$className] = new static;
        }
        return self::$objects[$className];
    }

## callback

	call_user_func_array(array(__CLASS__, 'func'), $arr);//static
	call_user_func_array(array($this, 'func'), $arr);//obj

# class

## traits
traits 是为单继承语言设计的一个代码复用机制。它和类组合的语义，避免了传统的多继承和混入类（Mixin）的复杂性。

Example:

	trait classA{
		function funA(){ echo __METHOD__ ."\n";	}
	}
	trait classB{
		function funB(){ echo __METHOD__ ."\n";	}
	}

	class A extends Exception{
		use classA;
		use classB;
		function __construct(){
			$this->funA();	//classA::funA
			$this->funB();	//classB::funB
		}
	}
	new A;

# Exception & Error

## try catch

	try{$this->clean(); return $res;}
	finally{return $this->clean();}

## Exception
Exception 用来API 错误信息返回特别有方便,
这比每个api 函数自己封装errno/err 要方便多了

	class BaseApiController{
		function __construct(){
			set_exception_handler(function($e){
				echo json_encode([
					'errno' => $e->getCode(),
					'error' => $e->getMessage(),
				], JSON_UNESCAPED_UNICODE);
			});
		}
	}

restore_exception:

	set_exception_handler('exception_handler_1');
    set_exception_handler('exception_handler_2');
    restore_exception_handler();

## Error
The following error cannot be handled with user defined function: E_ERROR, E_PARSE, E_CORE_ERROR, E_CORE_WARNING, E_COMPILE_ERROR, E_COMPILE_WARNING, and most of E_STRICT raised in the file where set_error_handler() is called.

	set_error_handler(function ($errCode, $errMesg, $errFile, $errLine) {
		echo "Error Occurred\n";
		throw new Exception($errMesg);
	});

如果要捕获Fatal Error, 可以用register_shutdown_function(), 参考[](http://stackoverflow.com/questions/277224/how-do-i-catch-a-php-fatal-error):

	register_shutdown_function( "fatal_handler" );
	function fatal_handler() {
	  $error = error_get_last();
	  if( $error !== NULL) {
		/*	$error["type"];
			$error["file"];
			$error["line"];
			$error["message"];
		 */
		  $error['errno'] = E_CORE_ERROR;
		  $trace = print_r( debug_backtrace( false ), true );
		  var_dump($trace, $error);
	  }
	}

Error handler 内throw 的异常不能被 exception handler 捕获，error handler 相当于exit 会跳过 exception handler
Refer to : [深入理解异常](http://www.laruence.com/2010/08/03/1697.html)

# fastcgi

## fastcgi_finish_request
flush数据到客户端。调用这个方法后，再有任何输出内容，都不会输出到客户端。

# Function

## Anonymous function recursively
use 传闭包变量

	$f = function() use($bar, $foo, &$f) { //$f 必须为引用，否则$f 会报: Notice:  Undefined variable: f
	   $f();
	};

## get_defined_functions

	array get_defined_functions(void)['user'];
	array get_defined_functions(void)['internal'];

## function argument

	func_num_args(void),
	func_get_arg(n), // get n'th argument
	func_get_args(void).

## register_shutdown_function
register_shutdown_function 可以有多个, 在php 结束时触发：

	register_shutdown_function( func1 );
	register_shutdown_function( func2 );

但是它对die 是没有用的，不过可以使用`__destruct()` 或者`ob_start`

# Math

## rand

	rand(0,99); //Rand from 0 to 99(). It does not generate cryptographically secure values
	mt_rand(0,99); //Generater a better random integer

## pi

	echo M_PI; // 3.1415926535898

## base

	echo base_convert('4', 16, 2);//100

# XML
simpleXML

## load

	$xmlstr = <<<XML
	<?xml version='1.0' standalone='yes'?>
	<movies>
	 <movie>
	  <title>PHP: Behind the Parser</title>
	  <characters>
	   <character>
		<name>Ms. Coder</name>
		<actor>Onlivia Actora</actor>
	   </character>
	   <character>
		<name>Mr. Coder</name>
		<actor>El Act&#211;r</actor>
	   </character>
	  </characters>
	  <plot>
	   So, this language. It's like, a programming language. Or is it a
	   scripting language? All is revealed in this thrilling horror spoof
	   of a documentary.
	  </plot>
	  <great-lines>
	   <line>PHP solves all my web problems</line>
	  </great-lines>
	  <rating type="thumbs">7</rating>
	  <rating type="stars">5</rating>
	 </movie>
	</movies>
	XML;

### loadStr

	$movies = new SimpleXMLElement($xmlstr);
	//or $movies = simplexml_load_string($xmlstr);

### loadDom

	$dom = new DOMDocument;
	$dom->loadXML('<books><book><title>blah</title></book></books>');
	if (!$dom) {
		echo 'Error while parsing the document';
		exit;
	}

	$books = simplexml_import_dom($dom);

	echo $books->book[0]->title;

### asXML

	echo $movies->asXML();

## Operation

### get

	echo $movies->movie[0]->plot;

### exist

	isset($movies->movie);

### add

	include 'example.php';
	$movies = new SimpleXMLElement($xmlstr);

	$character = $movies->movie[0]->characters->addChild('character');
	$character->addChild('name', 'Mr. Parser');
	$character->addChild('actor', 'John Doe');

	$rating = $movies->movie[0]->addChild('key', 'val');
	$rating->addAttribute('type', 'mpaa');


### foreach

	foreach($movies as $k => $movie){
		echo $movie->title;
	}
	foreach($movies->children() as $k => $movie){
		echo $movie->title;
	}

# and or

	php > echo 65 & 63;
	1
	php > echo 66 & 63;
	2
	php > echo 127 & 63;
	63

# i18n(gettext)

	setlocale(LC_ALL, 'en_US');

	//locate language file
	bindtextdomain('messages', '/usr/local/locale/')
		//locale/en_US/LC_MESSAGES
	//locate messages in en_US(MESSAGES)
	textdomain('messages');

	//create text file: messages.po
	$ xgettext -n *.php
	//create binary file: messages.mo
	$ msgfmt messages.po

	//translate
	gettext('hello')

# network

## curl
Refer to [php-curl](https://github.com/ahui132/php-lib)

## headers

### getheader

	getallheaders();

## dns

	checkdnsrr($domain) && print "domain exists!" ;
	//获取dns信息
	print_r(dns_get_record('baidu.com'));
	//获取mx信息(mail exchange 记录)
	getmxrr('baidu.com', $info); print_r($info);

## service

	//get port
	echo getservbyname($service = 'http', $protocol = 'tcp');//service 必须是/etc/services中
	//get service name
	echo getservbyport($port = 80, 'tcp');

## socket

	$http = fsockopen('baidu.com', 80[, $errno, $err, $timeout]);
	fputs($http, $header = "GET /1.1\r\nConnection: Close\r\n\r\n");
	while(!feof($http)) $res = fgets($http, 1024);

## mail

	mail($to, $subject, $message[, $header = "From: test@ahui132.github.io\r\n"]);
	cat php.ini
		sendmail_from = string
		sendmail_path = String 默认为系统sendmail的路径
		smtp_port = 25(default)

## ip

	ip2long('0.0.1.1');//257
	long2ip

# shutdown

	register_shutdown_function($callback);

## fastcgi
> http://stackoverflow.com/questions/4806637/continue-processing-after-closing-connection

If running under fastcgi you can use the very nifty:

	fastcgi_finish_request();

This allows for time consuming tasks to be performed without leaving the connection to the client open.

> http://www.laruence.com/2008/04/16/98.html

## client abort
`php.ini`:

	ignore_user_abort False;" by default. If changed to TRUE scripts will not be terminated after a client has aborted their connection.

In php running:

	ignore_user_abort();

使用nginx的童鞋注意:

	fastcgi_ignore_client_abort on; // 客户端主动断掉连接之后，Nginx 会等待后端处理完(或者超时);


# php package manager
目前主要有两个PHP包管理系统：Composer和PEAR

- 管理单个项目的依赖时使用Composer
- 管理整个系统的PHP依赖时使用PEAR
- pecl 安装扩展: $ pecl install extname

## pecl
pecl(PHP Extension Library) 是一个扩展库，也是一个扩展安装命令

pecl 只能用于扩展的安装

	$ yum install php-devel
	$ pacman -S php-pear

用法：

	$ pecl install extname
	相当于：
	$ cd extname && phpize && ./configure && make && make install

## pear

- PEAR installs packages globally
- PEAR 打包规则严格 不自由

### install pear

	curl http://pear.php.net/go-pear | php

pear(Php Extension and Aplication Repository) 好像没有composer 流行

	pear list
	pear help
	pear instal package

### Handling PEAR dependencies with Composer
> http://www.phptherightway.com/

If you are already using Composer and you would like to install some PEAR code too, you can use Composer to handle your PEAR dependencies.

This example will install code from pear2.php.net:

	{
		"repositories": [
			{
				"type": "pear",
				"url": "http://pear2.php.net"
			}
		],
		"require": {
			"pear-pear2/PEAR2_Text_Markdown": "*",
			"pear-pear2/PEAR2_HTTP_Request": "*"
		}
	}

The first section `"repositories"` will be used to let Composer know it should “initialize” (or “discover” in PEAR terminology) the pear repo. Then the require section will prefix the package name like this:

	pear-channel/Package

The “pear” prefix is hardcoded to avoid any conflicts, as a pear channel could be the same as another packages vendor name for example, then the channel short name (or full URL) can be used to reference which channel the package is in.

When this code is installed it will be available in your vendor directory and automatically available through the Composer autoloader:

	vendor/pear-pear2.php.net/PEAR2_HTTP_Request/pear2/HTTP/Request.php

To use this PEAR package simply reference it like so:

	<?php
	$request = new pear2\HTTP\Request();

# Interface

	interface a {
		public function foo();//相当于 abstract public function foo();
	}

	interface b extends a {
		public function baz(Baz $baz, array $c = []);//相于abstract 原型
	}

	class c implements b {
		public function foo() { }
		abstract public function foo();//false, 只有abstract class 才允许abstract function
		protected function foo() {}; //Access level must be public 这是父级决定的

		public function baz(Baz $baz, $c) { }			//error
		public function baz(Baz $baz, array $c) { }		//error
		public function baz(Baz $baz, array $c = []) { }//ok
		public function baz(Baz $baz, array $c = [1]) { }//ok
	}
	new c;
	abstract class c implements b {
		abstract public function foo();//ok
	}

> 子类不可改变父类的 public/protected/privated 的access level, 也不可以改变参数的数据类型(子类型也不行)

> extends/implements 所继承的类或接口，必须先定义后使用. 它本身的定义也需要先定义再使用
否则编译器会报错

# Extension
http://php.net/manual/en/refs.basic.other.php

## Tokenizer
http://php.net/manual/en/book.tokenizer.php

## APCu & Memcached (对象缓存)
APCu 在单机性能上比 Memacached 高，但是它不能跨进程，更不到跨机器

> Note that when running PHP as a (Fast-)CGI application inside your webserver, every PHP process will have its own cache, i.e. APCu data is not shared between your worker processes. In these cases, you might want to consider using memcached instead, as it’s not tied to the PHP processes.

	apc_fetch('key');
	apc_add('key', $data);

在php5.5 之前APC 作为扩展时，即提供opcode 字节码缓存，又提供对象缓存。
但是php5.5 之后集成了字节码缓存组件OPcache, APC 的对象缓存部分被单独提出来了，叫做APCu

## SPL(Standard PHP Library)
标准库是php 自带的extension `php -m | grep SPL`，它提供了：常用的数据结构如栈，队列，堆, 数组, 以及这些数据结构的迭代器。如果需要还可自己扩展这些SPL

Refer to [](/p/php-spl)

## Taint
It is used for detecting XSS codes(tainted string). And also can be used to spot sql injection vulnerabilities, and shell inject, etc.

## Other Extension
V8js,Yaf,
GeoIP — Geo IP Location
Yaml — YAML Data Serialization
