---
layout: page
title: io network
category: blog
description: 
date: 2016-09-27
---
# network tool
https://www.binarytides.com/linux-commands-monitor-network/

# Interface speed between two server
> https://linuxaria.com/article/tool-command-line-bandwidth-linux
有几个工具：
1. iperf,iperf3
2. Netcat(nc)

## iperf
server side:

    #iperf -s
    ------------------------------------------------------------
    Server listening on TCP port 5001
    TCP window size: 8.00 KByte (default)
    ------------------------------------------------------------
    [852] local 10.1.1.1 port 5001 connected with 10.6.2.5 port 54355
    [ ID]   Interval          Transfer        Bandwidth
    [852]   0.0-10.1 sec   1.15 MBytes   956 Kbits/sec
    ------------------------------------------------------------
    Client connecting to 10.6.2.5, TCP port 5001
    TCP window size: 8.00 KByte (default)
    ------------------------------------------------------------
    [824] local 10.1.1.1 port 1646 connected with 10.6.2.5 port 5001
    [ ID]   Interval          Transfer        Bandwidth
    [824]   0.0-10.0 sec   73.3 MBytes   61.4 Mbits/sec

Client side

    #iperf -c 10.1.1.1 -d
    ------------------------------------------------------------
    Server listening on TCP port 5001
    TCP window size: 85.3 KByte (default)
    ------------------------------------------------------------
    ------------------------------------------------------------
    Client connecting to 10.1.1.1, TCP port 5001
    TCP window size: 16.0 KByte (default)
    ------------------------------------------------------------
    [ 5] local 10.6.2.5 port 60270 connected with 10.1.1.1 port 5001
    [ 4] local 10.6.2.5 port 5001 connected with 10.1.1.1 port 2643
    [ 4] 0.0-10.0 sec 76.3 MBytes 63.9 Mbits/sec
    [ 5] 0.0-10.1 sec 1.55 MBytes 1.29 Mbits/sec

## netcat speed test
On th server machine

    nc -v -v -l -n  2222 | wc -c
    listening on [any] 2222 ...
    73903624

On the client machine

    time yes|nc -v -v -n 10.1.1.1 2222 >/dev/null

    # Or copy 2.1GB
    DATASIZE=$(echo '2^31' | bc)
    dd if=/dev/zero bs=$DATASIZE count=1 | nc [HOST] 2222

On client stop the process  after 10 seconds (more or less) with ctrl-c, you’ll get something at server side:

    73903624 (bytes)

使用ifstat 可实时查看speed

# ifstat, interface stat

    $ ifstat -t -i eth0 0.5

# tcp stats
## iftop, tcp top(面对连接)
But being based on the pcap library, iftop is able to filter the traffic and report bandwidth usage over selected host connections as specified by the filter.

    $ sudo iftop -n

## Iptraf
 is an interactive and colorful IP Lan monitor. It shows individual connections and the amount of data flowing between the hosts. Here is a screenshot

    $ sudo iptraf

## tcptrack

# program top, 程序网络统计
## nethogs
Nethogs is a small 'net top' tool that shows the bandwidth used by individual processes and sorts the list putting the most intensive processes on top.

    $ sudo nethogs
