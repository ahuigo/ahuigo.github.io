---
layout: page
title:	
category: blog
description: 
---
# Preface

# hello world

	git clone git@github.com:laruence/yaf.git
	cd yaf/tools/cg/
	php yaf_cg Sample
	mv output/Sample ~/www/yaf_php

# config

## php.ini
yaf 全局配置：

	yaf.environ	product	PHP_INI_ALL	环境名称, 当用INI作为Yaf的配置文件时, 这个指明了Yaf将要在INI配置中读取的节的名字
	yaf.library	NULL	PHP_INI_ALL	全局类库的目录路径(多个项目的公用库目录)
	yaf.cache_config	0	PHP_INI_SYSTEM	是否缓存配置文件(只针对INI配置文件生效), 打开此选项可在复杂配置的情况下提高性能
	yaf.name_suffix	1	PHP_INI_ALL	在处理Controller, Action, Plugin, Model的时候, 类名中关键信息是否是后缀式, 比如UserModel, 而在前缀模式下则是ModelUser
	yaf.name_separator	""	PHP_INI_ALL	在处理Controller, Action, Plugin, Model的时候, 前缀和名字之间的分隔符, 默认为空, 也就是UserPlugin, 加入设置为"_", 则判断的依据就会变成:"User_Plugin", 这个主要是为了兼容ST已有的命名规范
	yaf.forward_limit	5	PHP_INI_ALL	forward最大嵌套深度
	yaf.use_namespace	0	PHP_INI_SYSTEM	开启的情况下, Yaf将会使用命名空间方式注册自己的类, 比如Yaf_Application将会变成Yaf\Application
	yaf.use_spl_autoload	0	PHP_INI_ALL	开启的情况下, Yaf在加载不成功的情况下, 会继续让PHP的自动加载函数加载, 从性能考虑, 除非特殊情况, 否则保持这个选项关闭
	action_prefer	off	PHP_INI_ALL URI 结尾是否为action
	


## application/conf

	$app  = new Yaf_Application(APP_PATH . "/conf/application.ini");
	$app  = new Yaf_Application(APP_PATH . "/conf/application.ini", ini_get('yaf.environ'));

### application.ini
yaf 项目自身配置

	[yaf]
	名称	值类型	默认值	说明
	application.directory=/usr/
	application.ext	String	php	PHP脚本的扩展名
	application.bootstrap	String	Bootstrap.php	Bootstrap路径(绝对路径)
		define('APPLICATION_PATH', ROOT_PATH . '/application');
		define('BOOTSTRAP_PATH', ROOT_PATH . '/application/Bootstrap.php');
	application.library	String	application.directory + "/library"	本地(自身)类库的绝对目录地址
	application.baseUri	String	NULL	在路由中, 需要忽略的路径前缀, 一般不需要设置, Yaf会自动判断.
	application.dispatcher.defaultModule	String	index	默认的模块
	application.dispatcher.throwException	Bool	True	在出错的时候, 是否抛出异常
	application.dispatcher.catchException	Bool	False	是否使用默认的异常捕获Controller, 如果开启, 在有未捕获的异常的时候, 控制权会交给ErrorController的errorAction方法, 可以通过$request->getException()获得此异常对象
	application.dispatcher.defaultController	String	index	默认的控制器
	application.dispatcher.defaultAction	String	index	默认的动作
	
	application.view.ext	String	phtml	视图模板扩展名
	application.modules	String	Index	声明存在的模块名, 请注意, 如果你要定义这个值, 一定要定义Index Module
	application.system.*	String	*	通过这个属性, 可以修改yaf的runtime configure, 比如application.system.lowcase_path, 但是请注意只有PHP_INI_ALL的配置项才可以在这里被修改, 此选项从2.2.0开始引入

Example:

	[yaf]
	; 通用配置
	db.msyql.host = '1.1.1.1'
	 
	[product:yaf]
	; 生产环境配置
	 
	[test:yaf]
	; 测试环境配置
	 
	[test1:test]
	; test1 继承test

php.ini 中:

	yaf.environ=product

通过设置运行环境，在项目中可以通过`ini_get(‘yaf.environ’)` 获取环境参数，进而取到相应节的配置。

	$app  = new Yaf_Application(APP_PATH . "/conf/application.ini", ini_get('yaf.environ'));
	\Yaf\Application::app()->getConfig();

获取自定义的ini:

	$config = new \Yaf\Config\Ini(APPLICATION_PATH . '/conf/url.ini', ini_get('yaf.environ'));

#### view

	application.view.ext	String	phtml	视图模板扩展名
	application.modules	String	Index	声明存在的模块名, 请注意, 如果你要定义这个值, 一定要定义Index Module
	application.system.*	String	*	通过这个属性, 可以修改yaf的runtime configure, 比如application.system.lowcase_path, 但是请注意只有PHP_INI_ALL的配置项才可以在这里被修改, 此选项从2.2.0开始引入


# 加载顺序
index.php 

	$app = new Yaf_Application('conf/app.ini') //set application.directory=APPLICATION_PATH
		init
	$app ->bootstrap() ->run();
		routerStartup	
			router
		routerShutdown	
		dispatchLoopStarup
		preDispatch	
			dispath
		postDispatch	
		dispatchLoopShutdown
		
## autoload 自动加载器
Yaf在自启动的时候, 会通过SPL注册一个自己的Autoloader

### dispatcher

	Yaf_Dispatcher::getInstance()->getRequest()->getControllerName()

### Controller/Model/Plugin 的自动加类
它们依赖后缀

表 5.1. Yaf目录映射规则

	类型	后缀(或者前缀, 可以通过php.ini中ap.name_suffix来切换)	映射路径
	控制器	Controller	默认模块下为{项目路径}/controllers/, 否则为{项目路径}/modules/{模块名}/controllers/
	数据模型Model	{项目路径}/models/
	插件	Plugin	{项目路径}/plugins/

### 全局类和本地类的加载

	//自动查找本地类（放在 _initLoder()), 需要用registerLocalNameSpace 申明本地类的前缀
	Yaf_Loader::getInstance()->registerLocalNameSpace(array('Comm','Page'))

Example:

	//在没有申明本地类的情况下: 访问Foo_Dummy_Bar
	{php.ini中的ap.library}/Foo/Dummy/Bar.php

	// 用Loader->registerLocalNameSpace 申请了本地类前缀: 访问Comm_Func
	application.ini中指定的ap.library)}/Comm/Func.php
	

> 在yaf.use_spl_autoload关闭的情况下, Yaf Autoloader在一次找不到的情况下, 会立即返回, 而剥夺其后的自动加载器的执行机会.

## Bootstrap
实例化成功之后, 所有在Bootstrap类中定义的, 以_init开头的方法, 都会被依次调用

	/**
	 * 所有在Bootstrap类中, 以_init开头的方法, 都会被Yaf调用,
	 * 这些方法, 都接受一个参数:Yaf_Dispatcher $dispatcher
	 * 调用的次序, 和申明的次序相同
	 */
	class Bootstrap extends Yaf_Bootstrap_Abstract{
		public function _initConfig() {
			$config = Yaf_Application::app()->getConfig();
			Yaf_Registry::set("config", $config);
		}

		public function _initDefaultName(Yaf_Dispatcher $dispatcher) {
			$dispatcher->setDefaultModule("Index")->setDefaultController("Index")->setDefaultAction("index");
		}
	}

## Plugin
Yaf支持用户定义插件来扩展Yaf的功能, 这些插件都是一些类. 它们都必须继承自Yaf_Plugin_Abstract. 插件要发挥功效, 也必须现实的在Yaf中进行注册, 然后在适当的实际, Yaf就会调用它.

Yaf定义了6个Hook, 它们分别是:

	触发顺序	名称	触发时机	说明
	1	routerStartup	在路由之前触发	这个是7个事件中, 最早的一个. 但是一些全局自定的工作, 还是应该放在Bootstrap中去完成
	2	routerShutdown	路由结束之后触发	此时路由一定正确完成, 否则这个事件不会触发
	3	dispatchLoopStartup	分发循环开始之前被触发	 
	4	preDispatch	分发之前触发	如果在一个请求处理过程中, 发生了forward, 则这个事件会被触发多次
	5	postDispatch	分发结束之后触发	此时动作已经执行结束, 视图也已经渲染完成. 和preDispatch类似, 此事件也可能触发多次
	6	dispatchLoopShutdown	分发循环结束之后触发	此时表示所有的业务逻辑都已经运行完成, 但是响应还没有发送

Example: 定义插件

     class RouterPlugin extends Yaf_Plugin_Abstract {
		 public function routerStartup(Yaf_Request_Abstract $request, Yaf_Response_Abstract $response) {
		 }

		 public function routerShutdown(Yaf_Request_Abstract $request, Yaf_Response_Abstract $response) {
		 }
     }

注册插件：

	//in Bootstrap
	public function _initPlugin(Yaf_Dispatcher $dispatcher) {
        $dispatcher->registerPlugin(new RouterPlugin());
    }

# Router
Yaf 支持一个固定不变的路由器, 配合各种可自定义的路由协议, 来实现灵活多变的路由策略.
路由组件有两个部分：一个路由器(Yaf_Router)和一个或者多个路由协议(Yaf_Route_Abstract)

路由器主要负责管理和运行路由链,它根据路由协议栈倒序依次调用各个路由协议, 一直到某一个路由协议返回成功以后, 就匹配成功.

> 路由是按注册的顺序的倒序执行匹配的, 最后注册的路由协议, 最先尝试路由, 这就有个陷阱. 请注意.

1. 路由的过程发生派遣过程的最开始, 并且路由解析仅仅发生一次.  路由过程在控制器动作(Controller, Action)被派遣之前被执行
2. 一旦路由成功,路由器将会把解析出得到的信息传递给请求对象(Yaf_Request_Abstract object), 这些信息包括moduel、controller、action、用户params等. 
3. 然后派遣器(Yaf_Dispatcher)就会按照这些信息派遣正确的控制器动作. 
4. 路由器也有插件钩子,就是routerStartup和routerShutdown,他们在路由解析前后分别被调用.

## 路由器
Yaf_Router 是默认的路由器
默认使用的路由协议是Yaf_Route_Static,是基于HTTP路由的, 它期望一个请求是HTTP请求并且请求对象是使用Yaf_Request_Http

首先让我们来看看路由器是如何让路由协议与之一起工作的. 

1. 在我们添加任何路由协议之前我们必须要得到一个路由器(Yaf_Router)实例, 我们通过派遣器的getRouter方法来得到默认的路由器：

	<?php
     //通过派遣器得到默认的路由器
     $router = Yaf_Dispatcher::getInstance()->getRouter();

2. 添加自定义路由协议

	<?php
	$router->addRoute('myRoute', $route);
	$router->addRoute('myRoute1',$route)

除此方法外，还可以通过配置直接添加路由协议:

	[common]
     ;自定义路由
     ;顺序很重要
     routes.regex.type="regex"
     routes.regex.match="#^/list/([^/]*)/([^/]*)#"
     routes.regex.route.controller=Index
     routes.regex.route.action=action
     routes.regex.map.1=name
     routes.regex.map.2=value
     ;添加一个名为simple的路由协议
     routes.simple.type="simple"
     routes.simple.controller=c
     routes.simple.module=m
     routes.simple.action=a
     ;添加一个名为supervar的路由协议
     routes.supervar.type="supervar"
     routes.supervar.varname=r

     [product : common]
     ;product节是Yaf默认关心的节, 添加一个名为rewrite的路由协议
     routes.rewrite.type="rewrite"
     routes.rewrite.match="/product/:name/:value"

然后在Bootstrap中通过调用Yaf_Router::addConfig添加定义在配置中的路由协议

	class Bootstrap extends Yaf_Bootstrap_Abstract{
		public function _initRoute(Yaf_Dispatcher $dispatcher) {
			$router = Yaf_Dispatcher::getInstance()->getRouter();
			/**
			 * 添加配置中的路由
			 */
			 $router->addConfig(Yaf_Registry::get("config")->routes);
		}
	}

路由器也提供给我们不同的方法来得到和设置包含在它内部的信息, Refer http://php.net/manual/en/class.yaf-router.php

    $Router->getCurrentRoute(void) //在路由结束以后, 获取起作用的路由协议 Get the name of the route which is effective in the route process.
    $Router->getRoute($name)//Retrieve a route by name 
	$Router->getRoutes(void);//Retrieve registered routes

## 路由协议

### Yaf_Route_Static
默认使用的路由协议是Yaf_Route_Static, 它期望一个请求是HTTP请求并且请求对象是使用Yaf_Request_Http

就是分析请求中的request_uri, 在去除掉baseUri以后, 获取到真正的负载路由信息的request_uri片段

具体的策略是:

1. 根据"/"对request_uri分段, 依次得到Module,Controller,Action, 
2. 在得到Module以后, 还需要根据Yaf_Application::$modules来判断Module是否是合法的Module
3. 如果不是, 则认为Module并没有体现在request_uri中, 而把原Module当做Controller, 原Controller当做Action:

	<?php
     /**
      * 对于请求request_uri为"/ap/foo/bar/dummy/1"
      * base_uri为"/ap"
      * 则最后参加路由的request_uri为"/foo/bar/dummy/1"
      * 然后, 通过对URL分段, 得到如下分节
      * foo, bar, dummy, 1
      * 然后判断foo是不是一个合法的Module, 如果不是, 则认为结果如下:
      */
      array(
        'module'     => '默认模块',
        'controller' => 'foo',
        'action'     => 'bar',
        'params'     => array(
             'dummy' => 1,
        )
     )

     /**
      * 而如果在配置文件中定义了ap.modules="Index,Foo",
      * 则此处就会认为foo是一个合法模块, 则结果如下
      */
      array(
        'module'     => 'foo',
        'controller' => 'bar',
        'action'     => 'dummy',
        'params'     => array(
             1 => NULL,
        )
     )

> 只有一段路由信息的时候, 比如对于上面的例子, 请求的URI为/ap/foo, 则默认路由和下面要提到的Yaf_Route_Supervar会首先判断ap.action_prefer, 如果为真, 则把foo当做Action, 否则当做Controller

### Yaf_Route_Simple
Yaf_Route_Simple是基于请求中的query string来做路由的, 在初始化一个Yaf_Route_Simple路由协议的时候, 我们需要给出3个参数, 这3个参数分别代表在query string中Module, Controller, Action的变量名:

     <?php
     /**
      * 指定3个变量名
      */
      $route = new Yaf_Route_Simple("m", "c", "a");
      $router->addRoute("name", $route);
     /**
      * 对于如下请求: "http://domain.com/index.php?c=index&a=test
      * 能得到如下路由结果
      */
      array(
        'module'     => '默认模块',
        'controller' => 'index',
        'action'     => 'test',
        )


>注意, 只有在query string中不包含任何3个参数之一的情况下, Yaf_Route_Simple才会返回失败, 将路由权交给下一个路由协议.

### Yaf_Route_Supervar
Yaf_Route_Supervar和Yaf_Route_Simple相似, 都是在query string中获取路由信息, 不同的是, 它获取的是一个类似包含整个路由信息的request_uri

     <?php
     /**
     * 指定supervar变量名
     */
     $route = new Yaf_Route_Supervar("r");
     $router->addRoute("name", $route);
     /**
     * 对于如下请求: "http://domain.com/index.php?r=/a/b/c
     * 能得到如下路由结果
     */
     array(
     'module'     => 'a',
     'controller' => 'b',
     'action'     => 'c',
     )


> 注意 在query string中不包含supervar变量的时候, Yaf_Route_Supervar会返回失败, 将路由权交给下一个路由协议.

### Yaf_Route_Map
Yaf_Route_Map 路由协议是一种简单的路由协议, 它将REQUEST_URI中以'/'分割的节, 组合在一起, 形成一个分层的控制器或者动作的路由结果.

Yaf_Route_Map的构造函数接受俩个参数:

1. 第一个参数表示路由结果是作为动作的路由结果,还是控制器的路由结果. 默认的是动作路由结果. 
2. 第二个参数是一个字符串, 表示一个分隔符, 如果设置了这个分隔符, 那么在REQUEST_URI中, 分隔符之前的作为路由信息载体, 而之后的作为请求参数.

	<?php
	/**
	* 对于请求request_uri为"/ap/foo/bar"
	* base_uri为"/ap"
	* 则最后参加路由的request_uri为"/foo/bar"
	* 然后, 通过对URL分段, 得到如下分节
	* foo, bar
	* 组合在一起以后, 得到路由结果foo_bar
	* 然后根据在构造Yaf_Route_Map的时候, 是否指明了控制器优先,
	* 如果没有, 则把结果当做是动作的路由结果
	* 否则, 则认为是控制器的路由结果
	* 默认的, 控制器优先为FALSE
	*/
     $route = new Yaf_Route_Map($controller_prefer = false);

Refer to http://php.net/manual/en/class.yaf-route-map.php

	//delimiter=?
	string(%d) "/foo/bar?tkey1=tval1&tkey2=tval2"
	//delimiter=_
	string(%d) "/foo/bar/_/tkey1/tval1/tkey2/tval2"

### Yaf_Route_Rewrite
Yaf_Route_Rewrite是一个强大的路由协议, 它能满足我们绝大部分的路由需求:

     <?php
     //创建一个路由协议实例
     $route = new Yaf_Route_Rewrite(
     　　'product/:ident',
     　　array(
     　　　　'controller' => 'products',
     　　　　'action' => 'view'
     　　)
     );
     //使用路由器装载路由协议
     $router->addRoute('product', $route);

在这个例子中, 我们试图匹配Url指定到一个单一的产品, 就像http://domain.com/product/choclolat-bar. 

为了实现这点, 我们在路由协议中传递了2个变量到路由协议Yaf_Route_Rewrite的构造函数其中. 

1. 第一个变量('product/:indent')就是匹配的路径, 
2. 第二个变量(array变量)是路由到的动作控制器； 
3. 路径使用一个特别的标识来告诉路由协议如何匹配到路径中的每一个段,这个标识有有两种,可以帮助我们创建我们的路由协议,如下所示

	a) :
	b) *

冒号(:)指定了一个段,这个段包含一个变量用于传递到我们动作控制器中的变量,我们要设置好事先的变量名,比如在上面我们的变量名就是'ident',因此,倘若我们访问http://domian.com/product/chocoloate-bar将会创建一个变量名为ident并且其值是'chocoloate-bar'的变量,我们然后就可以在我们的动作控制器ProductsController/viewAction下获取到它的值：$this->getRequest()->getParam('ident');

星号(*)被用做一个通配符, 意思就是在Url中它后面的所有段都将作为一个通配数据被存储. 例如,如果我们有路径'path/product/:ident/*, 并且我们访问的Url为http://domain.com/product/chocolate-bar/test/value1/another/value2,那么所有的在'chocolate-bar'后面的段都将被做成变量名/值对,因此这样会给我们下面的结果：

    
    ident = chocolate-bar
    test = value1
    another = value2

这种行为也就是我们平常默认使用的路由协议的行为, 记住变量名/值要成对出现,否则像/test/value1/这样的将不会这种另一个变量,
我们有静态的路由协议部分,这些部分简单地被匹配来满足我们的路由协议,在我们的例子中,静态部分就是product；

### Yaf_Route_Regex
到目前为止,我们之前的路由协议都很好的完成了基本的路由操作,我们常用的也是他们,然而它们会有一些限制,这就是我们为什么要引进正则路由(Yaf_Route_Regex)的原因. 正则路由给予我们preg正则的全部力量,但同时也使得我们的路由协议变得更加复杂了一些.即使是他们有点复杂,我还是希望你能好好掌握它,因为它比其他路由协议要灵活一点点. 一开始,我们先对之前的产品案例改用使用正则路由：

	<?php
	$route = new Yaf_Route_Regex(
	　　'product/([a-zA-Z-_0-9]+)',
	　　array(
	　　　　　　'controller' => 'products',
	　　　　　　'action' => 'view'
	　　)
	);
	$router->addRoute('product', $route);

你可以看到,我们现在移动我们的正则到我们的path(构造函数的第一个参数)中来了. 这个正则没有批定 ident变量名？但是我们可以通过变量1(one)来获取其值,即可以在控制器里用:$this->getRequest()->getParam(1)来获取,

如果需要指定变量名indent:

	<?php
	$route = new Yaf_Route_Regex(
	　　'product/([a-zA-Z-_0-9]+)',
	　　array(
	　　　　'controller' => 'products',
	　　　　'action' => 'view'
	　　),
	　　array(
	　　　　//完成数字到字符变量的映射
	　　　　1 => 'ident'
	　　)
	);
	$router->addRoute('product', $route);

这样,我们就简单的将变量1映射到了ident变量名,这样就设置了ident变量,同时你也可以在控制器里面获取到它的值.

### 自定义路由协议
你可以自己实现你自己的路由协议, 你要做的是, 申明你的路由协议实现了Yaf_Route_Interface接口即可.

	class Route_Base implements Yaf_Route_Interface{
		public function route ( $request ){
			$request->setControllerName('upperCamel_upperCamel');//寻址:Uppercamel/Uppercamel.php
			$request->setControllerName('upperCamel/LoWer/LoWer');//寻址:Uppercamel/lower/lower.php, 它是以下划线做的切割！
			return true;//true 时不再进行下一次匹配
		}
		public function assemble(array $info, array $query = []){ }
	}

# Request

	$request = Yaf_Dispatcher::getInstance()->getRequest();
	$request->getControllerName();
	$request->getActionName();
	$request->setControllerName('Login_Tb');
	$request->setActionName('add');

# Error & Exception

## Exception 异常
在application.dispatcher.catchException(配置文件, 或者可通过Yaf_Dispatcher::catchException(true))开启的情况下, 

1. 当Yaf遇到未捕获异常的时候, 就会把运行权限, 交给当前模块的Error Controller的Error Action动作, 而异常或作为请求的一个参数, 传递给Error Action.

2. 在Error Action中可以通过`$request->getRequest()->getParam("exception")`获取当前发生的异常.

3. 从Yaf1.0.0.12开始, 也可以通过`$request->getException()`来获取当前发生的异常, 而如果Error Action定义了一个名为$e 的参数的话, 也可以直接通过这个参数获取当前发生的异常.

### 捕获错误异常

	/**
	 * 当有未捕获的异常, 则控制流会流到这里
	 */
	class ErrorController extends Yaf_Controller_Abstract {
		 /**
		  * 也可通过$request->getException()获取到发生的异常
		  */
		public function errorAction($exception) {
			assert($exception === $exception->getCode());
			$this->getView()->assign("code", $exception->getCode());
			$this->getView()->assign("message", $exception->getMessage());
		}
	}

> yaf 老版本的异常类存在一些bug：errorAction($exception) 必须写`$exception`, 否则可能捕获不了异常；而且不能 throw $exception，在xdebug 开启的情况下会导致fpm 死掉

通过异常类型处理

	 public function errorAction() {
	  $exception = $this->getRequest()->getException();
	  try {
		throw $exception;
	  } catch (Yaf_Exception_LoadFailed $e) {
		//加载失败
	  } catch (Yaf_Exception $e) {
		//其他错误
	  }

通过异常code处理:

	 switch($exception->getCode()) {
		  case YAF_ERR_LOADFAILD:
		  case YAF_ERR_LOADFAILD_MODULE:
		  case YAF_ERR_LOADFAILD_CONTROLLER:
		  case YAF_ERR_LOADFAILD_ACTION:
		  //404
		  header("Not Found");
		  break;

		  case CUSTOM_ERROR_CODE:
		  ....
		  break;
	  }

# Yaf_Request

	$uri = $request->getRequestUri();
	->setRequestUri()
	->setControllerName('A_B_C')

# View

## Template

    $this->getView()->assign("var", "value");
    $this->getView()->var = 'value';
    $this->getView()->assignRef("_view_obj", $view);

## display

	$this->getView()->display('h5/index/index.phtml', ['var'=>$value]);
	echo $this->getView()->render('h5/index/index.phtml', ['var'=>$value]);
	$this->getView()->eval( string $tpl_content [, array $tpl_vars ] )

`controller->display` 的原型会自动对 $tpl 加".phtml", 而view 的display 则不会:

    protected function display($tpl, array $tpl_vars = []) {
        $this->getView()->display($tpl, $tpl_vars);
    }

## view path
多种方法

	$dispatcher->initView( ROOT_PATH.'/views' );
	$view->setScriptPath ( $template_dir )
	//只适用于控制器自身的View
	$controller->setViewPath('ViewPath');

## disable view
1. 需要在action 中`return false`
2. 

	Yaf_Dispatcher::getInstance()->disableView();

