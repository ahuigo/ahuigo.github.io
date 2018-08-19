---
layout: page
title:	PHP 的协程多任务
category: blog
description:
---
# Preface
学习了一下php 的基于yield 的多任务[Cooperative Multitasking]. 本文最终实现了这样一个*非阻塞(Non-Blocking)*且支持*协程调用栈(Stacked Coroutines)* 的*server demo*:

	curl https://raw.githubusercontent.com/ahui132/php-lib/master/yield/stacked-coroutine.php | php &;
	sleep 5; curl -d 'test' http://localhost:8000/

# Coroutines, 协程
php 的generator 不仅可以中断并返回值. 调用方(Caller) 还可以通过`send` 向generators 传值。这就实现了php 的协程(Coroutines)

> 对应到Python语言，单进程的异步编程模型称为协程，有了协程的支持，就可以基于事件驱动编写高效的多任务程序。我们会在后面讨论如何编写协程。

Coroutines 可以通过`send()` 实现向 generators 传值，这实现了主程(caller)与生成器(generator)之间的双向通信

	function gen() {
		$ret = (yield 'key1'=>'yield1');
		var_dump($ret);
		$ret = (yield 'yield2');
		var_dump($ret);
	}

	$gen = gen();
	var_dump([$gen->current(), $gen->key()]);    // string(6) "yield1" "key1"
	var_dump($gen->send('ret1')); // string(4) "ret1"   (the first var_dump in gen)
								  // string(6) "yield2" (the var_dump of the ->send() return value)
	var_dump($gen->send('ret2')); // string(4) "ret2"   (again from within gen)
								  // NULL               (the return value of ->send())

`send()` 实现了`next() + current()`，它使得`gen` 从`yield` 中断处重新开始执行。同时，yield 返回的值就是send 传送的值。

另一个例子:

	function logger($fileName) {
		$fileHandle = fopen($fileName, 'a');
		while (true) {
			fwrite($fileHandle, yield . "\n");
		}
	}

	$logger = logger(__DIR__ . '/log');
	$logger->send('Foo');
	$logger->send('Bar');

# cooperative multitasking, 多任务协作

- cooperative multitasking: currently running task *voluntarily* passes back control to the scheduler, so it can run another task.
- preemptive multitasking:  where the *scheduler* can *interrupt* the task after some time whether it likes it or not

早期的win95 和 MAC OS 采用的是cooperative multitasking, 这样的坏处是：
>  If you rely on a program to pass back control voluntarily, badly-behaving software can easily occupy the whole CPU for itself, not leaving a share for other tasks.

在php 中`yield` 提供了cooperative multitasking(a way for task to interrupt itself and pass control back to the scheduler). 而`send` 提供了 communication between the task and the scheduler.

	class Task {
		protected $taskId;
		protected $coroutine;
		protected $sendValue = null;
		protected $beforeFirstYield = true;

		public function __construct($taskId, Generator $coroutine) {
			$this->taskId = $taskId;
			$this->coroutine = $coroutine;
		}

		public function getTaskId() {
			return $this->taskId;
		}

		public function setSendValue($sendValue) {
			$this->sendValue = $sendValue;
		}

		public function run() {
			if ($this->beforeFirstYield) {
				$this->beforeFirstYield = false;
				return $this->coroutine->current();
			} else {
				$retval = $this->coroutine->send($this->sendValue);
				$this->sendValue = null;
				return $retval;
			}
		}

		public function isFinished() {
			return !$this->coroutine->valid();
		}
	}
	class Scheduler {
		protected $maxTaskId = 0;
		protected $taskMap = []; // taskId => task
		protected $taskQueue;

		public function __construct() {
			$this->taskQueue = new SplQueue();
		}

		public function newTask(Generator $coroutine) {
			$tid = ++$this->maxTaskId;
			$task = new Task($tid, $coroutine);
			$this->taskMap[$tid] = $task;
			$this->schedule($task);
			return $tid;
		}

		public function schedule(Task $task) {
			$this->taskQueue->enqueue($task);
		}

		public function run() {
			while (!$this->taskQueue->isEmpty()) {
				$task = $this->taskQueue->dequeue();
				$task->run();

				if ($task->isFinished()) {
					unset($this->taskMap[$task->getTaskId()]);
				} else {
					$this->schedule($task);
				}
			}
		}
	}

Lets try out scheduler with an example:

	function task1() {
		for ($i = 1; $i <= 10; ++$i) {
			echo "This is task 1 iteration $i.\n";
			yield;
		}
	}

	function task2() {
		for ($i = 1; $i <= 5; ++$i) {
			echo "This is task 2 iteration $i.\n";
			yield;
		}
	}

	$scheduler = new Scheduler;

	$scheduler->newTask(task1());
	$scheduler->newTask(task2());

	$scheduler->run();

Both tasks will just echo a message and then pass control back to the scheduler with yield. This is the resulting output:

	This is task 1 iteration 1.
	This is task 2 iteration 1.
	This is task 1 iteration 2.
	This is task 2 iteration 2.
	....

# Communicating between task and scheduler
How to Communicating between task and scheduler:

1. Historically the generic `int` interruption instruction was used,
2. Nowadays there are more specialized and faster `syscall/sysenter` instructions.

We will communicate via `system calls` passed through the `yield` expression. The yield here will act both as an interrupt and as a way to pass information to (and from) the scheduler.

To represent a system call I’ll use a small wrapper around a callable:

	class SystemCall {
		protected $callback;

		public function __construct(callable $callback) {
			$this->callback = $callback;
		}

		public function __invoke(Task $task, Scheduler $scheduler) {
			$callback = $this->callback; // Can't call it directly in PHP :/
			return $callback($task, $scheduler);
		}
	}

 To handle it we have to slightly modify the scheduler’s run method:

	public function run() {
		while (!$this->taskQueue->isEmpty()) {
			$task = $this->taskQueue->dequeue();
			$retval = $task->run();

			if ($retval instanceof SystemCall) {
				$retval($task, $this);
				continue;
			}

			if ($task->isFinished()) {
				unset($this->taskMap[$task->getTaskId()]);
			} else {
				$this->schedule($task);
			}
		}
	}

> SystemCall 用于Task 与 Scheduler 之间传递信息. Task 是不能直接调用Scheduler 的。而是以回调SystemCall 函数，被Scheduler 调用

The first system call will do nothing more than return the task ID:

	function getTaskId() {
		return new SystemCall(function(Task $task, Scheduler $scheduler) {
			$task->setSendValue($task->getTaskId());
			$scheduler->schedule($task);
		});
	}

> setSendValue 起到的作用是将$this->sendValue 作为task的 yield 的返回`$this->coroutine->send($this->sendValue);`

It does so by setting the tid as next send value and rescheduling the task. For system calls the scheduler does not automatically reschedule the task, we need to do it manually (you’ll see why a bit later).
Using this new syscall we can rewrite the previous example:

	function task($max) {
		$tid = (yield getTaskId()); // <-- here's the syscall!
		for ($i = 1; $i <= $max; ++$i) {
			echo "This is task $tid iteration $i.\n";
			yield;
		}
	}

	$scheduler = new Scheduler;

	$scheduler->newTask(task(10));
	$scheduler->newTask(task(5));

	$scheduler->run();

Whole code:

	class SystemCall {
		protected $callback;

		public function __construct(callable $callback) {
			$this->callback = $callback;
		}

		public function __invoke(Task $task, Scheduler $scheduler) {
			$callback = $this->callback; // Can't call it directly in PHP :/
			return $callback($task, $scheduler);
		}
	}
	function getTaskId() {
		return new SystemCall(function(Task $task, Scheduler $scheduler) {
			$task->setSendValue($task->getTaskId());
			$scheduler->schedule($task);
		});
	}
	class Task {
		protected $taskId;
		protected $coroutine;
		protected $sendValue = null;
		protected $beforeFirstYield = true;

		public function __construct($taskId, Generator $coroutine) {
			$this->taskId = $taskId;
			$this->coroutine = $coroutine;
		}

		public function getTaskId() {
			return $this->taskId;
		}

		public function setSendValue($sendValue) {
			$this->sendValue = $sendValue;
		}

		public function run() {
			if ($this->beforeFirstYield) {
				$this->beforeFirstYield = false;
				$r = $this->coroutine->current();
				var_dump($r);
				return $r;
			} else {
				$retval = $this->coroutine->send($this->sendValue);
				$this->sendValue = null;
				return $retval;
			}
		}
		public function isFinished() {
			return !$this->coroutine->valid();
		}
	}
	class Scheduler {
		protected $maxTaskId = 0;
		protected $taskMap = []; // taskId => task
		protected $taskQueue;

		public function __construct() {
			$this->taskQueue = new SplQueue();
		}

		public function newTask(Generator $coroutine) {
			$tid = ++$this->maxTaskId;
			$task = new Task($tid, $coroutine);
			$this->taskMap[$tid] = $task;
			$this->schedule($task);
			return $tid;
		}

		public function schedule(Task $task) {
			$this->taskQueue->enqueue($task);
		}

		public function run() {
			while (!$this->taskQueue->isEmpty()) {
				$task = $this->taskQueue->dequeue();
				$retval = $task->run();
				//var_dump(['task run reutn'=>$retval]);

				if ($retval instanceof SystemCall) {
					$retval($task, $this);
					continue;
				}

				if ($task->isFinished()) {
					unset($this->taskMap[$task->getTaskId()]);
				} else {
					$this->schedule($task);
				}
			}
		}

	}

	//Lets try out scheduler with an example:

	function task($max) {
		$tid = (yield getTaskId()); // <-- here's the syscall!
		var_dump(['getTask:tid'=>$tid]);
		for ($i = 1; $i <= $max; ++$i) {
			echo "This is task $tid iteration $i.\n";
			yield;
		}
	}

	$scheduler = new Scheduler;

	$scheduler->newTask(task(10));
	$scheduler->newTask(task(5));

	$scheduler->run();

This will give the same output as with the previous example. Notice how the system call is basically done like any other call, but with a prepended yield.

Two more syscalls for creating new tasks and killing them again:

	function newTask(Generator $coroutine) {
		return new SystemCall(
			function(Task $task, Scheduler $scheduler) use ($coroutine) {
				$task->setSendValue($scheduler->newTask($coroutine));
				$scheduler->schedule($task);
			}
		);
	}

	function killTask($tid) {
		return new SystemCall(
			function(Task $task, Scheduler $scheduler) use ($tid) {
				$task->setSendValue($scheduler->killTask($tid));
				$scheduler->schedule($task);
			}
		);
	}

The `killTask` function needs an additional method in the scheduler:

	public function killTask($tid) {
		if (!isset($this->taskMap[$tid])) {
			return false;
		}

		unset($this->taskMap[$tid]);

		// This is a bit ugly and could be optimized so it does not have to walk the queue,
		// but assuming that killing tasks is rather rare I won't bother with it now
		foreach ($this->taskQueue as $i => $task) {
			if ($task->getTaskId() === $tid) {
				unset($this->taskQueue[$i]);
				break;
			}
		}

		return true;
	}

A small script to test the new functionality:

	function childTask() {
		$tid = (yield getTaskId());
		while (true) {
			echo "Child task $tid still alive!\n";
			yield;
		}
	}

	function task() {
		$tid = (yield getTaskId());
		$childTid = (yield newTask(childTask()));

		for ($i = 1; $i <= 6; ++$i) {
			echo "Parent task $tid iteration $i.\n";
			yield;

			if ($i == 3) yield killTask($childTid);
		}
	}

	$scheduler = new Scheduler;
	$scheduler->newTask(task());
	$scheduler->run();

This will print the following:

	Parent task 1 iteration 1.
	Child task 2 still alive!
	Parent task 1 iteration 2.
	Child task 2 still alive!
	Parent task 1 iteration 3.
	Child task 2 still alive!
	Parent task 1 iteration 4.
	Parent task 1 iteration 5.
	Parent task 1 iteration 6.

> One Syscall could not include other Syscall

The complete code for [Cooperative-Multitask](https://raw.githubusercontent.com/ahui132/php-lib/master/yield/cooperative-multitask.php)

There are many more process management calls one could implement, for example wait (which waits until a task has finished running), exec (which replaces the current task) and fork (which creates a clone of the current task). Forking is pretty cool and you can actually implement it with PHP’s coroutines, because they support cloning.

But I’ll leave these for the interested reader. Instead lets get to the next topic!

# Non-Blocking IO
To find out which sockets are ready to read from or write to the `stream_select` function can be used.

First, lets add two new syscalls, which will cause a task to wait until a certain socket is ready:

	function waitForRead($socket) {
		return new SystemCall(
			function(Task $task, Scheduler $scheduler) use ($socket) {
				$scheduler->waitForRead($socket, $task);
			}
		);
	}

	function waitForWrite($socket) {
		return new SystemCall(
			function(Task $task, Scheduler $scheduler) use ($socket) {
				$scheduler->waitForWrite($socket, $task);
			}
		);
	}

These syscalls are just proxies to the respective methods in the scheduler:

	// resourceID => [socket, tasks]
	protected $waitingForRead = [];
	protected $waitingForWrite = [];

	public function waitForRead($socket, Task $task) {
		if (isset($this->waitingForRead[(int) $socket])) {
			$this->waitingForRead[(int) $socket][1][] = $task;
		} else {
			$this->waitingForRead[(int) $socket] = [$socket, [$task]];
		}
	}

	public function waitForWrite($socket, Task $task) {
		if (isset($this->waitingForWrite[(int) $socket])) {
			$this->waitingForWrite[(int) $socket][1][] = $task;
		} else {
			$this->waitingForWrite[(int) $socket] = [$socket, [$task]];
		}
	}


The `waitingForRead` and `waitingForWrite` properties are just arrays containing the sockets to wait for and the tasks that are waiting for them.
The interesting part is the following method, which actually checks whether the sockets are ready and reschedules the respective tasks:

	protected function ioPoll($timeout) {
		$rSocks = [];
		foreach ($this->waitingForRead as list($socket)) {
			$rSocks[] = $socket;
		}

		$wSocks = [];
		foreach ($this->waitingForWrite as list($socket)) {
			$wSocks[] = $socket;
		}

		$eSocks = []; // dummy

		if (!stream_select($rSocks, $wSocks, $eSocks, $timeout)) {
			return;
		}

		foreach ($rSocks as $socket) {
			list(, $tasks) = $this->waitingForRead[(int) $socket];
			unset($this->waitingForRead[(int) $socket]);

			foreach ($tasks as $task) {
				$this->schedule($task);
			}
		}

		foreach ($wSocks as $socket) {
			list(, $tasks) = $this->waitingForWrite[(int) $socket];
			unset($this->waitingForWrite[(int) $socket]);

			foreach ($tasks as $task) {
				$this->schedule($task);
			}
		}
	}

The stream_select function takes arrays of read, write and except sockets to check (we’ll ignore that last category). The arrays are passed by reference and the function will only leave those elements in the arrays that changed state. We can then walk over those arrays and reschedule all tasks associated with them.

In order to regularly perform the above polling action we’ll add a special task in the scheduler:

	protected function ioPollTask() {
		while (true) {
			if ($this->taskQueue->isEmpty()) {
				$this->ioPoll(null);
			} else {
				$this->ioPoll(0);
			}
			yield;
		}
	}

This task needs to be registered at some point, e.g. one could add `$this->newTask($this->ioPollTask())` to the start of the `run()` method. Then it will work just like any other task, performing the polling operation once every full task cycle (this isn’t necessarily the best way to handle it). The `ioPollTask` will call `ioPoll` with a `0 second timeout`, which means that `stream_select` will return right away (rather than waiting).

Only if the task queue is `empty` we use a `null timeout`, which means that it will wait until some socket becomes ready. If we wouldn’t do this the polling task would just run again and again and again until a new connection is made. This would result in 100% CPU usage. It’s much more efficient to let the operating system do the waiting instead.

Writing the server is relatively easy now:

	function server($port) {
		echo "Starting server at port $port...\n";

		$socket = @stream_socket_server("tcp://localhost:$port", $errNo, $errStr);
		if (!$socket) throw new Exception($errStr, $errNo);

		stream_set_blocking($socket, 0);

		while (true) {
			yield waitForRead($socket);
			$clientSocket = stream_socket_accept($socket, 0);
			yield newTask(handleClient($clientSocket));
		}
	}

	function handleClient($socket) {
		yield waitForRead($socket);
		$data = fread($socket, 8192);

		$msg = "Received following request:\n\n$data";
		$msgLength = strlen($msg);

		$response = <<<RES
	HTTP/1.1 200 OK\r
	Content-Type: text/plain\r
	Content-Length: $msgLength\r
	Connection: close\r
	\r
	$msg
	RES;

		yield waitForWrite($socket);
		fwrite($socket, $response);

		fclose($socket);
	}

	$scheduler = new Scheduler;
	$scheduler->newTask(server(8000));
	$scheduler->run();

> The complete code for [server-non-block](https://raw.githubusercontent.com/ahui132/php-lib/master/yield/server-non-block.php)

This will accept connections to `localhost:8000` and just send back a HTTP response with whatever it was sent.

You can try the server out using something like `ab -n 10000 -c 100 localhost:8000/`. This will send 10000 requests to it with 100 of them arriving concurrently. Using these numbers I get a median response time of 10ms.

But there is an issue with a few requests being handled really slowly (like 5 seconds), that’s why the total throughput is only 2000 reqs/s (with a 10ms response time it should be more like 10000 reqs/s). With higher concurrency count (e.g. -c 500) it mostly still works well, but some connections will throw a “Connection reset by peer” error.
As I know very little about this low-level socket stuff I didn’t try to figure out what the issue is.

# Stacked coroutines, 协程堆栈
If you use this scheduler system you will run into this problem: We are used to breaking up code into smaller functions and calling them. But with coroutines this is no longer possible. E.g. consider the following code:

	function echoTimes($msg, $max) {
		for ($i = 1; $i <= $max; ++$i) {
			echo "$msg iteration $i\n";
			yield;
		}
	}

	function task() {
		echoTimes('foo', 10); // print foo ten times
		echo "---\n";
		echoTimes('bar', 5); // print bar five times
		yield; // force it to be a coroutine
	}

	$scheduler = new Scheduler;
	$scheduler->newTask(task());
	$scheduler->run();

> 我们想让：ten times 结束后才开始 five times
> yield retval($v) 中的值$v, 其实是`return $v`, 要中断并传给父generator

This code tries to put the recurring “output n times” code into a separate coroutine and then invoke it from the main task. But this won’t work. As mentioned at the very beginning of this article calling a generator (or coroutine) will not actually do anything, it will only return an object.

In order to still allow this we need to write a small wrapper around the bare coroutines. I’ll call this a “stacked coroutine” because it will manage a stack of nested coroutine calls. It will be possible to call sub-coroutines by yielding them:

	$retval = (yield someCoroutine($foo, $bar));

The subcoroutines will also be able to return a value, again by using yield:

	yield retval("I'm a return value!");

The `retval` function does nothing more than returning a wrapper around the value which will signal that it’s a return value:

	class CoroutineReturnValue {
		protected $value;

		public function __construct($value) {
			$this->value = $value;
		}

		public function getValue() {
			return $this->value;
		}
	}

	function retval($value) {
		return new CoroutineReturnValue($value);
	}

In order to turn a coroutine into a stacked coroutine (which supports subcalls) we’ll have to write another function (which is obviously yet-another-coroutine):

	function stackedCoroutine(Generator $gen) {
		$stack = new SplStack;

		for (;;) {
			$value = $gen->current();

			if ($value instanceof Generator) {
				$stack->push($gen);
				$gen = $value;
				continue;
			}

			$isReturnValue = $value instanceof CoroutineReturnValue;
			if (!$gen->valid() || $isReturnValue) {
				if ($stack->isEmpty()) {
					return;
				}

				$gen = $stack->pop();
				$gen->send($isReturnValue ? $value->getValue() : NULL);
				continue;
			}

			$gen->send(yield $gen->key() => $value);
		}
	}

This function acts as a simple proxy between the `caller` and the `currently running subcoroutine`. This is handled in the `$gen->send(yield $gen->key() => $value);` line.
Additionally it checks whether a return value is a generator, in which case it will start running it and pushes the previous coroutine on the stack. Once it gets a CoroutineReturnValue it will pop the stack again and continue executing the previous coroutine.

In order to make the stacked coroutines usable in tasks the `$this->coroutine = $coroutine;` line in the `Task` constructor needs to be replaced with `$this->coroutine = stackedCoroutine($coroutine);`.

Now we can improve the webserver example from above a bit by grouping the `wait+read` (and wait+write and wait+accept) actions into functions. To group the related functionality I’'ll use a class:

	class CoSocket {
		protected $socket;

		public function __construct($socket) {
			$this->socket = $socket;
		}

		public function accept() {
			yield waitForRead($this->socket);
			yield retval(new CoSocket(stream_socket_accept($this->socket, 0)));
		}

		public function read($size) {
			yield waitForRead($this->socket);
			yield retval(fread($this->socket, $size));
		}

		public function write($string) {
			yield waitForWrite($this->socket);
			fwrite($this->socket, $string);
		}

		public function close() {
			@fclose($this->socket);
		}
	}

Now the server can be rewritten a bit cleaner:

	function server($port) {
		echo "Starting server at port $port...\n";

		$socket = @stream_socket_server("tcp://localhost:$port", $errNo, $errStr);
		if (!$socket) throw new Exception($errStr, $errNo);

		stream_set_blocking($socket, 0);

		$socket = new CoSocket($socket);
		while (true) {
			yield newTask(
				handleClient(yield $socket->accept())
			);
		}
	}

	function handleClient($socket) {
		$data = (yield $socket->read(8192));

		$msg = "Received following request:\n\n$data";
		$msgLength = strlen($msg);

		$response = <<<RES
	HTTP/1.1 200 OK\r
	Content-Type: text/plain\r
	Content-Length: $msgLength\r
	Connection: close\r
	\r
	$msg
	RES;

		yield $socket->write($response);
		yield $socket->close();
	}

The complete code for [stacked coroutine](https://raw.githubusercontent.com/ahui132/php-lib/master/yield/stacked-coroutine.php)

# Error handling
Coroutines provide the ability to throw exceptions inside them using the `throw()` method.

The throw() method takes an exception and throws it at the current suspension point in the coroutine. Consider this code:

	function gen() {
		echo "Foo\n";
		try {
			yield;
		} catch (Exception $e) {
			echo "Exception: {$e->getMessage()}\n";
		}
		echo "Bar\n";
	}

	$gen = gen();
	//$gen->rewind();                     // echos "Foo"
	$gen->throw(new Exception('Test')); // echos "Exception: Test"
										// and "Bar"

This is really awesome for our purposes, because we can make system calls and subcoroutine calls throw exceptions. For the system calls the `Scheduler::run()` method needs a small adjustment: via Scheduler

	if ($retval instanceof SystemCall) {
		try {
			$retval($task, $this);
		} catch (Exception $e) {
			$task->setException($e);
			$this->schedule($task);
		}
		continue;
	}

And the Task class needs to handle throw calls too: via Task

	class Task {
		// ...
		protected $exception = null;

		public function setException($exception) {
			$this->exception = $exception;
		}

		public function run() {
			if ($this->beforeFirstYield) {
				$this->beforeFirstYield = false;
				return $this->coroutine->current();
			} elseif ($this->exception) {
				$retval = $this->coroutine->throw($this->exception);
				$this->exception = null;
				return $retval;
			} else {
				$retval = $this->coroutine->send($this->sendValue);
				$this->sendValue = null;
				return $retval;
			}
		}
	}

Now we can start throwing exceptions from system calls! E.g. for the `killTask call`, lets throw an exception if the passed task ID is invalid:
Throw via SystemCall:

	function killTask($tid) {
		return new SystemCall(
			function(Task $task, Scheduler $scheduler) use ($tid) {
				if ($scheduler->killTask($tid)) {
					$scheduler->schedule($task);
				} else {
					throw new InvalidArgumentException('Invalid task ID!');
				}
			}
		);
	}

Try it out: Received Exception

	function task() {
		try {
			yield killTask(500);
		} catch (Exception $e) {
			echo 'Tried to kill task 500 but failed: ', $e->getMessage(), "\n";
		}
	}

Sadly this won’t work properly yet, because the `stackedCoroutine` function doesn’t handle the exception correctly.
To fix it the function needs some modifications:

	function stackedCoroutine(Generator $gen) {
		$stack = new SplStack;
		$exception = null;//self exception

		for (;;) {
			try {
				if ($exception) {
					$gen->throw($exception);
					$exception = null;
					continue;
				}

				$value = $gen->current();

				if ($value instanceof Generator) {
					$stack->push($gen);
					$gen = $value;
					continue;
				}

				$isReturnValue = $value instanceof CoroutineReturnValue;
				if (!$gen->valid() || $isReturnValue) {
					if ($stack->isEmpty()) {
						return;
					}

					$gen = $stack->pop();
					$gen->send($isReturnValue ? $value->getValue() : NULL);
					continue;
				}

				try {
					$sendValue = (yield $gen->key() => $value);//Received Exception
				} catch (Exception $e) {
					$gen->throw($e);
					continue;
				}

				$gen->send($sendValue);
			} catch (Exception $e) {
				if ($stack->isEmpty()) {
					throw $e;
				}

				$gen = $stack->pop();
				$exception = $e;
			}
		}
	}

# Ending
The resulting code for the tasks looks totally synchronous, even though it is performing a lot of asynchronous operations. If you want to read data from a socket you don’t have to pass some callback or register an event listener. Instead you write `yield $socket->read()`. Which is basically what you would normally do too, just with a yield in front of it.

When I first heard about all this I found this concept totally awesome and that’s what motivated me to implement it in PHP. At the same time I find coroutines really scary. There is a thin line between awesome code and a total mess and I think coroutines sit exactly on that line. It’s hard for me to say whether writing async code in the way outlined above is really beneficial.

In any case, I think it’s an interesting topic and I hope you found it interesting too. Comments welcome :)

# Reference
- [Cooperative Multitasking]

[Cooperative Multitasking]: http://nikic.github.io/2012/12/22/Cooperative-multitasking-using-coroutines-in-PHP.html
