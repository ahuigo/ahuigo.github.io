---
title: user
date: 2018-10-04
---
# user

	get_current_user() Gets PHP script owner's name
	getmyuid() - Gets PHP script owner's UID
	getmygid() - Get PHP script owner's GID The user who *owns the file* containing the current script , not the user who running
	getmyinode() - Gets the inode of the current script
	getlastmod() - Gets time of last page modification

	getmypid() - Gets PHP's process ID
	Thread::getCurrentThreadId()

Get user php is running as:

	echo exec('whoami');

# Disk

	filesize
	float disk_free_space(str $dir); //返回目录所在分区剩余大小
	float disk_total_space(str $dir); //返回目录所在分区大小

# Memory

	memory_get_usage($real_usage = false); //false 返回emalloc分配的内存; true:返回操作OS分配的内存:real_size
	memory_get_peak_usage($real_usage = false); //内存峰值

# Cpu

	$dat=getrusage();
	foreach ($dat as $key => $val) {
		$usertime= $dat['ru_utime.tv_usec'];
		$systemtime= $dat['ru_stime.tv_usec'];
		$finalresultcpu= ($systemtime + $usertime);
	}


# Shell

## gethostname

	gethostname();
	php_uname('n')

## argv

	getopt($options, array $longopts)
	-options
			该字符串中的每个字符会被当做选项字符，匹配传入脚本的选项以单个连字符(-)开头。 比如，一个选项字符串 "x" 识别了一个选项 -x。 只允许 a-z、A-Z 和 0-9。
				单独的字符（不接受值）
				后面跟随冒号的字符（此选项需要值）
				后面跟随两个冒号的字符（此选项的值可选）
	--longopts

example

	$shortopts  = "";
	$shortopts .= "f:";  // Required value
	$shortopts .= "v::"; // Optional value
	$shortopts .= "abc"; // These options do not accept values

	$longopts  = array(
	    "required:",     // Required value
	    "optional::",    // Optional value
	    "option",        // No value
	    "opt",           // No value
	);
	$options = getopt($shortopts, $longopts);
	var_dump($options);

通过 `php script.php -f "value for f" -v -a --required value --optional="optional value" --option` 运行以上脚本会输出：

	array(6) {
	  ["f"]=>
	  string(11) "value for f"
	  ["v"]=>
	  bool(false)
	  ["a"]=>
	  bool(false)
	  ["required"]=>
	  string(5) "value"
	  ["optional"]=>
	  string(14) "optional value"
	  ["option"]=>
	  bool(false)
	}

## 转义

	str escapeshellarg($arg); //将args转义为有效参数: 比如`abc`, 转义成`'abc'`
	str escapeshellcmd($cmd); //转义cmd中的特殊字符：| ; & > \x0a ....

## 执行

	passthru($cmd, [$errno]); //直接打印输出
	$output = shell_exec($cmd); // 相当于反引号 $output = `$cmd`
	$output = system($cmd[, $errno]); //也会直接打印输出
	$lastline = exec($cmd[, $output, [, $errno]])

shell_exec 等价于反引号:

	echo `ls`;
	echo `'ls'`;
	echo `"ls"`;
	echo `$cmd`;

## pipe

	<?php
	$descriptorspec = array(
		0 => array("pipe", "r"),  // stdin is a pipe that the child will read from
		1 => array("pipe", "w"),  // stdout is a pipe that the child will write to
		//2 => array("file", "/tmp/error-output.txt", "a") // stderr is a file to write to
		2 => array("file", "a.txt", "a") // stderr is a file to write to
	);
	$process = proc_open('php', $descriptorspec, $pipes, $cwd =null, $env =['env1' => 'cookie']);
	if (is_resource($process)) {
		fwrite($pipes[0], '<?php print_r($_ENV); ?>');
		fclose($pipes[0]);

		echo stream_get_contents($pipes[1]);
		fclose($pipes[1]);

		// It is important that you close any pipes before calling
		// proc_close in order to avoid a deadlock
		$return_value = proc_close($process);

		echo "command returned $return_value\n";
	}

non-block

	//stream_set_blocking($pipes[0],false);
	//stream_set_blocking(fopen('php://input', 'r'),false); //# input is for HTTP_RAW_POST_DATA
	stream_set_blocking($pipes[1],false);
	stream_set_blocking($pipes[2],false);
	while( true ) {
		$read= array();
		if( !feof($pipes[1]) ) $read[]= $pipes[1];
		if( !feof($pipes[2]) ) $read[]= $pipes[2];
		if (!$read) break;

		$ready= stream_select($read, $write=NULL, $ex= NULL, 2);
		if ($ready === false) {
			break; #should never happen - something died
		}

		foreach ($read as $r) {
			$s= fread($r,1024);
			$output.= $s;
		}
	}

non-block + timeout

    execute("program --option", null, $out, $out, 30);
    echo $out;

	/**
	 * Notice: $cmd = 'cmd1|cmd2', cmd 1 cannot be TERMINATED!
	 */
    function execute($cmd, &$stdout, &$stderr, $timeout=false, $stdin=null) {
        $pipes = array();
        $process = proc_open(
            $cmd,
            array(array('pipe','r'),array('pipe','w'),array('pipe','w')),
            $pipes
        );
        $start = time();
        $stdout = '';
        $stderr = '';

        if(is_resource($process)) {
            stream_set_blocking($pipes[0], 0);
            stream_set_blocking($pipes[1], 0);
            stream_set_blocking($pipes[2], 0);
            fwrite($pipes[0], $stdin);
            fclose($pipes[0]);
        }

        while(is_resource($process)) {
            //echo ".";
            $stdout .= stream_get_contents($pipes[1]);
            $stderr .= stream_get_contents($pipes[2]);

            if($timeout !== false && time() - $start > $timeout) {
                proc_terminate($process, 9);
                return 1;
            }

            $status = proc_get_status($process);
            if(!$status['running']) {
                fclose($pipes[1]);
                fclose($pipes[2]);
                proc_close($process);
                return $status['exitcode'];
            }

            usleep(100000);
        }
        return 1;
    }

## master kill
master kill 不会结束子进程

	`sleep 1&`; # block
	`sleep 1 &> out.txt &`;# non-block


# thread

    Thread::getCurrentThreadId()