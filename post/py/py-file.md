---
title: Directory
date: 2018-09-28
---
# Directory
建议用Path 代替

## file property
os

### file exists: os

	os.path.exists(file)

### isfile, isdir: os

    os.path.isfile(path)
    os.path.isdir(path)

### file.stat

	import os
	st = os.stat(path)
    if st.st_uid == euid:
        return st.st_mode & stat.S_IRUSR != 0
    st_size

### access permision
Use the real uid/gid to test for access to a path.

	access(path, mode, *, dir_fd=None, effective_ids=False, follow_symlinks=True)
		mode
			Operating-system mode bitfield.  Can be F_OK to test existence,
			or the inclusive-OR of R_OK, W_OK, and X_OK.

example:

	if os.access(file, os.R_OK):
		# Do something
	else:
		if not os.access(file, os.R_OK):
			print(file, "is not readable")
		else:
			print("Something went wrong with file/dir", file)
		break

#### chmod

	os.chmod(path, mode)
	os.chown(path, uid, gid)

## mkdir/rename/delete/

	os.mkdir(dir,mode=511)
		os.makedirs(newDir/dir);//recursive
	os.rmdir('/Users/michael/testdir')
        import shutil
        shutil.rmtree('/path/to/your/dir/'); # recursive

### rename file:

	os.rename(fileA_or_dirA, existedDir/fileB)
	os.move(fileA, existedDir/fileB)
		os.renames('dirA', 'newDir/DirB')//auto create dir
		os.renames('a', 'c/')// rename a to c (rmdir c if c is existed)

> `shutil.move()` uses `os.rename()` if the destination is on the current filesystem.
Otherwise, `shutil.move()` copies the source to destination using `shutil.copy2()` and then removes the source.

### copy file
shutil模块提供了copyfile()的函数，你还可以在shutil模块中找到很多实用函数，它们可以看做是os模块的补充。

`copy2` is also often useful, it preserves the `original modification and access info (mtime and atime)` in the file metadata.

	shutil.copyfile(src, existedDir/dst)
	shutil.copy2(src, existedDir/dst)

### remove file

	os.rmdir(empty_dir);	//empty dir
		shutil.rmtree(dir_only)
	os.remove(file_only);	//file_only

## mkfile fifo

	os.mkfifo(path, mode=438, *, dir_fd=None)
        Create a "fifo" (a POSIX named pipe).

## touch file
	with open("empty.txt", "w") as f:
		f.write("")

	Path("empty.txt").write_file("")

## listdir

### via os.listdir

	>>> [x for x in os.listdir('.') if os.path.isfile(x) and os.path.splitext(x)[1]=='.py']
	['apis.py', 'config.py', 'models.py', 'pymonitor.py', 'test_db.py', 'urls.py', 'wsgiapp.py']

### via glob.glob
Starting with Python version 3.5, the glob module supports the `"**"` directive for recursive
(which is parsed only if you pass `recursive flag`):

	import glob
	glob.glob(pathname, *, recursive=False); # list
	glob.iglob(pathname, *, recursive=False); # iterator

	for filepath in glob.iglob('src/**/*.c', recursive=True):
		print(filepath)

If you need an list, just use `glob.glob` instead of `glob.iglob` with iterator

## pathinfo

### dirname:

	path = os.path.dirname(amodule.__file__)
	path = Path('file').parent.absolute()

### abspath/relpath:
绝对/相对、link/real

	>>> os.path.join('/Users/michael', 'testdir')
	'/Users/michael/testdir'

Get absolute/relative path

    os.path.abspath(filepath)
    os.path.relpath(filepath, Commprefix)

Get symbolic link and real path

    os.readlink(filepath)
    os.path.realpath(filepath)

islink:

    os.path.islink(filepath)

1. abspath: simply removes things like . and .. 
2. realpath: removes things like . and .., and symbolic link
3. relative path:
	1. print os.path.commonprefix(['/usr/var/log', '/usr/var/security'])
		'/usr/var'
	2. os.path.relpath('/usr/var/a.xt', '/usr') 
        var/a.xt
	3. Path('/usr/var/a.xt').relative_to(common_prefix) 

### current directory
change current workspace:  support abspath only

	path = Path('/etc')
	os.chdir(path)

	os.getcwd()
	os.path.abspath('.')
	os.path.abspath(amodule.__file__)
	os.chroot(path)

current file's dir:

	os.path.realpath(__file__)

### split pathinfo

	>>> os.path.split('/Users/michael/testdir/file.txt')
	('/Users/michael/testdir', 'file.txt')

	>>> os.path.splitext('/path/to/file.txt')
	('/path/to/file', '.txt')

# File stream

    sys.stdout.write('stm') # return number of characters
    print sys.stdin.read()
	print open('a.php').read(); //cat a.php

## lock

    import fcntl
    new_entry = "foobar"
    with open("/somepath/somefile.txt", "a") as g:
        fcntl.flock(g, fcntl.LOCK_EX)
        g.write(new_entry)
        fcntl.flock(g, fcntl.LOCK_UN)

### append is atomic?
对于POSIX-compliant components:
1. under the size of 'PIPE_BUF' is supposed to be atomic. (linux 4096)

## IOError

	import glob, os
	try:
		for file in glob.glob("\\*.txt"):
			with open(file) as fp:
				# do something with file
	except IOError:
		print("could not read", file)


## Open File

	fp = open(filename[, mode])
	mode:
		'r' 'w' 'a'
		append a '+' to the mode to allow simultaneous reading and writing
			'r+' read and write
			'w+' empty old content and write
			'a+' read and append
		append a 'U' to the mode open a file for input with universal new line support('\r', '\n', '\r\n')
			 'U' cannot be combined with 'w' or '+' mode.
	fp.close()

### stdin file
参考  python-io.md

	import fileinput
	for line in fileinput.input():
		print(line)

### binary

	>>> f = open('/Users/michael/test.jpg', 'rb')
	>>> f.read()
	b'\xff\xd8\xff\xe1\x00\x18Exif\x00\x00...' # 十六进制表示的字节
	>>> f = open('/Users/michael/test.json', 'r')

### file encoding

	open('a.txt').encoding; # utf8(default)

用gbk 打开且忽略非法编码

	>>> f = open('/Users/michael/gbk.txt', 'r', encoding='gbk', errors='ignore')
	open('a.txt', 'rb').read().decode('gbk')

## read and write
> pydoc file

	fp.read()	Return file content.
	fp.readline()	Return just one line of text file.
	fp.readlines() === list(fp)	Return just one line of text file.
		for line in fp
		while line:
			line = fp.readline()
	fp.write(string)	Writes string to file(start at file position)
	fp.writelines(string or array);	str === ''.join(array)
	fp.truncate(...)
		truncate([size]) -> None.  Truncate the file to at most size bytes.
		Size defaults to the current file position, as returned by tell().

Example:

	fp = open('a.txt')
	fp.read()
	fp.close();

## close file
由于文件读写时都有可能产生IOError，一旦出错，后面的f.close()就不会调用。
所以，为了保证无论是否出错都能正确地关闭文件，我们可以使用try ... finally来实现：

	try:
		f = open('/path/to/file', 'r')
		print(f.read())
	finally:
		if f:
			f.close()

但是每次都这么写实在太繁琐，所以，Python引入了with语句来自动帮我们调用close()方法：

	with open('/path/to/file', 'r') as f:
		print(f.read())

## file position
`pydoc file`

	fp.tell(...)
		tell() -> current file position, an integer (may be a long integer).
	.seek(...)
		.seek(offset[, whence]) -> None.  Move to new file position.
		Optional argument whence defaults to:
			0 (offset from start of file, offset should be >= 0);
			1 (move relative to current position, positive or negative),
			2 (move relative to end of file, usually negative, 
            If the file is opened in text mode, only offsets returned by tell() are legal.  

        tail 100 char of file:
            fp.seek(fp.seek(0, 2)-100)
            

### line position

	def seek_line(f, line):
		f.seek(0);
        line -= 1
		while(line >0):
			f.getline();

### get specify line    

    >>> import linecache
    >>> linecache.getline(linecache.__file__, 8)
    'one line example\n'