# redis-benchmark

    redis-benchmark [-h <host>] [-p <port>] [-c <clients>] [-n <requests]> [-k <boolean>]
        -k 1=keep alive 0=reconnect(default 1)
        -r <keyspacelen>  Use random keys for SET/GET/INCR, range from 0 ~ keyspacelen -1

     Use 20 parallel clients, for a total of 100k requests, against 192.168.1.1:
       $ redis-benchmark -h 192.168.1.1 -p 6379 -n 100000 -c 20

     Fill 127.0.0.1:6379 with about 1 million keys only using the SET test:
       $ redis-benchmark -t set -n 1000000 -r 100000000

     Benchmark 127.0.0.1:6379 for a few commands producing CSV output:
       $ redis-benchmark -t ping,set,get -n 100000 --csv

     Benchmark a specific command line:
       $ redis-benchmark -r 10000 -n 10000 eval 'return redis.call("ping")' 0

     Fill a list with 10000 random elements:
       $ redis-benchmark -r 10000 -n 10000 lpush mylist "__rand_int__:asdf"

     On user specified command lines __rand_int__ is replaced with a random integer
     with a range of values selected by the -r option

## Running only a subset of the tests
The simplest thing to select only a subset of tests is to use the -t option

    $ redis-benchmark -t set,lpush -n 100000 -q
    SET: 74239.05 requests per second
    LPUSH: 79239.30 requests per second

It is also possible to specify the command to benchmark directly like in the following example:

    $ redis-benchmark -n 100000 -q script load "redis.call('set','foo','bar')"
    script load redis.call('set','foo','bar'): 69881.20 requests per second

## Selecting the size of the key space
By default the benchmark runs against a single key.
Using a random key for every operation out of 100k possible keys, I'll use the following command line:

    $ redis-cli flushall
    OK

    $ redis-benchmark -t set -r 100000 -n 1000000
    ====== SET ======
      1000000 requests completed in 13.86 seconds
      50 parallel clients
      3 bytes payload
      keep alive: 1

    99.76% `<=` 1 milliseconds
    99.98% `<=` 2 milliseconds
    100.00% `<=` 3 milliseconds
    100.00% `<=` 3 milliseconds
    72144.87 requests per second

    $ redis-cli dbsize
    (integer) 99993

## Using pipelining
> 多个请求合并为一条请求（pipelining）

By default every client (the benchmark simulates 50 clients if not otherwise specified with -c) sends the next command only when the reply of the previous command is received, this means that the server will likely *need a read call in order to read each command* from every client. Also RTT is paid as well.

Redis supports */topics/pipelining*, so it is possible to send *multiple commands at once*, a feature often exploited by real world applications. Redis pipelining is able to dramatically improve the number of operations per second a server is able do deliver.

using a pipelining of 16 commands:

    $ redis-benchmark -n 1000000 -t set,get -P 16 -q
    SET: 403063.28 requests per second
    GET: 508388.41 requests per second

Using pipelining results in a significant increase in performance.

## Pitfalls and misconceptions(陷阱与误区)
通过测试达不到最大吞吐量: 使用 pipelining 和更快的客户端（hiredis）可以达到更大的吞吐量(Throughput)。 redis-benchmark 默认情况下面仅仅使用并发来提高吞吐量（创建多条连接）。 它并没有使用 pipelining 或者其他并行技术（仅仅多条连接，而不是多线程）。

1. Redis 是一个服务器：所有的命令都包含网络或 IPC 消耗。
2. Redis 的大部分常用命令都有确认返回。把 Redis 和其他单向调用命令存储系统(如mongodb)比较意义不大。
3. 简单的循环操作只是测试你的网络（或者 IPC）延迟。基准测试需要使用多个连接（比如 redis-benchmark)， 或者使用 pipelining 来聚合多个命令，另外还可以采用多线程或多进程。
4. Redis 持久化功能对比的话， 那你需要考虑启用 AOF 和适当的 fsync 策略。
5. Redis 是单线程服务。它并没有设计为多 CPU 进行优化。如果想要从多核获取好处， 那就考虑启用多个实例吧。

## Factors impacting Redis performance
There are multiple factors having direct consequences on Redis performance.

1. *Network bandwidth* and *latency*(延迟ping):
Regarding the bandwidth(根据带宽), it is generally useful to estimate the throughput in Gbit/s and compare it to the theoretical (理论)bandwidth of the network. For instance(比如) a benchmark setting 4 KB strings in Redis at 100000 q/s, would actually consume 3.2 Gbit/s of bandwidth. it worth considering putting a 10 Gbit/s NIC(网卡) or multiple 1 Gbit/s NICs with TCP/IP bonding.

2. CPU: is another very important factor.
Being single-threaded(由于单线程), Redis favors(更喜欢) *fast CPUs with large caches* and not many cores.

3. Speed of RAM and memory bandwidth: seem less critical(重要) for global performance especially for small objects.
For large objects (>10 KB), it may become noticeable though(变得重要起来).

4. Redis runs slower on a VM:
Most of the serious performance issues you may incur are due to over-provisioning, non-local disks with high latency, or old hypervisor software that have slow fork syscall implementation.

5. TCP/IP vs unix socket:
The performance benefit of unix domain sockets compared to TCP/IP loopback tends to decrease when pipelining is heavily used.

6. Pipelining:
When TCP/IP, *aggregating(聚合) commands* using pipelining is especially efficient when the size of the data is kept under the ethernet packet size (about 1500 bytes).
Actually, processing 10 bytes, 100 bytes, or 1000 bytes queries almost result in the same throughput. See the graph below.

7. On multi CPU servers, Redis performance becomes dependent on the *NUMA configuration* and *process location(处理器绑定位置)*.
To get deterministic results, it is required to use *process placement tools* (on Linux: taskset or numactl).
The most efficient combination is always to put the client and server on two different cores of the same CPU to benefit from the L3 cache.

Here are some results of 4 KB SET benchmark for 3 server CPUs:

![redis-benchmark-1.png](/img/redis-benchmark-1.png)

8. With high-end configurations(高配置), *the number of client connections* is also an important factor.
Being based on *epoll/kqueue*, the Redis event loop is quite scalable.
As a rule of thumb(经验法则), an instance with 30000 connections can only process half the throughput achievable with 100 connections.

9. Achieve higher throughput by tuning(调优) the NIC(s) configuration and associated interruptions.
Best throughput(最高吞吐) is achieved by setting an *affinity(绑定)* between *Rx/Tx NIC queues* and *CPU cores*, and *activating RPS (Receive Packet Steering)* support. *Jumbo frames* may also provide a performance boost when large objects are used.

10. Depending on the platform:
Redis can be compiled against different memory allocators (libc malloc, jemalloc, tcmalloc), which may have different behaviors in term of raw speed, internal and external fragmentation(片段).
If you did not compile Redis yourself, you can use the INFO command to check the mem_allocator field.
Please note most benchmarks do not run long enough to generate significant external fragmentation (contrary to production Redis instances).

## others
Some configurations (desktops and laptops for sure, some servers as well) have a variable CPU core frequency mechanism(分配机制).
The policy(策略) controlling this mechanism can be set at the OS level. Some CPU models are more aggressive(积极,好) than others at adapting the frequency of the CPU cores to the workload(负载). To get reproducible(可重现) results, it is better to set the highest possible fixed frequency for all the CPU cores involved in the benchmark.


# debug

## unkonwn command
Look for the following lines in your redis.conf:

    rename-command FLUSHDB ""
    rename-command FLUSHALL ""
