---
layout: page
title:	php multi process
category: blog
description:
---
# Preface
PHP多进程编程初步

> php 不支持多线程，不过PHP 5.3 以上版本，使用pthreads PHP扩展，可以使PHP真正地支持多线程。 Refer: http://zyan.cc/pthreads/

1. 准备

	$ php -m

这个命令检查并打印当前PHP所有开启的扩展，看一下pcntl和posix是否在输出的列表中。

1.1. pcntl
pcntl 提供fork 支持, 你很可能没有pcntl. 在编译的时候记得加上--enable-pcntl参数即可。

	$ cd /path/to/php_source_code_dir
	$ ./configure [some other options] --enable-pcntl
	$ make && make install

1.2. posix
一般默认就会装上，只要你编译的时候没有加上--disable-posix。

# fork

## create fork

创建一个PHP脚本：

	$pid = pcntl_fork(); // 一旦调用成功，事情就变得有些不同了
	echo "$pid \n";//
	if ($pid <= -1) {
		die('fork failed');
	} else if ($pid == 0) {
		//子进程
	} else {
		//父进程
	}

pcntl_fork()函数创建一个子进程，子进程和父进程唯一的区别就是PID（进程ID）和PPID（父进程ID）不同。

	67789 # 这个是父进程打印的
	0     # 这个是子进程打印的

pcntl_fork()函数调用成功后，在父进程中会返回子进程的PID，而在子进程中返回的是0。所以，下面直接用if分支来控制父进程和子进程做不同的事。

## 分配任务

然后我们来说说鸣人16岁那次影分身的事儿，给原身和分身分配两个简单的输出任务：

$parentPid = getmypid(); // 这就是传说中16岁之前的记忆
$pid = pcntl_fork(); // 一旦调用成功，事情就变得有些不同了
if ($pid == -1) {
    die('fork failed');
} else if ($pid == 0) {
    $mypid = getmypid(); // 用getmypid()函数获取当前进程的PID
    echo 'I am child process. My PID is ' . $mypid . ' and my father's PID is ' . $parentPid . PHP_EOL;
} else {
    echo 'Oh my god! I am a father now! My child's PID is ' . $pid . ' and mine is ' . $parentPid . PHP_EOL;
}
输出的结果可能是这样：

Oh my god! I am a father now! My child's PID is 68066 and mine is 68065
I am child process. My PID is 68066 and my father's PID is 68065
再强调一下，pcntl_fork()调用成功以后，一个程序变成了两个程序：一个程序得到的$pid变量值是0，它是子进程；另一个程序得到的$pid的值大于0，这个值是子进程的PID，它是父进程。在下面的分支语句中，由于$pid值的不同，运行了不同的代码。再次强调一下：子进程的代码和父进程的是一样的。所以就要通过分支语句给他们分配不同的任务。

## 子进程回收

刚刚有man ps么？一般我习惯用ps aux加上grep命令来查找运行着的后台进程。其中有一列STAT，标识了每个进程的运行状态。这里，我们关注状态Z：僵尸（Zombie）。当子进程比父进程先退出，而父进程没对其做任何处理的时候，子进程将会变成僵尸进程。Oops，又跟火影里的影分身不一样了。鸣人的影分身被干死了以后就自动消失了，但是这里的子进程分身死了话还留着一个空壳在，直到父进程回收它。僵尸进程虽然不占什么内存，但是很碍眼，院子里一堆躺着的僵尸怎么都觉得怪怪的。（别忘了它们还占用着PID）

一般来说，在父进程结束之前回收挂掉的子进程就可以了。在pcntl扩展里面有一个pcntl_wait()函数，它会将父进程挂起，直到有一个子进程退出为止。如果有一个子进程变成了僵尸的话，它会立即返回。所有的子进程都要回收，所以多等等也没关系啦！

## 父进程先挂了

如果父进程先挂了怎么办？会发生什么？什么也不会发生，子进程依旧还在运行。但是这个时候，子进程会被交给1号进程，1号进程成为了这些子进程的继父。1号进程会很好地处理这些进程的资源，当它们结束时1号进程会自动回收资源。所以，另一种处理僵尸进程的临时办法是关闭它们的父进程。

# 3. 信号

一般多进程的事儿讲到上面就完了，可是信号在系统中确实是一个非常重要的东西。信号就是信号灯，点亮一个信号灯，程序就会做出反应。这个你一定用过，比如说在终端下运行某个程序，等了半天也没什么反应，可能你会按 Ctrl+C 来关闭这个程序。实际上，这里就是通过键盘向程序发送了一个中断的信号：SIGINT。有时候进程失去响应了还会执行kill [PID]命令，未加任何其他参数的话，程序会接收到一个SIGTERM信号。程序收到上面两个信号的时候，默认都会结束执行，那么是否有可能改变这种默认行为呢？必须能啊！

## 3.1. 注册信号

人是活的程序也是活的，只不过程序需要遵循人制定的规则来运行。现在开始给信号重新设定规则，这里用到的函数是pcntl_signal()（继续之前为啥不先查查PHP手册呢？）。下面这段程序将给SIGINT重新定义行为，注意看好：

// 定义一个处理器，接收到SIGINT信号后只输出一行信息
function signalHandler($signal) {
    if ($signal == SIGINT) {
        echo 'signal received' . PHP_EOL;
    }
}
// 信号注册：当接收到SIGINT信号时，调用signalHandler()函数
pcntl_signal(SIGINT, 'signalHandler');
while (true) {
    sleep(1);
    // do something
    pcntl_signal_dispatch(); // 接收到信号时，调用注册的signalHandler()
}
执行一下，随时按下 Ctrl+C 看看会发生什么事。

## 3.2. 信号分发

说明一下：pcntl_signal()函数仅仅是注册信号和它的处理方法，真正接收到信号并调用其处理方法的是pcntl_signal_dispatch()函数。试试把// do something替换成下面这段代码：

	for ($i = 0; $i < 1000000; $i++) {
		echo $i . PHP_EOL;
		usleep(100000);
	}

在终端下执行这个脚本，当它不停输出数字的时候尝试按下 Ctrl+C 。看看程序有什么响应？嗯……什么都没有，除了屏幕可能多了个^C以外，程序一直在不停地输出数字。因为程序一直没有执行到pcntl_signal_dispatch()，所以就并没有调用signalHandler()，所以就没有输出signal received。

## 3.3. 版本问题

如果认真看了PHP文档，会发现pcntl_signal_dispatch()这个函数是PHP 5.3以上才支持的，如果你的PHP版本大于5.3，建议使用这个方法调用信号处理器。5.3以下的版本需要在注册信号之前加一句：declare(ticks = 1);表示每执行一条低级指令，就检查一次信号，如果检测到注册的信号，就调用其信号处理器。想想就挺不爽的，干嘛一直都检查？还是在我们指定的地方检查一下就好。

## 4.4. 感受僵尸进程

现在我们回到子进程回收的问题上（差点忘了= ="）。当你的一个子进程挂了（或者说是结束了），但是父进程还在运行中并且可能很长一段时间不会退出。一个僵尸进程从此站起来了！这时，保护伞公司（内核）发现它的地盘里出现了一个僵尸，这个僵尸是谁儿子呢？看一下PPID就知道了。然后，内核给PPID这个进程（也就是僵尸进程的父进程）发送一个信号：SIGCHLD。然后，你知道怎么在父进程中回收这个子进程了么？提示一下，用pcntl_wait()函数。

## 4.5. 发送信号

希望刚刚有认真man过kill命令。它其实就是向进程发送信号，在PHP中也可以调用posix_kill()函数来达到相同的效果。有了它就可以在父进程中控制其他子进程的运行了。比如在父进程结束之前关闭所有子进程，那么fork的时候在父进程记录所有子进程的PID，父进程结束之前依次给子进程发送结束信号即可。

# 5. 实践

PHP的多进程跟C还是挺像的，搞明白了以后用其他语言写的话也大同小异差不多都是这么个情况。如果有空的话，尝试写一个小程序，切身体会一下个中滋味：

16岁的鸣人发送影分身，分出5个分身
每个分身随机生存10到30秒，每秒都输出点什么
保证原身能感受到分身的结束，然后开动另一个分身，保证最多有5个分身
不使用nohup，让原身在终端关闭后依旧能够运行
把分身数量（5）写进一个配置文件里，当给原身发送信号（可以考虑用SIGUSR1或SIGUSR2）时，原身读取配置文件并更新允许的分身最大数量
如果分身多了，关闭几个；如果少了，再分出来几个
提示：

- 用while循环保证进程运行，注意sleep以免100%的CPU占用
- 运行进程的终端被关闭时，程序会收到一个SIGHUP信号
- 可以用parse_ini_file()函数解析INI配置文件

http://www.pureweber.com/article/php-multi-process-programming-preview/
