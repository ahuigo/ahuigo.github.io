---
title: python 性能分析
date: 2018-10-04
---
# python 性能分析
介绍几个分析工具：
- cProfile
类似于xdebug cachegrind profiler 性能画像
- py-spy python 版的top
    - py-spy --pid 12345
    - py-spy --flame profile.svg --pid 12345
    - py-spy -- python myprogram.py

## Timer

### timeit
使用time with context

	import timeit
	>>> min(timeit.repeat(lambda: {**x, **y}))
	0.4094954460160807

装饰：每次运行时打印时间

    >>> @timeit(repeat=3, number=10)
    ... def convert(df, column_name):
    ...     return pd.to_datetime(df[column_name])



## profile
### for code
用标准库里面的profile或者cProfile(cProfile性能更好)

    import cProfile
    cProfile.run("prime()")

如果想查看耗时最多的4个函数，先将cProfile 的输出保存到诊断文件中，然后用 pstats 定制更加有好的输出

    import pstats
    cProfile.run("import os; os.getcwd()", 'a.psstats')
    p = pstats.Stats('a.pstats')
    p.sort_stats('time') # 基于对time排序
    p.print_stats(4)    # 打印出前4个

### for file
prime.py

    import time
    def s(n=1): time.sleep(n)
    def s1(): s(1)
    def s2(): s(2)
    def f():
        s(3)
        s1()

    f()

cProfile 执行整个脚本:

    python -m cProfile -o out.pstats prime.py arg1 arg2
    python -m profile -o out.pstats prime.py arg1 arg2
    python -m cProfile -o out.pstats $(which py.test)

可用以下脚本分析：

    import pstats
    p = pstats.Stats('out.pstats')
    p.strip_dirs()
    p.sort_stats('cumtime')
    #p.sort_stats('time') # 基于对time排序
    p.print_stats(50)

结果：

            self               total
   ncalls  tottime  percall  cumtime  percall filename:lineno(function)
        1    0.000    0.000    4.007    4.007 a.py:8(f)
        2    0.000    0.000    4.007    2.004 a.py:3(s)
        2    4.007    2.004    4.007    2.004 {built-in method time.sleep}
        1    0.000    0.000    1.003    1.003 a.py:6(s1)

还可以使用一些图形化工具，比如 gprof2dot 来可视化分析 cProfile 的诊断结果: 火焰图,
用dot 生成调用结构图(循环调用这种最麻烦了)

    pip install gprof2dot
    brew install gprof2dot
    gprof2dot -f pstats out.pstats | dot -Tpng -o output.png

## line_profiler 逐行计时和分析执行的频率
pip install line_profiler

fib.py:

    @profile
    def primes(n): 
        xxx
    
使用 kernprof.py 运行这个脚本。

    kernprof.py -l -v fib.py
    -l 选项告诉 kernprof 把修饰符 @profile 注入你的脚本
    -v 打印结果


## memory_profiler 内存分析
在这里建议安装 psutil 是因为该包能提升 memory_profiler 的性能。

    $ pip install -U memory_profiler
    $ pip install psutil

memory_profiler 设置 @profile 来修饰你的函数：

    @profile
    def primes(n): 
        ...

运行如下命令来显示你的函数使用了多少内存：

    $ python -m memory_profiler primes.py

### iPython
line_profiler 和 memory_profiler 在IPython 上都有快捷命令。

    %load_ext memory_profiler
    %load_ext line_profiler

这样做了以后，你就可以使用魔法命令 %lprun 和 %mprun 执行 @profile 修饰符:

    In [1]: from primes import primes
    In [2]: %mprun -f primes primes(1000)
    In [3]: %lprun -f primes primes(1000)

### objgraph 内存溢出了？
发现内存泄漏用objgraph 的工具, 变量不使用时，引用计数还存在。
1. 可看到在内存中对象的数量
2. 也定位在代码中所有不同的地方,对这些对象的引用。

一旦你安装了这个工具，在你的代码中插入一个调用调试器的声明。

    $ pip install objgraph
    import pdb; pdb.set_trace()

具体参考: https://segmentfault.com/a/1190000000616798

# perf (todo)
python 性能分析
http://www.oschina.net/translate/python-performance-analysis

    1.它运行的有多块？
    2.那里是速度的瓶颈？
    3.它使用了多少内存？
    4.哪里发生了内存泄漏？

## time
### line_profiler: 
1. pip3 install line_profiler
```
@profiler
def primes(n):
    ....

primes(100)
```
```
$ kernprof.py -l -v primes.py
```
-l选项通知kernprof注入@profile装饰器到你的脚步的内建函数，-v选项通知kernprof在脚本执行完毕的时候显示计时信息。上述脚本的输出看起来像这样：
```
Wrote profile results to primes.py.lprof
Timer unit: 1e-06 s

File: primes.py
Function: primes at line 2
Total time: 0.00019 s

Line #      Hits         Time  Per Hit   % Time  Line Contents
==============================================================
     2                                           @profile
     3                                           def primes(n): 
     4         1            2      2.0      1.1      if n==2:
     5                                                   return [2]
     6         1            1      1.0      0.5      elif n<2:
     7                                                   return []
     8         1            4      4.0      2.1      s=range(3,n+1,2)
     9         1           10     10.0      5.3      mroot = n ** 0.5
    10         1            2      2.0      1.1      half=(n+1)/2-1
    11         1            1      1.0      0.5      i=0
    12         1            1      1.0      0.5      m=3
    13         5            7      1.4      3.7      while m <= mroot:
    14         4            4      1.0      2.1          if s[i]:
    15         3            4      1.3      2.1              j=(m*m-3)/2
    16         3            4      1.3      2.1              s[j]=0
    17        31           31      1.0     16.3              while j<half:
    18        28           28      1.0     14.7                  s[j]=0
    19        28           29      1.0     15.3                  j+=m
    20         4            4      1.0      2.1          i=i+1
    21         4            4      1.0      2.1          m=2*i+3
    22        50           54      1.1     28.4      return [2]+[x for x in s if x]
```

## memory
```
$ pip install psutil
$ python -m memory_profiler primes.py

Filename: primes.py

Line #    Mem usage  Increment   Line Contents
==============================================
     2                           @profile
     3    7.9219 MB  0.0000 MB   def primes(n): 
     4    7.9219 MB  0.0000 MB       if n==2:
     5                                   return [2]
     6    7.9219 MB  0.0000 MB       elif n<2:
     7                                   return []
     8    7.9219 MB  0.0000 MB       s=range(3,n+1,2)
     9    7.9258 MB  0.0039 MB       mroot = n ** 0.5
    10    7.9258 MB  0.0000 MB       half=(n+1)/2-1
    11    7.9258 MB  0.0000 MB       i=0
    12    7.9258 MB  0.0000 MB       m=3
```
## QA
### ine_profiler和memory_profiler的IPython快捷方式
memory_profiler和line_profiler有一个鲜为人知的小窍门，两者都有在IPython中的快捷命令。你需要做的就是在IPython会话中输入以下内容：

    %load_ext memory_profiler
    %load_ext line_profiler

在这样做的时候你需要访问魔法命令%lprun和%mprun，它们的行为类似于他们的命令行形式。主要区别是你不需要使用@profile decorator来修饰你要分析的函数。只需要在IPython会话中像先前一样直接运行分析：

    In [1]: from primes import primes
    In [2]: %mprun -f primes primes(1000)
    In [3]: %lprun -f primes primes(1000)

这样可以节省你很多时间和精力，因为你的源代码不需要为使用这些分析命令而进行修改。

# objgraph 内存泄漏在哪里？
cPython解释器使用引用计数做为记录内存使用的主要方法. 
1. 如果程序中不再被使用的对象的引用一直被占有，那么就经常发生内存泄漏。
2. 查找“内存泄漏”可用objgraph，查看内存中对象的数量，定位含有该对象的引用的所有代码的位置。

## 安装 objgraph

    $ pip install objgraph

一旦你已经安装了这个工具，在你的代码中插入一行声明调用调试器：

    import pdb; pdb.set_trace()

运行python 运行时，并使用gdb 调试查看 最普遍的对象是哪些？

    ```
    (pdb) import objgraph
    (pdb) objgraph.show_most_common_types()

    MyBigFatObject             20000
    tuple                      16938
    function                   4310
    dict                       2790
    wrapper_descriptor         1181
    builtin_function_or_method 934
    weakref                    764
    list                       634
    method_descriptor          507
    getset_descriptor          451
    type                       439
    ```

### 哪些对象已经被添加或删除？

我们也可以查看两个时间点之间那些对象已经被添加或删除：

    ```
    (pdb) import objgraph
    (pdb) objgraph.show_growth()
    .
    .
    .
    (pdb) objgraph.show_growth()   # this only shows objects that has been added or deleted since last show_growth() call

    traceback                4        +2
    KeyboardInterrupt        1        +1
    frame                   24        +1
    list                   667        +1
    tuple                16969        +1
    ```

### 谁引用着泄漏的对象？

继续，你还可以查看哪里包含给定对象的引用。让我们以下述简单的程序做为一个例子：

    ```
    x = [1]
    y = [x, [x], {"a":x}]
    import pdb; pdb.set_trace()

想要看看哪里包含变量x的引用，执行objgraph.show_backref()函数：

    ```
    (pdb) import objgraph
    (pdb) objgraph.show_backref([x], filename="/tmp/backrefs.png")
    ```

我们得到一个refs.png 引用图