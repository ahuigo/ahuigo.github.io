# Preface
python 主要是通过import 实现模块化的, 每个文件就是一个package:

	module/
		__init__.py
		pkg1.py
		pkg2.py
	
必须要电式引入，只会引入`pkg1`和`__init__`, 如下就不会引入`pkg2`\
```python
from module import pkg1; 
from module.pkg1
from module.pkg1 import func; 
```

# import
wirte a `hilo.py`:

	def add(a, b):
		return a+b

Then under interact python envirment:

	import hilo
	#from . import hilo ;# 仅限__init__.py
	print hilo.add(1,2)
	add = hilo.add
	print add(1,2)

	help(hilo) # What did you see?
	help(hilo.add)
	help(add)

import all class as first level   

    from hilo import *
    print add(1,2)

import `ex47.game`, would find two file:

	ex47/game.py
	ex47/__init__.py

1. 请注意，每一个包目录下面都会有一个__init__.py的文件，这个文件是必须存在的，否则，Python就把这个目录当成普通目录，而不是一个包。目录名就是包名或叫模块名(python3 后不是必须)
2. `__init__.py`可以是空文件，也可以有Python代码，因为`__init__.py`本身就是一个模块，而它的模块名就是所在文件夹的名字`ex47`

## import as
from tkinter import messagebox
import tkinter.messagebox as messagebox
import numpy as np
from bs4 import BeautifulSoup as bs

## import function
依次从locals, globals, PYTHONPATH查找:

	```python
	A = __import__('A')
	A = __import__('A.B') # __import__('A') == __import__('A.B')
	A = __import__('A.B', globals(), locals())

	B = __import__('A.B', fromlist=[''])
	```

如果想直接获取属性:

	```
	B = __import__('A.B', globals(), locals(), ['attr1'])
	attr1 = __import__('A.B', globals(), locals(), ['attr1']).attr1
	attr1 = getattr(__import__('A.B', globals(), locals(), ['attr1']), 'attr1')
	```

fromlist:

	['a', 'b'] is a list of names to emulate ``from name import a,b''
    [''] fromlist to emulate ``from name import *''.
    [] fromlist to emulate ``import name''.

## import dot
The . is a shortcut that tells it search in current package(not process's cwd) before rest of the PYTHONPATH:

	from .submodule import sth

current working path

	import mod.pkg;   # top file's directory (not process's cwd)
	import .mod.pkg;  # current file's directory (not process's cwd)
	from . import a,b,c ; current file's directory (not process's cwd)

比如 `__init__.py` 中经常用dot

## __name__
命令行执行模块时，`__name__` = `__main__` , import 导入时，它等于模块名, if不会执行

	if __name__=='__main__':
		print(__name__)

## path
此PATH 与 SHELL PATH 是独立的

1. Shell path: `os.environ['PATH']`, `os.getenv('PATH', default_value)`
2. PATH: sys.path, 会包括 `export PYTHONPATH`, 用于搜索python的模块

### module path

	import a_module
	print a_module.__file__
    >>> c.__class__
    <class 'http.cookiejar.Cookie'>
    >>> c.__class__.__module__
    'http.cookiejar'
    >>> inspect.getfile(__class__)

use module in command line:

    python -m easy_install pyyaml

### sys.path
module find path

	>>> import sys
	>>> sys.path.append('path')
	>>> print(sys.path)
	['', '/usr/local/Cellar/python3/3.5.0/Frameworks/Python.framework/Versions/3.5/lib/python35.zip', '/usr/local/Cellar/python3/3.5.0/Frameworks/Python.framework/Versions/3.5/lib/python3.5', '/usr/local/Cellar/python3/3.5.0/Frameworks/Python.framework/Versions/3.5/lib/python3.5/plat-darwin', '/usr/local/Cellar/python3/3.5.0/Frameworks/Python.framework/Versions/3.5/lib/python3.5/lib-dynload', '/usr/local/lib/python3.5/site-packages']
	 '/usr/local/lib/python3.5/site-packages'
	 /usr/local/lib/python3.5/site-packages/pip/_vendor/requests/cookies.py

#### PYTHONPATH
> PYTHONPATH Augment the default search path for module files. The format is the same as the shell’s PATH

相当于: sys.path.append()

	export PYTHONPATH=.

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

### 控制 from xxx import * 的行为
用 from xxx import * 的写法的，就只会导入 `__all__` 列出的成员(`仅限制*`)

### 为 lint 工具提供辅助
编写一个库的时候，经常会在 `__init__.py` 中暴露整个包的 API，而这些 API 的实现可能是在包中其他模块中定义的。如果我们仅仅这样写：

    from foo.bar import Spam, Egg

一些代码检查工具，如 pyflakes 就会报错，认为 Spam 和 Egg 是 import 了又没被使用的变量。当然一个可行的方法是把这个警告用`# noqa`压掉：

    from foo.bar import Spam, Egg  # noqa

但是更好的方法是显式定义 __all__，这样代码检查工具会理解这层意思，就不再报 unused variables 的警告：

    from foo.bar import Spam, Egg
    __all__ = ["Spam", "Egg"]

### limit
1. `__all__` must be list
2. `__all__` must be static(not dynamic)
3. `__all__` must be under import

# reload vs import
 多次重复使用import语句(其实是`__import__`)时，*不会重新加载执行* 被指定的模块，只是把对该模块的内存地址给引用到本地变量环境。

	import sys
 	print(id(sys))
	import sys
 	print(id(sys))

reload 对已经加载的模块进行重新加载(不含子模块)，一般用于原模块有变化等特殊情况，reload前该模块必须已经import过。

	from importlib import reload
	reload(sys);	# 因为setdefaultencoding函数在被系统调用后被删除了，所以通过import引用进来时其实已经没有了，所以必须reload
	sys.setdefaultencoding('utf8')  ##调用setdefaultencoding函数

see: py-import.md