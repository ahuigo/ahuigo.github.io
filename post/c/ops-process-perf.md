---
layout: page
title: Ops 分析进程性能的工具
category: blog
description:
---
# perf book
http://linuxtools-rst.readthedocs.org/zh_CN/latest/advance/index.html

# Ops 分析进程性能的工具
- sar, iostat, top
- vmstat

# sar
sar 用地找出系统瓶颈: CPU、内存、硬盘的使用情况

它有两种用法；

1. 追溯过去的统计数据（默认）
2. 周期性的查看当前数据

## install sar
	1. apt-get install sysstat 来安装；

## 追溯过去的统计数据
### 先开启 sar 服务生成日志
sar 默认情况下是关闭的；需要编辑配置文件来开启它；

	1. vi /etc/default/sysstat
        2. 设置 ENABLED=”true”
	3. /etc/init.d/sysstat start

### 查看历史数据
默认情况下，sar从最近的0点0分开始显示数据；如果想继续查看一天前的报告；可以查看保存在`/var/log/sysstat/`下的sa日志； 使用sar工具查看:
最近28号的sa 日志

	$ sar -f /var/log/sysstat/sa28
	$ sar -f /var/log/sa/sa28
	12:00:01 AM     CPU     %user     %nice   %system   %iowait    %steal     %idle
	12:10:01 AM     all      7.46      0.00      3.83      0.03      0.12     88.55
	12:20:01 AM     all      6.61      0.00      3.39      0.02      0.10     89.88

### limit time
限定时间点为最近28号:20点~23点

	 sar -s 20:00:00 -e 23:00:00 -f /var/log/sa/sa28
	 sar -q -s 20:00:00 -e 23:00:00 -f /var/log/sa/sa28

## cpu
表示每秒采样一次，总共采样2次, (`-u` 默认采样cpu )

	$ sar -u 1 2
	09:03:59 AM     CPU     %user     %nice   %system   %iowait    %steal     %idle
	09:04:00 AM     all      0.00      0.00      0.50      0.00      0.00     99.50
	09:04:01 AM     all      0.00      0.00      0.00      0.00      0.00    100.00

说明

	%user 用户模式下消耗的CPU时间的比例；
	%nice 通过nice改变了进程调度优先级的进程，在用户模式下消耗的CPU时间的比例
	%system 系统模式下消耗的CPU时间的比例；
	%iowait CPU等待磁盘I/O导致空闲状态消耗的时间比例；
	%steal 利用Xen等操作系统虚拟化技术，等待其它虚拟CPU计算占用的时间比例；
	%idle CPU空闲时间比例；

## memory

	sar -r 1 2
	02:11:22 PM kbmemfree kbmemused  %memused kbbuffers  kbcached  kbcommit   %commit
	02:11:23 PM   1363500  14872620     91.60     32352  11729320   8035392      9.64
	02:11:24 PM   1362384  14873736     91.61     32352  11729960   8033956      9.64

不采样的话, 也可以用`free` 其它 说明

	kbmemfree：这个值和free命令中的free值基本一致,所以它不包括buffer和cache的空间.
	kbmemused：这个值和free命令中的used值基本一致,所以它包括buffer和cache的空间.
	%memused：物理内存使用率，这个值是kbmemused和内存总量(不包括swap)的一个百分比.
	kbbuffers和kbcached：这两个值就是free命令中的buffer和cache.
	kbcommit：保证当前系统所需要的内存,即为了确保不溢出而需要的内存(RAM+swap).
	%commit：这个值是kbcommit与内存总量(包括swap)的一个百分比.

## average usage 查看平均负载
指定-q后，就能查看运行队列中的进程数、系统上的进程大小、平均负载等；与其它命令相比，它能查看各项指标随时间变化的情况；

	$ sar -q 1 2
	02:13:34 PM   runq-sz  plist-sz   ldavg-1   ldavg-5  ldavg-15
	02:13:35 PM         2      1126      0.25      0.30      0.31
	02:13:36 PM         1      1126      0.25      0.30      0.31
	Average:            2      1126      0.25      0.30      0.31

说明：

	runq-sz：运行队列的长度（等待运行的进程数）
	plist-sz：进程列表中进程（processes）和线程（threads）的数量
	ldavg-1：最后1分钟的系统平均负载 ldavg-5：过去5分钟的系统平均负载
	ldavg-15：过去15分钟的系统平均负载

## disk

	sar -d
	11:00:02 PM       DEV       tps  rd_sec/s  wr_sec/s  avgrq-sz  avgqu-sz     await     svctm     %util
	11:10:01 PM    dev8-0     20.54      2.36   6024.41    293.43      0.98     47.56      0.87      1.79
	11:20:01 PM    dev8-0     21.64     85.86   5328.48    250.20      0.98     45.42      1.05      2.27

## page inout 查看页面交换发生状况
sar -W：查看页面交换发生状况

	pswpin/s：每秒系统换入的交换页面（swap page）数量
	pswpout/s：每秒系统换出的交换页面（swap page）数量

## summary
要判断系统瓶颈问题，有时需几个 sar 命令选项结合起来；

	怀疑CPU存在瓶颈，可用 sar -u 和 sar -q 等来查看
	怀疑内存存在瓶颈，可用sar -B、sar -r 和 sar -W 等来查看
	怀疑I/O存在瓶颈，可用 sar -b、sar -u 和 sar -d 等来查看

### sar参数说明
sar --help

	-B 内存分页统计 (Paging Statistics)
        数据来自 /proc/vmstat
	-b 全局I/O 传输速率统计 (I/O and Transfer Rate Statistics)
        用于监控块设备（如硬盘、SSD、RAID 卡）的整体吞吐量和请求频率。
        数据来自 /proc/stat
	-d DEV 具体到每个磁盘的详细统计 (Device Activity)
    -n 网络统计 (Network Statistics)
        -n DEV 每个网络接口的统计
        -n EDEV 每个网络接口的统计errors
        -n IP IP 相关统计
        -n EIP IP 相关erros 统计
        -n TCP TCP 相关统计
        -n ETCP TCP 相关erros 统计

## other

	-g       Report page-out activity.
	-p       Report page-in and page fault activity


# 各种top工具
## disk 瓶颈分析
### 用iostat 查看磁盘整体实时吞吐量
    iostat -dmx 1 
        -d : display only disk statistics
        -m : display statistics in megabytes per second
        -x : display extended statistics
    观察 %util：如果一直 100%，说明磁盘已经到物理极限了。
    观察 await：如果每个请求的平均等待时间超过 100 ms，说明磁盘响应极慢。
### 用iotop的元凶
查看各个进程的磁盘I/O 使用情况；

    sudo iotop -oPa
        -o : only show processes or threads actually doing I/O
        -P : show accumulated I/O instead of bandwidth
        -a : accumulate I/O over time instead of showing bandwidth


## network瓶颈分析
### 整体与明细结合
    #sar 中nload 查看整体网络吞吐量(rxkB/s, txkB/s)
    sar -n DEV 1
    nload

    # iftop (查看连接明细)
    sudo iftop -i eth0

    # 查看发包/收包累计错误
    ip -s link show eth0

### 如何确认带宽是否到达瓶颈？
确认带宽瓶颈通常遵循 “查上限 -> 算占比 -> 看丢包” 的逻辑。

    # 是否有重传
    watch -n 1 "netstat -s | grep retransmitted"
        2786339 segments retransmitted

    # 使用 ifconfig 或 ip -s link 查看是否有丢包 dropped 
    ip -s link show eth0
        RX:     bytes   packets errors dropped  missed   mcast           
            1071085972035 732395223  21089 1658458       0  412232 
        TX:     bytes   packets errors dropped carrier collsns           
            18521428887  24931231      0       0       0       0
        RX dropped：接收丢包，通常由于内核处理速度跟不上或缓冲区满。
        TX dropped：发送丢包，通常由于网卡队列溢出（即带宽打满）。

rxkB+txkB 达到接近网卡或带宽上限, 参考net-perf-test.md中的 iperf3 测试上限