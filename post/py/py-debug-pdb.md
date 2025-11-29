---
title: py-debug-pdb
date: 2018-09-28
---
# Preface
几个pdb相关的调试工具介绍
- pdb: pdb(标准库调试器), 相当于是c里面的gdb
    - pdb.set_trace()，或命令行 python -m pdb script.py 异常触发
- ipdb(pdb 的“增强版”交互壳)：ipdb之于pdb, 相当于ipython 之于python. 
    0. 触发：ipdb.set_trace() 或 ipython --pdb script.py 异常时触发
    1. 相对pdb 增加了高亮、tab  
    2. p (print), up(up stack), down(down stack) 之类的命令。
    3. 还能创建临时变量，执行任意函数
- IPython 的 embed（嵌入式交互解释器）
    - from IPython import embed; embed()
    - 能力：交互式探索当前作用域变量、执行任意 Python 语句；不提供步进/断点/堆栈导航，除非结合异常钩子或 --pdb。

# ipdb(ipython)

## start shell
ipython.embed 进入shell：

    if is_debug():
        from IPython import embed
        embed()

下面介绍的 pdb插入以下代码进入断点调试，相当于js debugger:

    import os
    def is_debug():
        return os.getenv('DEBUG_PDB')!=None

    if is_debug():
        import pdb; 
        pdb.set_trace()


## via sys.excepthook
创建一个sys.excepthook, 当异常出现时，就调用ipython+pdb 调试: (from @Rui L on zhihu)
```python
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
其实不用手动引入sys.excepthook (ipython+pdb), 直接使用命令就可以, 当发生错误时会自动动停下的:
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

# pdb(debugger)
python -m pdb test_pdb.py

    import pdb
    ....code...
    pdb.set_trace()      # This introduces a breakpoint like js debugger
    ... code...

在调试器模式下，您可以使用以下命令执行代码：

    n：执行下一行代码。
    s：进入当前行的函数。
    c：继续执行代码，直到下一个断点。
    q：退出调试器模式。

## example
run:

    > bt
        -> caller()
        /Users/hilojack/test/a.py(7)caller()
        -> a()
        > /Users/hilojack/test/a.py(3)a()
        -> time.sleep(1)
    > help
    # list code 
    > list

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

breakponint on frame:

    pdb.Pdb().set_trace(frame)

## pdb 操作
### pdb help
     (Pdb) help
    Documented commands (type help <topic>):
    ========================================
    EOF    c          d        h         list      q        rv       undisplay
    a      cl         debug    help      ll        quit     s        unt      
    alias  clear      disable  ignore    longlist  r        source   until    
    args   commands   display  interact  n         restart  step     up       
    b      condition  down     j         next      return   tbreak   w        
    break  cont       enable   jump      p         retval   u        whatis   
    bt     continue   exit     l         pp        run      unalias  where    

     (Pdb) h step

### 设断点

    (Pdb) b 10          # 在第10行设断点
    (Pdb) b myfile.py:15 # 在myfile.py的第15行设断点
    (Pdb) b myfunc      # 在函数myfunc入口处设断点
    (Pdb) b             # 列出所有断点

### (Pdb) step + return(step out)

     (Pdb) h step
     (Pdb) h return
### (Pdb) next
### (Pdb) c, continue

    (Pdb) help c
      Usage: c(ont(inue))
      Continue execution, only stop when a breakpoint is encountered.