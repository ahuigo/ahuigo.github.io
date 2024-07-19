---
title: py-import
date: 2018-09-28
---

# package vs module
> 示例： cd pylib/app/pkg/

## package vs module 定义
> 示例： cd pylib/app/pkg/

`import pkg/module` 时，引入的虽然object type 都是`module`，但它们不同点是

1. mod.py is module, 优先级低(同名时选pkg) (a single file)
2. `pkg/` is package(python3.3前必须要有`pkg/__init__.py`,), 优先级高. (a collection of modules in directory)

示例： cd pylib/app/pkg/:

    > import mypkg
    <module 'mypkg' (namespace) from ['/mypkg']>

    > from mypkg import version
    <module 'mypkg.version' from '/mypkg/version.py'>

## 运行package或module 的方法
运行package:

    python -m tests 
    # 1. 先运行 tests/__init__.py
    # 2. 再运行　tests/__main__.py

    python tests ;#文件夹也是可以运行的,　它本身就是package, 只是sys.path 插入的是"./tests"
    #运行 tests/__main__.py

运行 module

    python -m tests.test_client 
    # 运行的  python tests/test_client.py

## package name and parent package
打印包名：`print("name:" + __name__, "package:"+__package__)`(参考:pylib/app/pkg/)

    $ p tests/test_client.py
    name:__main__ package: None
    mypkg: {'name': 'mypkg', 'package': 'mypkg'}

    $ p -m tests.test_client
    name:__main__ package: tests 
    mypkg: {'name': 'mypkg', 'package': 'mypkg'}

Note: mypkg 的父包就是 tests(相对引用必须要有parent package),
> 如果没有父包的文件，调用`from .mypkg import Client` 就会报:
> ImportError: attempted relative import with no known parent package

# import

## import 缓存
import 的包都会缓存到sys.modules

    # Install the Q() object in sys.modules so that "import q" gives a callable q.
    sys.modules['q'] = Q()
    # import conf 
    sys.modules['conf'] = {user:"ahui"}

## import function
A目录下必须放`__init__.py`才被作为pkg 引入import

import 函数原型：

    __import__(name, globals=None, locals=None, fromlist=(), level=0) -> module

依次从locals, globals, PYTHONPATH查找:

	```python
	A = __import__('A')   # import A
	A = __import__('A.B') # import A.B
	A = __import__('A.B', globals(), locals()) 

	B = __import__('A.B', fromlist=[''])
	```

fromlist: 

	# 加载A.B，但得到B
	['a', 'b'] is a list of names to emulate ``from A.B import a,b'' : a,b
    [''] fromlist to emulate ``from A.B import *''. : B

	# 加载A.B，但得到A
    [] fromlist to emulate ``import A.B''. : A
    no fromlist to emulate ``import A.B''. : A

	# 只得到A
    no fromlist to emulate ``import A''. : A

如果想直接获取属性:

	```
	B = __import__('A.B', globals(), locals(), fromlist=['attr1'])
	attr1 = __import__('A.B', globals(), locals(), ['attr1']).attr1
	attr1 = getattr(__import__('A.B', globals(), locals(), ['attr1']), 'attr1')
	```

globals(): is only used to determine the context; they are not modified.  
locals(): is unused(不使用).

## import dot. 相对引用
The . is a shortcut that tells it search in current package(not process's cwd) before rest of the PYTHONPATH:

    # 从当前file所在目录中，导入user.py
    from . import user
    from .user import User
    from .dir import Dir #__init__.py
	from .submodule import sth
	from ..parentmodule import sth
	from ......parentmodule import sth

bad　usage:

    import .pkg
    import ..pkg

以下用法中，查找的目录是什么呢？

	from mod.pkg;   # find in sys.path
	from .mod.pkg;  # find in current file's directory (not process's cwd)
	from . import a,b,c ; find in current file's directory (not process's cwd)

## reload vs import
 多次重复使用import语句(其实是`__import__`)时，*不会重新加载执行* 被指定的模块，只是把对该模块的内存地址给引用到本地变量环境。

	import sys
 	print(id(sys))
	import sys
 	print(id(sys))

reload 对已经加载的模块进行重新加载(不含子模块)，一般用于原模块有变化等特殊情况，reload前该模块必须已经import过。

	from importlib import reload
	reload(sys);	# 因为setdefaultencoding函数在被系统调用后被删除了，所以通过import引用进来时其实已经没有了，所以必须reload
	sys.setdefaultencoding('utf8')  ##调用setdefaultencoding函数

## path
sys.path 与 SHELL PATH 是独立的

1. Shell path: `os.environ['PATH']`, `os.getenv('PATH', default_value)`
2. sys.path: 会包括 `export PYTHONPATH`, 用于搜索python的模块

### sys.prefix 安装路径
python安装路径: sys.prefix

### site-packages path
    # 这个不全: 只有一个
    python -c 'import site;print(site.getsitepackages())'
    # 这个全
    python -m site

### find package path

	import a_module
	print a_module.__file__

    >>> c.__class__
    <class 'http.cookiejar.Cookie'>
    >>> c.__class__.__module__
    'http.cookiejar'
    >>> inspect.getfile(__class__)

### sys.path
> 示例： cat pylib/app/pkg/doc.md, 演示了python执行时的sys.path

module find path

	>>> import sys
	>>> sys.path.append('path')
	>>> print(sys.path)
	['', '/usr/local/Cellar/python3/3.5.0/Frameworks/Python.framework/Versions/3.5/lib/python3.5','/usr/local/lib/python3.5/site-packages']
	 /usr/local/lib/python3.5/site-packages/pip/_vendor/requests/cookies.py

#### PYTHONPATH(warn)
相当于: sys.path.insert(1,'.'): 注意不是0个，第0个是执行入口文件所在的目录, 比如flask/gunicorn 所在的目录

	export PYTHONPATH=. ;# 当前的working 目录

# module is store

    $ tree mod
    mod
    ├── run.py
    ├── b.py
    └── store.py

    
    $  cat store.py 
    name=None

    $  cat b.py 
    from . import store
    def debug():
        print(store.name)

    $  cat run.py 
    from . import b
    from . import store
    store.name='name from run.py'
    b.debug()

module `store.py` is used as store

    $ python
    >>> from mod import run
    name from run.py

## conf with env

    # from conf import DEBUG
    DEBUG = os.getenv("DEBUG", "")

# scope
模块内变量作用scope

1. public:
	正常的函数和变量名是公开的（public），可以被直接引用，比如：abc，x123，PI等；

1. 特殊变量`__xxx__`： 可以被直接引用，但是有特殊用途
	__author__，__name__就是特殊变量
	__doc__ 文档注释也可以用特殊变量
	__file__ 
	`__class__.__name__`

3. `_xxx和__xxx`
    import M import * #不会引入下划线属性
	这样的函数或变量就是非公开的（private），不应该被直接引用，比如_abc，__abc等；
	`FOO.__xxx` 通过改名为`FOO._FOO__xxx` 隐藏自己

> 之所以我们说，private函数和变量“不应该”被直接引用，而不是“不能”被直接引用，是因为Python并没有一种方法可以完全限制访问private函数或变量

## 类中的私有属性
对于`class.__x`, 这样的私有属性, 为了禁止访问私有属性, 它会将它改名为`_Demo__x`(实际上是禁止不了的!)
改名由不同的python interpreter 决定

    class Demo(object):
        def _f1(self): pass
        def __f2(self): pass
        _v1 = 1
        __v2 = 1

    print(Demo.__dict__.keys())
        _f1
        _Demo__f2
        _v1
        _Demo__v2

## `__all__`
> 参考: http://python-china.org/t/725
Python 靠一套需要大家自觉遵守的”约定“下工作。 比如下划线开头的应该对外部不可见。all 则不是人为约定, 而是机器约定

1. 同样，__all__ 也是对于模块公开接口的一种约定，比起下划线，__all__ 提供了暴露接口用的”白名单“。
2. 一些不以下划线开头的变量（比如从其他地方 import 到当前模块的成员）可以同样被排除出去。

    import os
    import sys
    __all__ = ["process_xxx"]  # 只暴露`process_xxx`, 排除了 `os` 和 `sys`

    def process_xxx():
        pass  # omit

###  作用
1. 只能控制 `from xxx import *` 的写法的，就只会导入 `__all__` 列出的成员(`仅限制*`)
2. `from xxx import any` 则不限制

### 为 lint 工具提供辅助
编写一个库的时候，经常会在 `__init__.py` 中暴露整个包的 API，而这些 API 的实现可能是在包中其他模块中定义的。如果我们仅仅这样写：

    from foo.bar import Spam, Egg

一些代码检查工具，如 pyflakes 就会报错，认为 Spam 和 Egg 是 import 了又没被使用的变量。当然一个可行的方法是把这个警告用`# noqa`压掉：

    from foo.bar import Spam, Egg  # noqa

但是更好的方法是显式定义 __all__，这样代码检查工具会理解 为暴露给外部，就不再报 unused variables 的警告：

    from foo.bar import Spam, Egg
    __all__ = ["Spam", "Egg"]

### limit
1. `__all__` must be list
2. `__all__` must be static(not dynamic)
3. `__all__` must be under import
