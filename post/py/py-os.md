---
layout: page
title:
category: blog
description:
---
# Preface

# os 
## platform

    from sys import platform
	if platform == 'Darwin':  # 如果是Mac OS X
        linux linux2 win32 win64

	>>> import os
	>>> os.name # 操作系统类型
	'posix'

要获取详细的系统信息，可以调用uname()函数：

	>>> os.uname()
	posix.uname_result(sysname='Darwin', nodename='MichaelMacPro.local', release='14.3.0', version='Darwin Kernel Version 14.3.0: Mon Mar 23 11:59:05 PDT 2015; root:xnu-2782.20.48~5/RELEASE_X86_64', machine='x86_64')

## cpython executable path
```
import sys
print(sys.executable)
```

# psutil

## cup

	>>> multiprocessing.cpu_count()
    >>> psutil.cpu_count() # CPU逻辑数量
    4
    >>> psutil.cpu_count(logical=False) # CPU物理核心
    2

## 统计CPU的用户／系统／空闲时间：

    >>> psutil.cpu_times()
    scputimes(user=10963.31, nice=0.0, system=5138.67, idle=356102.45)

再实现类似top命令的CPU使用率，每秒刷新一次，累计10次：

    >>> for x in range(10):
    ...     psutil.cpu_percent(interval=1, percpu=True)
    [14.0, 4.0, 4.0, 4.0]
    [12.0, 3.0, 4.0, 3.0]

获取内存信息

使用psutil获取物理内存和交换内存信息，分别使用：

    >>> psutil.virtual_memory()
    svmem(total=8589934592, available=2866520064, percent=66.6, used=7201386496, free=216178688, active=3342192640, inactive=2650341376, wired=1208852480)
    >>> psutil.swap_memory()
    sswap(total=1073741824, used=150732800, free=923009024, percent=14.0, sin=10705981440, sout=40353792)

    返回的是字节为单位的整数，可以看到，总内存大小是8589934592 = 8 GB，已用7201386496 = 6.7 GB，使用了66.6%。
    而交换区大小是1073741824 = 1 GB。

获取磁盘信息
可以通过psutil获取磁盘分区、磁盘使用率和磁盘IO信息：

    >>> psutil.disk_partitions() # 磁盘分区信息
    [sdiskpart(device='/dev/disk1', mountpoint='/', fstype='hfs', opts='rw,local,rootfs,dovolfs,journaled,multilabel')]
    >>> psutil.disk_usage('/') # 磁盘使用情况
    sdiskusage(total=998982549504, used=390880133120, free=607840272384, percent=39.1)
    >>> psutil.disk_io_counters() # 磁盘IO
    sdiskio(read_count=988513, write_count=274457, read_bytes=14856830464, write_bytes=17509420032, read_time=2228966, write_time=1618405)
    可以看到，磁盘'/'的总容量是998982549504 = 930 GB，使用了39.1%。文件格式是HFS，opts中包含rw表示可读写，journaled表示支持日志。

获取网络信息
psutil可以获取网络接口和网络连接信息：

    >>> psutil.net_io_counters() # 获取网络读写字节／包的个数
    snetio(bytes_sent=3885744870, bytes_recv=10357676702, packets_sent=10613069, packets_recv=10423357, errin=0, errout=0, dropin=0, dropout=0)
    >>> psutil.net_if_addrs() # 获取网络接口信息
    {
    'lo0': [snic(family=<AddressFamily.AF_INET: 2>, address='127.0.0.1', netmask='255.0.0.0'), ...],
    'en1': [snic(family=<AddressFamily.AF_INET: 2>, address='10.0.1.80', netmask='255.255.255.0'), ...],

    >>> psutil.net_if_stats() # 获取网络接口状态
    {
    'lo0': snicstats(isup=True, duplex=<NicDuplex.NIC_DUPLEX_UNKNOWN: 0>, speed=0, mtu=16384),
    'en0': snicstats(isup=True, duplex=<NicDuplex.NIC_DUPLEX_UNKNOWN: 0>, speed=0, mtu=1500),

要获取当前网络连接信息，使用net_connections()：

    >>> psutil.net_connections()
    sconn(fd=83, family=<AddressFamily.AF_INET6: 30>, type=1, laddr=addr(ip='::127.0.0.1', port=62911), raddr=addr(ip='::127.0.0.1', port=3306), status='ESTABLISHED', pid=3725),
    sconn(fd=84, family=<AddressFamily.AF_INET6: 30>, type=1, laddr=addr(ip='::127.0.0.1', port=62905), raddr=addr(ip='::127.0.0.1', port=3306), status='ESTABLISHED', pid=3725),
获取进程信息

# sys/path
python 信息

## sys.version_info

    In [3]: sys.version_info
    Out[3]: sys.version_info(major=3, minor=6, micro=1, releaselevel='final', serial=0)

    sys.version_info > (3,6) Out[9]: True
    sys.version_info >= (3,7) Out[10]: False

## MEMORY, getsizeof

    >>> from sys import getsizeof
    >>> my_comp = [x * 5 for x in range(1000)]
    >>> my_gen = (x * 5 for x in range(1000))
    >>> getsizeof(my_comp)
    9024  
    >>> getsizeof(my_gen)
    88

If you need to know MEMORY USAGE of a given type, you can use the function sys.getsizeof

	>>> from sys import getsizeof
	>>> l = []
	>>> getsizeof(l)
	64
	>>> getsizeof("toto")
	53
	>>> getsizeof(10.5)
	24

# User

	import os, stat

    uid = os.getuid()
    euid = os.geteuid()
    gid = os.getgid()
    egid = os.getegid()

# environ, 环境变量
在操作系统中定义的环境变量，全部保存在os.environ这个变量中，可以直接查看：

	>>> os.environ
	environ({'VERSIONER_PYTHON_PREFER_32_BIT': 'no', 'TERM_PROGRAM_VERSION': '326', 'LOGNAME': 'michael', 'USER': 'michael', 'PATH': '/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/opt/X11/bin:/usr/local/mysql/bin', ...})
	要获取某个环境变量的值，可以调用os.environ.get('key')：

	>>> os.environ.get('PATH')
	'/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/opt/X11/bin:/usr/local/mysql/bin'
	>>> os.environ.get('x', 'default')
	'default'

	os.environ.get('HOME')
