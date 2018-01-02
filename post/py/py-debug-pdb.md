# Preface
- pdb 相当于是c里面的gdb
- ipdb：之于pdb, 相当于ipython 之于python. 
    1. 相对pdb 增加了高亮、tab  
    2. p (print), up(up stack), down(down stack) 之类的命令。
    3. 还能创建临时变量，执行任意函数

# ipdb: ipython + pdb

## sys.excepthook
创建一个sys.excepthook, 当异常出现时，就调用ipython.core.urltrdb+pdb 调试: (from @Rui L on zhihu)
```
import sys

class ExceptionHook:
    instance = None
    def __call__(self, *args, **kwargs):
        if self.instance is None:
            from IPython.core import ultratb
            self.instance = ultratb.FormattedTB(mode='Plain',
                 color_scheme='Linux', call_pdb=1)
        return self.instance(*args, **kwargs)

sys.excepthook = ExceptionHook()
```
使用时import这个文件就好。

和普通的IPython不同，这个时候可以调用 p (print), up(up stack), down(down stack) 之类的命令。还能创建临时变量，执行任意函数

```s
$ p3 a.py
Traceback (most recent call last):
  File "a.py", line 13, in <module>
    f2()
  File "a.py", line 11, in f2
    f1()
  File "a.py", line 6, in f1
    print(10 / n)
ZeroDivisionError: division by zero

> /Users/hilojack/test/a.py(6)f1()
      4     s = '0'
      5     n = int(s)
----> 6     print(10 / n)
      7     print('next exception KeyError')
      8     raise KeyError()

ipdb> up
> /Users/hilojack/test/a.py(11)f2()
      9
     10 def f2():
---> 11     f1()
     12
     13 f2()
> p f2
<function f2 at 0x10546abf8>
> f1()
...
```
## ipdb
其实不用手动引入sys.excepthook with ipython+pdb, 直接使用命令就可以, 当发生错误时会自动动停下的:
```
$ ipython --pdb test.py
```
ipdb（pdb）可以:

1. 设置断点、单步调试、进入函数调试、查看当前代码、查看栈片段、动态改变变量的值等。它有很多快捷键：
2. help: up，down，n，j，l，where，s, args
```python
ipdb> help
Documented commands (type help <topic>):
========================================
EOF    bt         cont      enable  jump  pdef    psource  run      unt   
a      c          continue  exit    l     pdoc    q        s        until 
alias  cl         d         h       list  pfile   quit     step     up    
args   clear      debug     help    n     pinfo   r        tbreak   w     
b      commands   disable   ignore  next  pinfo2  restart  u        whatis
break  condition  down      j       p     pp      return   unalias  where 
```

# pdb
pdb，让程序以单步方式运行，可以随时查看运行状态。

	s = '0'
	n = int(s)
	print(10 / n)

以参数`python -m pdb a.py`启动后，pdb定位到下一步要执行的代码-> s = '0'。输入命令l来查看代码：

	(Pdb) l
	  2  -> s = '0'
	  3     n = int(s)
	  4     print(10 / n)

单步命令：

	> n 下一步
	> s 进入函数

继续执行:

	> c 继续执行

打印命令：

	> p <var> 打印变量

退出:

	> q

## 设置断点
使用`-m pdb` 相当是在命令开始执行时就断点。我们可以通过`pdb.set_strace` 手动插入断点

	pdb.set_trace() # 运行到这里会自动暂停，并启动pdb

如果要比较爽地设置断点、单步执行，就需要一个支持调试功能的IDE。目前比较好的Python IDE有PyCharm.
