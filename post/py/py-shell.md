---
title: python shell 子进程
date: 2018-10-04
---
# python shell 子进程
很多时候，子进程并不是自身，而是一个外部进程。我们创建了子进程后，还需要控制子进程的输入和输出。

subprocess模块可以让我们非常方便地启动一个子进程，然后控制其输入和输出。

## shell readline

    # ~/.pythonrc
    # enable syntax completion
    try:
        import readline
    except ImportError:
        print("Module readline not available.")
    else:
        import rlcompleter
        readline.parse_and_bind("tab: complete")

## enter interact mode
    def interactDebug(local):
        import code
        import readline
        import rlcompleter
        readline.parse_and_bind("tab: complete")
        code.interact(local=local)
    
    interactDebug(locals())

## exec python shell
via shell args: 

	python -c 'import os;print(os.WNOHANG)' # -m mod 比 -c cmd 优先级高

via shell pip:

	cat a.py | python
	cat a.py | python - arg1
    p3 a.py 1 2 3
        ['a.py', '1', '2', '3']
    p3 <<<'import sys; print(sys.argv)'  - arg1 argv2
        ['-', 'arg1', 'argv2']

via 进程替换(process substitution)

	python <(cat p.py)
	python p.py

via python module

	echo 'import sys;print(sys.argv)' > module.py ; p3 -m module arg1

	python -m json.tool test.json
	echo '{"json":"obj"}' | python -m json.tool # 管道

    python -m fab arg1
    fab arg1

	# localserver
	python3 -m http.server 8080 # 3.x

via exec

	import file.py; #
	exec('print(1)')

## exec shell

### escape

    def shellquote(s):
        return "'" + s.replace("'", "'\\''") + "'"
    shlex.quote(s)

### sh
1. sh.ls("-l", "/tmp", color="never") # equal to getoutput
	1. sh.ls("-l /tmp".split(' '))
2. subprocess.check_output("ls -l", shell=True).decode('gbk')
    2. subprocess.check_output(["ls", "-l"]).decode('gbk')
3. subprocess.getoutput("ls -l;pwd"); # only support utf8
	1. subprocess.getstatusoutput("ls -l") # return list: [code, output_str]
4. print output: errno = os.system('ls -ls')
5. errno=subprocess.call("ls -l", shell=True)
    2. s.call(["ls","-a"])

background+gui:
1. errno=call("sleep 10 &", shell=True) 
    2. call 后台执行时，永远返回errno=0
    3. 而getoutput 它需要获取到stdout+stderr, 强制等待任务结束
1. print output: errno = os.system('ls -ls &')

### getstatusoutput
    cmd = f'psql -h host -U postgres {DBNAME} -p {PORT} -c "REINDEX table {TBNAME}" >/dev/null || echo "error" '
    print(cmd)
    code, out = subprocess.getstatusoutput(cmd)

check command exists

    def isCmdExisted(cmd):
        from subprocess import getstatusoutput
        return getstatusoutput('hash '+cmd)[0]==0

### subprocess.check_output

    import subprocess
    res = subprocess.check_output(["ls", "-l"])
    res = subprocess.check_output("ls -l", shell=True) # 以shell 角析, 否则"ls -l" 就是一个命令
    print(res.decode()) # 默认返回值为 bytes 类型
        -rw-r--r-- ...

### subprocess.Popen(支持异步)
> subprocess.call 等，内部使用的就是Popen
Popen 是最基础的类, 它是非阻塞的(除非执行`proc.stdout.read()`)

#### 异步执行
    import subprocess
    # 这里程序会继续执行，不会等待 'ls' 命令结束
    process = subprocess.Popen(['sleep', '61'])
    process = subprocess.Popen('ls -l', shell=True)

#### shell=True 支持字符语句
1. 只取第一个参数，且把参数当成shell 语句而非单条命令
2. 可以执行multiple commands

e.g.

	subprocess.Popen('sleep 5;echo abc',shell=True, stdout=subprocess.PIPE).stdout.read()

#### read output

	proc = subprocess.Popen(['ls','-l'],stdout=subprocess.PIPE)
	line = proc.stdout.readline();
	while line;
		print "test:", line.rstrip()
		line = proc.stdout.readline();

#### write: subprocess.Popen().communicate
如果子进程还需要输入，则可以通过communicate()方法输入(其实是向stdin 写)：

	import subprocess
	print('$ nslookup')
	p = subprocess.Popen(['nslookup'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
	output, err = p.communicate(b'set q=mx\npython.org\nexit\n')
	print(output.decode('utf-8'))
	print(output.decode())
	print('Exit code:', p.returncode)

上面的代码相当于在命令行执行命令nslookup，然后手动输入：

	set q=mx
	python.org
	exit

### via call
类似run, 但不返回结果:

1. 只返回errno
2. print capture output

	>>from subprocess import call
	>>errno=call("ls -l", shell=True)
	>>errno=call(["ls", "-l"])
	total 240
	-rw-r--r--   1 hilojack  staff   1.6K Dec 16 13:26 a.txt

### via run
它封装(package)的`subprocess.Popen`

	>>> import subprocess

doesn't capture output

	>>> r=subprocess.run(["ls", "-l", "/dev/null"])
	crw-rw-rw-  1 root  wheel    3,   2 Dec 19 11:13 /dev/null
	>>> print(r)
	CompletedProcess(args=['ls', '-l', '/dev/null'], returncode=0)

capture output

	>>> r = subprocess.run(["ls", "-l", "/dev/null"], stdout=subprocess.PIPE)
	>>> print(r)
	CompletedProcess(args=['ls', '-l', '/dev/null'], returncode=0, stdout=b'crw-rw-rw-  1 root  wheel    3,   2 Dec 19 11:13 /dev/null\n')

	>>> subprocess.run(["ls", "-l", "/dev/null"], stdout=subprocess.PIPE).stdout
	b'crw-rw-rw-  1 root  wheel    3,   2 Sep  2 18:16 /dev/null\n'

check error, and shell=True

	>>> subprocess.run("exit 1", shell=True)
	CompletedProcess(args='exit 1', returncode=1)

	>>> subprocess.run("exit 1", shell=True, check=True)
	Traceback (most recent call last):
	  File "<stdin>", line 1, in <module>
	  File "/usr/local/Cellar/python3/3.5.0/Frameworks/Python.framework/Versions/3.5/lib/python3.5/subprocess.py", line 711, in run
		output=stdout, stderr=stderr)
	subprocess.CalledProcessError: Command 'exit 1' returned non-zero exit status 1