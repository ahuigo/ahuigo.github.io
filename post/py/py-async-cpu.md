---
title: does-a-thread-waiting-on-io-also-block-a-core?
date: 2019-03-08
---
# does-a-thread-waiting-on-io-also-block-a-core
> Refer to: https://stackoverflow.com/questions/35688553/does-a-thread-waiting-on-io-also-block-a-core

A CPU core is normally not dedicated to one particular thread of execution. The kernel is constantly switching processes being executed in and out of the CPU. The process currently being executed by the CPU is in the "running" state. The list of processes waiting for their turn are in a "ready" state. The kernel switches these in and out very quickly. Modern CPU features (multiple cores, simultaneous multithreading, etc.) try to increase the number of threads of execution that can be physically executed at once.

If a process is I/O blocked, the kernel will just set it aside (put it in the "waiting" state) and not even consider giving it time in the CPU. When the I/O has finished, the kernel moves the blocked process from the "waiting" state to the "ready" state so it can have its turn ("running") in the CPU.

So your blocked thread of execution blocks only that: the thread of execution. The CPU and the CPU cores continue to have other threads of execution switched in and out of them, and are not idle.