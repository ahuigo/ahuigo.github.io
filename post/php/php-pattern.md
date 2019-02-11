---
layout: page
title:	设计模式
category: blog
description:
---
# Preface


# composer Pattern
聚合（空心菱形）：schoolClass 可以包含多个Pupil(聚合Pupil)
组合模式(实心菱形): 是聚合组件,组件不可被其它类包含
装饰器模式: 是改变组件

多个`Unit $o` 组合在一起， 比如员工\学生

    function addUnit(Unit $o){
        $this->os[] = $o;
    }

# Decorator Pattern, 装饰器模式
类似python, 不改变原类本身:
装饰器模式不修改原类, 也不增加新类, 需要通过组合模式, 传入两种类

	// 区域抽象类
	abstract class Area {
	    abstract public function treasure();
	}

	//森林类，价值100
	class Forest extends Area {
	    public function treasure() {
	        return 100;
	    }
	}
	//沙漠类，价值10
	class Desert extends Area {
	    function function treasure() {
	        return 10;
	    }
	}
	//区域类的装饰器类
	abstract class AreaDecorator extends Area {
	    protected $_area = null;

	    public function __construct(Area $area) {
	        $this->_area = $area;
	    }
	}

	//被破坏了后的区域，价值只有之前的一半
	class Damaged extends AreaDecorator {
	    public function treasure() {
	        return $this->_area->treasure() * 0.5;
	    }
	}

	//现在我们来获取被破坏的森林类的价值
	$damageForest = new Damaged(new Forest());
	echo $damageForest->treasure();  //返回50

# Factory Pattern, 工厂模式
1. 工厂: 生成对象, 需要判断不同类型
1. 抽象工厂: 子类工厂生成对象, 不需要判断不同类型, 直接指定不同子类名
1. 原型模式: 事先在参数中传入对象, 然后通过return clone $obj 返回对象

单例就是一种特殊的工厂模式

	interface IUser {
	  function getName();
	}

	class User implements IUser {
	  public function __construct( $id ) { }

	  public function getName() {
		return "Jack";
	  }

	  public static function Create( $id ) {
		return new User( $id );
	  }
	}

	class UserFactory {
	  public static function Create( $id ) {
		return new User( $id );
	  }
	}

	$uo = UserFactory::Create( 1 );
	//$uo = User::Create( 1 );
	echo( $uo->getName()."\n" );

# 执行任务及描述任务

## 解释器模式
通过子类一层一层去解释剖析问题
![php-pattern-1.png](/img/php-pattern-interpret.png)

## Strategy Pattern, 策略模式
问题：为了解决多种策略组合的问题（组合优于继承）
下例中，通过使用策略模式，可将`过滤部分`放入另一个类中，而不影响用户列表中的其余代码。

	class FindAfterStrategy implements IStrategy {
	  private $_name;

	  public function __construct( $name ) {
		$this->_name = $name;
	  }

	  public function filter( $record ) {
		return strcmp( $this->_name, $record ) <= 0;
	  }
	}

	class RandomStrategy implements IStrategy {
	  public function filter( $record ) {
		return rand( 0, 1 ) >= 0.5;
	  }
	}

	class UserList {
	  private $_list = array();

	  public function __construct( $names ) {
		if ( $names != null ) {
		  foreach( $names as $name ) {
			$this->_list []= $name;
		  }
		}
	  }

	  public function add( $name ) {
		$this->_list []= $name;
	  }

	  public function find( $filter ) {
		$recs = array();
		foreach( $this->_list as $user ) {
		  if ( $filter->filter( $user ) )
			$recs []= $user;
		}
		return $recs;
	  }
	}

	$ul = new UserList( array( "Andy", "Jack", "Lori", "Megan" ) );
	$f1 = $ul->find( new FindAfterStrategy( "J" ) );
	print_r( $f1 );

    //加入特定的策略
	$f2 = $ul->find( new RandomStrategy() );
	print_r( $f2 );

策略模式优化的是大量的if-elseif


## Observer Pattern, 观察者模式
问题：为了避免类太臃肿，将元素剥离主体！(正交原则，降低耦合)

观察者模式为您提供了避免组件之间紧密耦合的另一种方法。该模式非常简单：
1. 一个对象通过添加一个方法（该方法允许另一个对象，即观察者 注册自己）使本身变得可观察。
2. 当可观察的对象更改时，它会将消息发送到已注册的观察者。
3. 这些观察者使用该信息执行的操作与可观察的对象无关。结果是对象可以相互对话，而不必了解原因。

代码显示一个用户列表，添加用户时，它将发送出一条消息。添加用户时，通过发送消息的日志观察者可以观察此列表。

    //被观察者
	class UserList implements IObservable {
	  private $_observers = array();

	  public function addCustomer( $name ) {
		foreach( $this->_observers as $obs )
		  $obs->onChanged( $this, $name );
	  }

	  public function attach( $observer ) {
		$this->_observers []= $observer;
	  }
	}

    //观察者
	class UserListLogger implements IObserver {
	  public function onChanged( $sender, $args ) {
		echo( "'$args' added to user list\n" );
	  }
	}

	$ul = new UserList();

    //加入观察者(可以是多个)
	$ul->attach( new UserListLogger() );
	$ul->addCustomer("Jack");

### SPL 提供的观察者模式
SplSubject(Obervalbe) 与

    class Login implements SplSubject{
        function __construct(){
            $this->storage = new SplObjectStorage();
        }

        function attach(SplObserver $observer){
            $this->storage->attach($observer);
        }
        function detach(SplObserver $observer){
            $this->storage->detach($observer);
        }
        function notify(){
            foreach($this->storage as $observer){}
            $observer->update($this);
        }
    }
    abstract class LoginObserver implements SplObserver{
        function __construct(Login $login){
            $this->login = $login;
            $login->attach($this);
        }
        function update(SplSubject $subject){
            if($subject == $this->login){
                $this->doUpdate($subject);
            }
        }
        abstract function doUpdate(Login $login){}
    }

    $login = new Login;
    new LoginObserver($login);
    ...

## 访问者模式(visitor)
问题：“组合比继承更灵活”，但是你可能事先不知道新操作，每增加一个操作就在类中增加对新操作的组件，会让类变得臃肿。比如visit 操作
1. 在基类添加通用集大成的操作，比较臃肿
1. 在子类添加visit 操作，如果说我要统一visit点别的，要全部子类的visit要更新

访问者模式可以解决这个问题, 把visitor 解耦出来
在基类为visitor 预留一个调用入口accept

代码： https://github.com/ahuigo/php-lib/tree/master/pattern

    public function accept(Visitor $visitor) {
        $method = 'visit' . get_class($this);
        if (method_exists($visitor, $method)) {
            $visitor->$method($this);
        }
    }


# CommandChain Pattern, 命令链模式
命令链 模式以松散耦合主题为基础，发送消息、命令和请求，或通过一组处理程序发送任意内容。
1. 每个处理程序都会自行判断自己能否处理请求。如果可以，该请求被处理，进程停止。
2. 您可以为系统添加或移除处理程序，而不影响其他处理程序。

清单 5 显示了此模式的一个示例。

	class CommandChain {
	  private $_commands = array();

	  public function addCommand( $cmd ) {
		$this->_commands []= $cmd;
	  }

	  public function runCommand( $name, $args ) {
		foreach( $this->_commands as $cmd ) {
		  if ( $cmd->onCommand( $name, $args ) )
			return;
		}
	  }
	}

	class UserCommand implements ICommand {
	  public function onCommand( $name, $args ) {
		if ( $name != 'addUser' ) return false;
		echo( "UserCommand handling 'addUser'\n" );
		return true;
	  }
	}

	class MailCommand implements ICommand {
	  public function onCommand( $name, $args ) {
		if ( $name != 'mail' ) return false;
		echo( "MailCommand handling 'mail'\n" );
		return true;
	  }
	}

	$cc = new CommandChain();
	$cc->addCommand( new UserCommand() );
	$cc->addCommand( new MailCommand() );
	$cc->runCommand( 'addUser', null );
	$cc->runCommand( 'mail', null );

# 门面模式 Facade
比如去医院：挂号、看病、化验、取药... 自己一个一个去实现调用
Facade 模式：就只需要一个接待员，完成所有的调用

    function waiter(){
        register()
        doctor()
        ....
    }

# Reference
- [php-pattern]
- [pattern]

[php-pattern]: http://www.ibm.com/developerworks/cn/opensource/os-php-designptrns/
[pattern]: https://wizardforcel.gitbooks.io/w3school-design-patterns/content/17.html
