---
layout: page
title:	php 文件管理
category: blog
description:
---
# Preface
以下是php文件管理函数归纳

# 文件属性（file attribute）

    filetype($path) block(块设备:分区，软驱，光驱) char(字符设备键盘打打印机) dir file fifo （命名管道，用于进程之间传递信息） link unknown
    file_exits() 文件存在性
    filesize() 返回文件大小（字节数,用pow()去转化 为MB吧）
    is_readable()检查是否可读
    is_writeable()检查是否可写
    is_excuteable()检查是否可执行
    filectime()检查文件创建的时间
    filemtime()检查文件的修改时间
    fileatime()检查文件访问时间
    stat()获取文件的属性值
    0 dev device number - 设备名
    1 ino inode number - inode 号码
    2 mode inode protection mode - inode 保护模式
    3 nlink number of links - 被连接数目
    4 uid userid of owner - 所有者的用户 id
    5 gid groupid of owner- 所有者的组 id
    6 rdev device type, if inode device * - 设备类型，如果是 inode 设备的话
    7 size size in bytes - 文件大小的字节数
    8 atime time of last access (unix timestamp) - 上次访问时间（Unix 时间戳）
    9 mtime time of last modification (unix timestamp) - 上次修改时间（Unix 时间戳）
    10 ctime time of last change (unix timestamp) - 上次改变时间（Unix 时间戳）
    11 blksize blocksize of filesystem IO * - 文件系统 IO 的块大小
    12 blocks number of blocks allocated - 所占据块的数目

## stat

	function alt_stat($file) {

		clearstatcache();
		$ss=@stat($file);

		$ts=array(
		  0140000=>'ssocket',
		  0120000=>'llink',
		  0100000=>'-file',
		  0060000=>'bblock',
		  0040000=>'ddir',
		  0020000=>'cchar',
		  0010000=>'pfifo'
		);

		$t=decoct($ss['mode'] & 0170000); // File Encoding Bit

# Dir, 文件目录

## Path

### Pathinfo

	pathinfo()返回一个数组‘dirname’,'basename’,'filename', 'extension’
	realpath('.');
    dirname()
	basename();filename+.+extension

### File location

	__DIR__ //脚本目录
	getcwd();//当前目录
    __FILE__
	realpath($file); //获取链接文件的绝对路径


Refer to: [](/p/linux-nginx)


## Dir Access
opendir:

    $dirp=opendir()
    readdir($dirp);结尾时返回false
    rewinddir($dirp);返回目录开头
    closedir($dirp);

dir:

	$d = dir(".");
	echo "Path: " . $d->path . "\n";
	while ($entry = $d->read()) {
	   echo $entry."\n";
	}
	$d->close();

### Match file
用`glob` 代替`opendir` 浏览文件

	foreach (glob("*.txt") as $filename) {
		echo "$filename size " . filesize($filename) . "\n";//a.txt
	}

## Dir Operation

    mkdir ( string $pathname [, int $mode [, bool $recursive [, resource $context ]]] )
    rmdir($pathname);必须为空
    rename($old, $new)

### Foreach Directory
Via shell for:

	for file in `ls .` ;do { echo $file; } done
	for file in `find .` ;do { echo $file} done

Via shell while :

	while read file;do
		iconv -f gbk -t utf8 $file > dir/$file
	done <(ls dir/*.txt);

Via DirectoryIterator 针对目录的迭代类(php)

	foreach (new DirectoryIterator('../moodle') as $index => $fileInfo) {
		if($fileInfo->isFile())
		echo $fileInfo->getFilename() . "\n";
		echo $fileInfo->getPath() . "\n";
		echo $fileInfo->getPathName() . "\n";
	}

Via RecursiveIteratorIterator(Recursive)(php)

	$files = new RecursiveIteratorIterator(new RecursiveDirectoryIterator('.'), RecursiveIteratorIterator::SELF_FIRST);
	foreach($files as $pathname => $file){
		if($file->isFile()){echo $pathname."\n";}
	}

Via RegexIterator on RecursiveIteratorIterator(filter key(filename) with Regex):

	$Directory = new RecursiveDirectoryIterator('.');
	$Iterator = new RecursiveIteratorIterator($Directory);//不用则不会递归
	$Regex = new RegexIterator($Iterator, '/\.php$/i', RegexIterator::GET_MATCH); // It matches against (string)$fileobj
	foreach($Regex as $filepath=>$matches){
		echo "$filepath\n";
		var_export($matches);//.php
	}

	RecursiveRegexIterator::GET_MATCH
		like $matches in preg_match: array(0=>\.php)
	RecursiveRegexIterator::MATCH: default
		get $SplFileInfo
            ->pathName
            ->fileName

# Upload File

    'a' => '@a.png'
	move_uploaded_file($_FILES['a']['tmp_name'], $dir.$file))

    'a[0]' => '@a.png'
	move_uploaded_file($_FILES['a']['tmp_name'][0], $dir.$file))

# File Operation

## temp file

	//create tmp uniq file
	$tmpfname = tempnam(sys_get_temp_dir(), 'pre_'); // good

	//create tmp file handler
	$temp = tmpfile();
	fwrite($temp, "writing to tempfile");
	fseek($temp, 0);
	$file = stream_get_meta_data($temp)['uri'];

## copy

	copy('src.txt', 'dst.txt');//force copy file

## merge and split
合并:

	$dst = fopen('dst.bin', 'w');
	$fps = [
		fopen('a.txt','r'),
		fopen('b.txt','r'),
	]
	foreach($fps as $fp){
		stream_copy_to_stream($fp, $dst);
	}

分片:

	$src = fopen('http://www.example.com', 'r');
	$dest1 = fopen('first1k.txt', 'w');
	$dest2 = fopen('remainder.txt', 'w');

	echo stream_copy_to_stream($src, $dest1, 1024) . " bytes copied to first1k.txt\n";
	echo stream_copy_to_stream($src, $dest2) . " bytes copied to remainder.txt\n";

## Open：

    fopen ( string $filename , string $mode [, bool $use_include_path [, resource $zcontext ]] )
    ‘r’ 只读方式打开，将文件指针指向文件头。
    ‘r+’ 读写方式打开，将文件指针指向文件头。
    ‘w’ 写入方式打开，将文件指针指向文件头并将文件大小截为零。如果文件不存在则尝试创建之。
    ‘w+’ 读写方式打开，将文件指针指向文件头并将文件大小截为零。如果文件不存在则尝试创建之。
    ‘a’ 写入方式打开，将文件指针指向文件末尾。如果文件不存在则尝试创建之。
    ‘a+’ 读写方式打开，将文件指针指向文件末尾。如果文件不存在则尝试创建之。
    ‘x’ 创建并以写入方式打开，将文件指针指向文件头。如果文件已存在，则 fopen() 调用失败并返回 FALSE，并生成一条 E_WARNING 级别的错误信息。如果文件不存在则尝试创建之。这和给 底层的 open(2) 系统调用指定 O_EXCL|O_CREAT 标记是等价的。此选项被 PHP 4.3.2 以及以后的版本所支持，仅能用于本地文件。
    ‘x+’ 创建并以读写方式打开，将文件指针指向文件头。如果文件已存在，则 fopen() 调用失败并返回 FALSE，并生成一条 E_WARNING 级别的错误信息。如果文件不存在则尝试创建之。这和给 底层的 open(2) 系统调用指定 O_EXCL|O_CREAT 标记是等价的。此选项被 PHP 4.3.2 以及以后的版本所支持，仅能用于本地文件。

Windows 下提供了一个文本转换标记（’t'）可以透明地将 \n 转换为 \r\n。与此对应还可以使用 ‘b’ 来强制使用二进制模式，这样就不会转换数据。要使用这些标记，要么用 ‘b’ 或者用 ‘t’ 作为 mode 参数的最后一个字符。

> 多个进程 `a+`，会冲突吗？对于linux/mac 来说，不会

## Close

     fclose($fp);

## non-blocking
php stream reads are blocking operations by default. You can change that behavior with `stream_set_blocking()`. Like so:

	$file = isset($argv[1]) ? $argv[1] : 'php://stdin';
	$fd = fopen($file, 'r');
	stream_set_blocking($fd, false);
		while($line = fgets($fd)){
	}

## File:read - write

     fread ( int $handle , int $length )最长8192 –fwrite ( resource $handle , string $string [, int $length ] )
     fgets ( int $handle [, int $length=1024 ] ) 读取一行
     fgetss ( resource $handle [, int $length])读取一行并且去掉html+php标记
     fgetc();读取一个字符
	 //格式化
	 while($log = fscanf($handler, '%s-%d-%d')){
		list($name, $uid, $phone) = $log;
	 }
	 //csv
	 fgetcsv ( resource $handle [, int $length = 0 [, string $delimiter = ',' [, string $enclosure = '"' [, string $escape = '\\' ]]]] ); 读入一行并解析csv

	 var_dump(str_getcsv('abc,"cbd,"'));

其它：

	获取内容
	file_get_contents() —file_put_contents()
	返回行数组
	file( string $filename [, int $use_include_path [, resource $context ]] )
	输出一个文件
	readfile( string $filename [, bool $use_include_path [, resource $context ]] )
	文件截取
	ftruncate( resource $handle , int $size )，当$size=0,文件就变为空
	文件删除
	unlink();
	文件复制
	copy($src,$dst);

Access a.php , a.php include ../b.php, b.php include htm/c.php, in c.php

	file_put_contents('a.txt', 'a');// write to ./a.txt not to ../htm/a.txt


## foreach file
和DirectoryIterator 一样，继承了SplFileInfo
它用于遍历行，支持foreach/seek()/valid()/current()/next(); 包括换行符`0x0a`

	$file = new SplFileObject("b.php");
	foreach($file as $i=>$line){
		echo "$i:$line";//包含换行了
	}

> next 必须跟在current 后才能生吧!!!!! bug?

指定start, end

	//获取行[$start,$end)
	$file = new SplFileObject("b.php");
	$file->seek($start);
	$i=0;
	while($i++< $end - $start){
		$str .= $file->current();
	}

fgets

	$handle = fopen("inputfile.txt", "r");
	if ($handle) {
		while (($line = fgets($handle)) !== false) {
			// process the line read.
		}
		fclose($handle);
	}

> 最后有一个空白符, 即换行符都没有

## 指针移动

     ftell($fp);//Returns the current position of the file read/write pointer. 这是一个相对位置，append 模式下offset 是从0 开始
     fseek($fp,$offset[,SEEK_CUR OR SEEK_END OR SEEK_SET),SEEK_SET是默认值，SEEK_END时offset应该为负值
     可选。可能的值：
     SEEK_SET - 设定位置等于 offset 字节。默认。
     SEEK_CUR - 设定位置为当前位置加上 offset。(append 下SEEK_CUR 初始值也是0)
     SEEK_END - 设定位置为文件末尾加上 offset （要移动到文件尾之前的位置，offset 必须是一个负值）。

1. `a, a+` 在每次fwrite/init 后会将: `SEEK_CUR` 初始化为0
2. fseek() 在超出边界后会返回-1(但是指针变了)， 再次调用fseek 不会成功(指针也不会变). 建议使用前先用`ftell` 获取当前位置

	$file = 'a.txt';
	var_dump($pos = startPos($file));
	startPos($file, ++$pos);

	function startPos($fn, $pos = null){
		static $fp;
		$posFile = "$fn.pos";
		if($fp === null){
			$fp = fopen($posFile, 'a+');
		}
		if($pos !== null){
			fwrite($fp, $pos."\n");
		}else{
			$p = 10;
			fseek($fp, -$p, SEEK_END);
			$str = trim(fread($fp, $p));
			$arr = explode("\n", $str);
			return (int)end($arr);
		}
	}

# 并发访问中的文件锁

     flock ( int $handle , int $operation [, int &$wouldblock ] )
	 $operation
     	flock($f, LOCK_SH); 默认值, 没有意义? 不是的，当LOCK_EX 时，这句会返回失败
     	flock($f, LOCK_EX) 独占锁，带阻塞等待
     	flock($f, LOCK_EX | LOCK_NB) or die('Another process is running!'); 独占锁，不阻塞
     	flock($f, LOCK_UN); 释锁
	$wouldblock
		遇到阻塞时会被设为1

可以用`php -a` 开两个进程测试a.txt

	if(isset($_GET['sleep'])) sleep(8);
	function lock($id, $maxProcess)
        static $fp;
        if($fp === null){
			$pid = mt_rand(1, $maxProcess);
            $lockfile = "/task/$id-$pid";
            $this->createDir(dirname($lockfile));
            $fp = fopen($lockfile, 'a');
        }
        $lock = flock($fp, LOCK_EX | LOCK_NB);
        return $lock;
	}

# 上传下载

## 上传

1.1表单：enctype="multipart/form-data"

     array(1) {
     ["upload"]=>array(5) {
		 ["name"]=>array(3) {
			 [0]=>string(9)"file0.txt"
			 [1]=>string(9)"file1.txt"
			 [2]=>string(9)"file2.txt"
		 }
		 ["type"]=>array(3) {
			 [0]=>string(10)"text/plain"
			 [1]=>string(10)"text/plain"
			 [2]=>string(10)"text/plain"
		 }
		 ["tmp_name"]=>array(3) {
			 [0]=>string(14)"/tmp/blablabla"
			 [1]=>string(14)"/tmp/phpyzZxta"
			 [2]=>string(14)"/tmp/phpn3nopO"
		 }
		 ["error"]=>array(3) {
			 [0]=>int(0)
			 [1]=>int(0)
			 [2]=>int(0)
		 }
		 ["size"]=>array(3) {
			 [0]=>int(0)
			 [1]=>int(0)
			 [2]=>int(0)
		 }
     }
     }

1.2处理上传

     move_uploaded_file($from, $to);

## 下载

     header("Content-Type:application/octet-stream"); //打开始终下载的mimetype
     header("Content-Disposition: attachment; filename=文件名.后缀名");
     // 文件名.后缀名 换成你的文件名这里的文件名是下载后的文件名，和你的源文件名没有关系。
     header("Pragma: no-cache"); // 缓存
     header("Expires: 0″);
     header("Content-Length:3390″);
     记得加enctype="multipart/form-data"

# library

## getLineCount

	function getLineCount($file = 'largeFile.txt'){
		$linecount = 0;
		$handle = fopen($file, "r");
		while(!feof($handle)){
		  $line = fgets($handle, 4096);
		  $linecount = $linecount + substr_count($line, PHP_EOL);
		}

		fclose($handle);
		return $linecount;
	}

## html

	php -r 'highlight_file("a.php");

## tar

	$phar = new PharData('myphar.tar');
	$phar->extractTo('/full/path'); // extract all files
	$phar->extractTo('/another/path', 'file.txt'); // extract only file.txt
	$phar->extractTo('/this/path',
		array('file1.txt', 'file2.txt')); // extract 2 files only
	$phar->extractTo('/third/path', null, true); // extract all files, and overwrite
