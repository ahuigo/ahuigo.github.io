---
layout: page
title: py-file-io
category: blog
description: 
date: 2018-09-28
---
# Preface

# flush buffer
开启buffer 后，默认是换行才flush, print 调用的就是sys.stdout

    # mac测试后：不一定有效
    PYTHONUNBUFFERED=0 python3 <<<'import sys,time; sys.stdout.write("sys");time.sleep(10)'
    PYTHONUNBUFFERED=0 python3 <<<'import sys,time; sys.stdout.write("sys\n");time.sleep(10)'
    PYTHONUNBUFFERED=0 python3 <<<'import sys,time; print("print",end="");time.sleep(10)'
    # 有效
    python3 -u <<<'import sys,time; sys.stdout.write("sys");time.sleep(10)'
    python3 -u test.py

也可以定向到别的地方：

    sys.stdout = open(‘file.txt’, ‘a’,0)

其实包括换行，有三种mode:

    1. _IOLBF，line buffer
    2. _IOFBF, full buffer
    3. _IONBF，no buffer

C语言 关闭buffer

    int setvbuf(FILE *stream, char *buffer, int mode, size_t size)
    setvbuf(stdout, 0, _INNBF, 0);

python [完全关闭buffer](http://jaseywang.me/2015/04/01/stdio-%E7%9A%84-buffer-%E9%97%AE%E9%A2%98/)

1. sys.stdout = os.fdopen(sys.stdout.fileno(), 'w', 0)
2. 直接定向到stderr 
3. 直接脚本的时候加上 -u 参数。`python -u tool/bench.py`
   1. 但是需要注意下，xreadlines(), readlines() 包含一个内部 buffer，不受 -u 影响，因此如果通过 stdin 来遍历会出现问题
4. 将其 stream 关联到 pseudo terminal(pty) 上，script 命令可以做这事情的: `script -q -c "command1" /dev/null | command2`
或者通过 socat 这个工具实现，

使用buffer

    # no buffer
    sys.stdout = os.fdopen(sys.stdout.fileno(), 'w', 0)
    # any buffer 
    sys.stdout = os.fdopen(sys.stdout.fileno(), 'w', -1)
    sys.stdout = os.fdopen(sys.stdout.fileno(), 'w', buffering=-1)


## pipe buffer
再来看个跟 pipe 相关的问题， 这个命令常常回车之后没有反应:

    $ tail -f logfile | grep "foo" | awk {print $1}

解释
1. tail 的 stdout buffer 默认会做 full buffer，由于加上了 -f，表示会调用 fflush() 对输出流进行 flush，所以 tail -f 这部分没什么问题。
2. 关键在 grep 的 stdout buffer，因此它存在一个 8KB stdout buffer，要等该 buffer 满了之后 awk 才会接收到数据。
3. awk 的 stdout buffer 跟终端相关联，所有默认是 line buffer。怎么解决这个问题了，

其实 grep 提供了 –line-buffered 这个选项来做 line buffer，这会比 full buffer 快的多:

    tail -f logfile | grep –line-buffered  "foo" | awk {print $1}

除了 grep，sed 有对应的 -u(–unbuffered)，awk(我们默认的是 mawk) 有 -W 选项，tcpdump 有 -l 选项来将 full buffer 变成 line 或者 no buffer。

### stdbuf
上面修改参数的不具有普遍原理。其实 coreutils 已经给我们提供了一个叫 stdbuf 的工具。expect 还提供了一个叫 unbuffer 的工具:

    tail -f logfile | stdbuf -oL grep "foo" | awk {print $1}

# mmap
1. 文件操作需要从磁盘到页缓存再到用户主存的两次数据拷贝。
2. 而 mmap 操控文件，只需要从磁盘到用户主存的一次数据拷贝过程. 但是大文件： major page fault 多

    In [6]: with open("2.txt","r+b") as f:
    ...:     mm = mmap.mmap(f.fileno(),0,prot=mmap.PROT_READ)
    ...:     for line in iter(lambda: mm.readline(), b''):
    ...:         print(line)
    ...:

# HTTP io

	from urllib import urlopen

readline:

	urlp = urlopen(url);
	while(line = urlp.readline()){

	}

readlines:

	for line in urlopen(url).readlines():
		print line.strip()

# std io

    for l in sys.stdin.readlines():
        sys.stdout.write(l[::-1])

## input
输入一行，不含换行

	str = input()
	str = input("Input some string:")
    # 不回显:
    getpass.getpass("Please input your Password: ")

## stdin file
接收多行: 包含换行

    import fileinput
    for line in fileinput.input():
        sys.stdout.write(line)
        print(line) # on more new line

# StringIO和BytesIO

## File-like Object
像open()函数返回的这种有个read()方法的对象，在Python中统称为file-like Object。除了file外，还可以是内存的字节流，网络流，自定义流等等。file-like Object不要求从特定类继承，只要写个read()方法就行。

    if hasattr(obj, 'read'):
        return read(obj)

- StringIO/BytesIO 就是在内存中创建的file-like Object，常用作临时缓冲。

## StringIO
StringIO顾名思义就是在内存中读写str。

要把str写入StringIO，我们需要先创建一个StringIO，然后，像文件一样写入即可：

	>>> from io import StringIO
	>>> f = StringIO()
	>>> f.write('hello')
	5
	>>> f.write(' ')
	1
	>>> f.write('world!')
	6
	>>> print(f.getvalue())
	hello world!

### init: as file object

	>>> from PIL import Image
	>>> from io import StringIO
	>>> i = Image.open(StringIO('Hello!\nHi!\nGoodbye!')) # open(filename/file-object/Path)

再来一个csv+pg 例子：

    output = io.StringIO()
    df.to_csv(output, sep='\t', header=False, index=False)
    output.seek(0)

### read
受f.seek(0) 影响的

	f.read()
	f.readline()
	f.readlines()

io 特有的, 不会改变seek cursor：

    f.getvalue() 

## BytesIO
StringIO操作的只能是str，如果要操作二进制数据，就需要使用BytesIO。

	>>> from io import BytesIO
	>>> f = BytesIO()
	>>> f.write('中文'.encode('utf-8'))
	6

	>>> print(f.getvalue())
	b'\xe4\xb8\xad\xe6\x96\x87'

string 与 bytes 相互转换

	>>> '123€20'.encode('utf-8')
	b'123\xe2\x82\xac20'
	>>> b'\xe2\x82\xac20'.decode('utf-8')
	'€20'
	>>> '123'.encode('utf-8')