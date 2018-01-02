---
layout: page
title: intellij 使用简介
category: blog
description:
---
# Preface
在vim/netbeans中混迹了数年后，终于还是投奔到idea的门下了。原因：

- intellij idea 原生支持readline(emacs keymap)
- 足够的扩展性
- intellij 的设置窗口非常人性化: 一个`Cmd+,`就呼出来的，一目了然。
- vim 自身的历史遗留问题：map不支持<C-1>， <C-A-char> ,
- vim 不支持Gui 菜单
- 强悍的开发环境不存在IDE太慢的问题，再说了intellij 本性的性能就不错
- IDE更易学：几乎没有学习的时间成本

> 我并没有在intellij上吊死，写小文件和博客时，我就用vim, 现在也在深度用emacs.

## 360 server's certificate:
Accepted certificate will be saved in truststore with default password changeit:
	/Users/hilojack/Library/Caches/WebIde100/tasks/cacerts

# where is the plugin,cache store
https://www.jetbrains.com/phpstorm/help/directories-used-by-phpstorm-to-store-settings-caches-plugins-and-logs.html
Library//App

	Configuration
	~/Library/Preferences/<PRODUCT><VERSION>

	Caches
	~/Library/Caches/<PRODUCT><VERSION>

	Plugins
	~/Library/Application Support/<PRODUCT><VERSION>
	~/Library/Application\ Support/WebIde80/

	Logs
	~/Library/Logs/<PRODUCT><VERSION>

# preperty-read

经常用netbeans写代码，当一个项目的代码到达足够复杂时，手动去查找一个类是很麻烦的事儿。这时，netbeans的自动补全提供了很多便利。要让自动补全足够“智能”，你可能需要注释上进行一些认识。
现在我罗列下大家可能经常用到的一些doc注释.

1. 成员对象 启用预读

	classA.php:
	class ClassA{
	  public $var1;
	  function __construct(){
		****
	  }
	}

再建立一个classB.php：

	/**
	 * @property-read ClassA $objName // 方法一 启用对classA的预读
	 */
	class classB{
	 /**
	  * @var SDK\classA [$objName] //方法二 启用对classA的预读,成员对象是$objName（可忽略）
	  */
	  public $objName;
	  function __construct(){
		 $this->objName=new classA;
		 $this->objName-> //预读后，可以在这儿自动补全成员对象objName所含的成员了
	  }
	}

2.普通变量对象 启用预读
variable.php:

	/**
	 * @var $objName ClassA  //你用vdoc[tab]键 可以实现自动补全
	 */
	$objName=new ClassA;
	$objName-> //自动补全

3.指定预读属性
很多时候，我们不会显式的定义$var,比如使用__get()时，这个时候就加入$property注释吧

	classA.php:
	/**
	 * @property $varName //classA被预读时，属性$varName会被提示
	 */
	class ClassA{
	  public $var1;
	  function __construct(){
		****
	  }
	}

4.返回对象的预读

	class ClassA{
	/**
	 * @return ClassName
	 * @return static
	 * @return static object
	 */
	  static function __construct(){
		return self::$objName;
	  }
	}

# Definition

	Ctrl+Shift+I view definition

# java project

1. new project
2. java EE
3. sdk: /Library/Java/JavaVirtualMachines/jdk1.7.0_45.jdk or /System/Library/Java/JavaVirtualMachines/1.6.0.jdk/ or /Library/Java/Home(link)
4. in project structure
	Project: sdk 1.7 + out
	module:
		soruce tab:
			set source dir(src)
		dependence:
			add jar or Library(such as apache commons codec)

structure:

	/project
		/src
		/out
	/External Library
		sdk1.7
			*.jar # 基础的jar 包

## demo configuration

# Refactor
php提供了很强大的重构支持, `Ctrl+Shift+Alt+T` 即可弹出重构选项

## rename
选择任意一个变量/类名, 然后按`Shift+F6` 即可完成对其的重构

## change signature
如果你想为调整函数/方法的参数顺序，或者增加新的参数，那就可以在函数定义处按`Ctrl+F6`. 重构后，所有调用此函数的代码都会被同步更新（你可以在确认重构前点preview）.

# Terminal
	Alt+F12

# view

	alt+Shift+c recent changes
	Ctrl+Shift+E recent changed files

## theme主题

	Ctrl+`	 (view->switch scheme)

## tool windows

	alt+1  project
	alt+7  file struct (在nb中是command+7)
	Ctrl+F12 :  file struct (Float window)
	alt+9 changes
	alt+F12 terminal

## toolBar
你可以在这里点击“custom”

# Tools

## deployment 部署
deployment 可以通过 右键项目文件呼出(前提是你成功配置了ftp upload path)

### ftp
如果不能查看到Browse Remote Host , 可以试试将mode 改成passive mode


## use
打开ftp 目录：

	Tools->deployment->configruation->Browse Remote host 可打目录，支持拖放文件上传/下载

右键项目compare with ..
右键项目sync with ..

# Laravel Plugin
http://blog.jetbrains.com/phpstorm/2015/01/laravel-development-using-phpstorm/

# File

## open file
	double `shift`

## history

	右键 -> local history -> show history
	Alt+Shift+C 查看文件的历史

## move

	drag file in File Structure

## copy
	drag file while hold on `Alt` in File Structure

# keymap
这里我罗列一下我的emacs 按键
如果不知道配置在哪里， 可以通过` Ctrl+Shift+A` 再输入关键字`keymap`找到

	Forward/backward C-I/O

## Editor

	Alt+up/down 在方法间跳转
	Ctrl+Space 路径补全
	Ctrl+Shift+v 选择需要粘贴的最近内容
	start new line 				Shift+Enter
	start new line before current Ctrl+Alt+Enter

	complete current statement Ctrl+Shift+Enter

## Format

### Reformat Code

	Ctrl+CMD+F

code style - php

## select

    Ctrl+Alt+w
        select word

## Main menu

### completion

	Basic Alt+/
	SmartType Ctrl+Alt+/
	Cyclic expand word Shift+alt+/

### navigation

	goto line Alt+G

### find(search) / replace

	Cmd+F find next
	Shift+Cmd+F find previous

	Ctrl+Shift+F find in project
	Ctrl+Shift+R replace in project

### tab

	Command + Left/Right switch tab

### code move

	Alt+Shift+ UP/Down : move line Up/Down
	Ctrl+Shift+ UP/Down : move statement Up/Down

### fold
折叠

	ctrl + -/+  (不需要按shift)

### code navigation

#### move caret
移动光标

	Ctrl+[  move caret to code block start
	Ctrl+Shift+[  move to caret code block start (with selection)
	Ctrl+]  move caret to code block end
	Ctrl+Shift+]  move to caret code block end (with selection)

### file

	Ctrl+Alt+F12: file path
	Ctrl+E: 可以快速打开你最近编辑的文件。

## Alt-key map in mac
在mac中有些`Alt-key`是不可以用的，比如`Alt-B`, 这个问题6年都没有解决，参见[some alt-key combinations are not mappable](http://youtrack.jetbrains.com/issueMobile/IDEA-17392)

这个可以通过修改keyboard layout解决， 编辑`~/Library/KeyBindings/DefaultKeyBinding.dict`(只影响intellij):

	{
	/* Override symbols so other apps can bind */
	"~j" = "noop:";
	"~i" = "noop:";

	/* Additional Emacs bindings */
	"~f" = "moveWordForward:";
	"~b" = "moveWordBackward:";
	"~<" = "moveToBeginningOfDocument:";
	"~>" = "moveToEndOfDocument:";
	"~v" = "pageUp:";
	"^v" = "pageDown:";
	"~d" = "deleteWordForward:";
	"~w" = "deleteWordBackward:";
	"\UF729" = "moveToBeginningOfDocument:"; /* Home */
	"\UF72B" = "moveToEndOfDocument:"; /* End */
	"@\UF729" = "moveToBeginningOfParagraph:"; /* Cmd-Home */
	"@\UF72B" = "moveToEndOfParagraph:"; /* Cmd-End */
	"@\UF700" = "moveToBeginningOfDocument:"; /* Command-Up arrow */
	"@\UF701" = "moveToEndOfDocument:"; /* Command-Down arrow */
	"^\UF700" = "pageUp:"; /* Control-Up arrow */
	"^\UF701" = "pageDown:"; /* Control-Down arrow */
	"\UF72C" = "pageUp:"; /* Page-up */
	"\UF72D" = "pageDown:"; /* Page-down */

	"^/" = "undo:";
	"~/" = "complete:"; /* escape */
	"^j" = "insertNewline:"; /* Ctrl-j in case TextExtras isn't around */

	/* Some useful commands that are not bound by default. */
	"~p" = "selectParagraph:";
	"~l" = "selectLine:";
	"~w" = "selectWord:";

	/* Mark-point stuff (Emacs-style mark and point bindings are implemented but not bound by default. In the text system the mark and point are ranges, not just locations. The "point" is the selected range.) */
	"^ " = "setMark:";
	"^m" = "setMark:";
	"^s" = ("swapWithMark:", "centerSelectionInVisibleArea:");
	"^w" = "deleteToMark:";
	"^x" = {
	"^x" = ("swapWithMark:", "centerSelectionInVisibleArea:");
	"^m" = "selectToMark:";
	};
	}

# Exclude Directory
Open `Project Window`, right click and select `Mark Directory as` and `Excluded` from project.

# html

	快速查看样式：在HTML标签上进行右键，选择Show Applied Styles For Tag

## z-coding
> help z-coding on internet.

	ul.nav>li*5>a


# Path

## config path
phpstorm7.* 8.*

	u -sh ~/Library/Preferences/WebIde70
	u -sh ~/Library/Preferences/WebIde80

# intelliJ idea
http://www.jetbrains.com/idea/webhelp/enabling-php-support.html
