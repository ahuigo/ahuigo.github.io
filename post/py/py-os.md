---
layout: page
title:
category: blog
description:
---
# Preface

# platform

    from sys import platform
	if platform == 'Darwin':  # 如果是Mac OS X
        linux linux2 win32 win64

# os

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
## cpu

	import threading, multiprocessing

	multiprocessing.cpu_count()

# sys
python 信息

## sys.version_info
```
In [3]: sys.version_info
Out[3]: sys.version_info(major=3, minor=6, micro=1, releaselevel='final', serial=0)

sys.version_info > (3,6) Out[9]: True
sys.version_info >= (3,7) Out[10]: False
```

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

# 环境变量
在操作系统中定义的环境变量，全部保存在os.environ这个变量中，可以直接查看：

	>>> os.environ
	environ({'VERSIONER_PYTHON_PREFER_32_BIT': 'no', 'TERM_PROGRAM_VERSION': '326', 'LOGNAME': 'michael', 'USER': 'michael', 'PATH': '/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/opt/X11/bin:/usr/local/mysql/bin', ...})
	要获取某个环境变量的值，可以调用os.environ.get('key')：

	>>> os.environ.get('PATH')
	'/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/opt/X11/bin:/usr/local/mysql/bin'
	>>> os.environ.get('x', 'default')
	'default'

	os.environ.get('HOME')
