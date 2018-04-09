- cProfile
类似于xdebug cachegrind profiler 性能画像
# profile

## Timer
    from redis import Redis
    rdb = Redis()

    with Timer() as t:
        rdb.lpush("foo", "bar")
    print "=> elasped lpush: %s s" % t.secs

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
cProfile 执行整个脚本:

    python -m cProfile -o out.pstats prime.py arg1 arg2
    python -m profile -o out.pstats prime.py arg1 arg2
    python -m cProfile -o out.pstats $(which py.test)

可用以下脚本分析：
```
    import pstats
    p = pstats.Stats('out.pstats')
    p.strip_dirs()
    #p.sort_stats('cumtime')
    p.sort_stats('time') # 基于对time排序
    p.print_stats(50)
```

还可以使用一些图形化工具，比如 gprof2dot 来可视化分析 cProfile 的诊断结果: 火焰图,
用dot 生成调用结构图(循环调用这种最麻烦了)

    pip install gprof2dot
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
