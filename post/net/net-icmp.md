# ICMP, Internet Control Message Protocol
下图是一个`ping -c 1 baidu.com` 的 reply 包.

![protocol-icmp-1.png](/img/protocol-icmp-1.png)

Most of the time when I talk to people about blocking ICMP they're really talking about ping and traceroute. This translates into 3 types

  0 - Echo Reply (ping response)
  8 - Echo Request (ping request)
  11 - Time Exceeded

## traceroute
traceroute, 到达每个节点的丢包率和延迟都能详细的显示, 它涉及IP头部生存时间（time to live, TTL）字段及ICMP 协议。

### TTL
*跳站计数器*
设置TTL字段的目的是为了防止数据报由于选路错误或其他软硬件原因从而导致在网络中无休止的流动，TTL字段指定了数据报的生存时间。TTL的初始值由源主机设置，当一份数据报经过路由器时，处理该数据报的路由器都需要把TTL值减去数据报在路由器中停留的秒数。但事实上大多数路由器只是简单地将TTL值减1，因此TTL字段最终被实现为一个跳站计数器。

*超时差错报文:路由信息*
当TTL字段的值被减为0时，路由器就不会转发该数据报，而是将其丢弃，并产生一份ICMP超时差错报文发往源主机以通知错误的发生。TraceRoute程序的关键就在于返回的这份ICMP超时差错报文的源地址就是途经路由器的IP地址。由此，通过依次递增TTL字段的值，就可以得到一份数据报在其传输路径上所经过的路由信息。

*TraceRoute程序在具体实现*

1. 向目的主机发送一个ICMP回显请求（Echo request）消息，并重复递增IP头部TTL字段的值。
2. 刚开始的时候TTL等于1，这样当该数据报抵达途中的第一个路由器时，TTL的值就被减为0，导致发生超时错误，因此该路由器生成一份ICMP超时差错报文返回给源主机。
3. 随后，主机将数据报的TTL值递增1，以便IP报文能传递到下一个路由器，下一个路由器将会生成ICMP超时超时差错报文返回给源主机。
4. 不断重复这个过程，直到数据报到达最终的目的主机，此时目的主机将返回ICMP回显应答（Echo replay）消息。

这样，源主机只需对返回的每一份ICMP报文进行解析处理，就可以掌握数据报从源主机到达目的主机途中所经过的路由信息

	traceroute - print the route packets trace to network host

这个 traceroute 程序（一些系统使用相似的 tracepath 程序来代替）会显示从本地到目的主机 要经过的所有“跳数”的网络流量列表(路由)。

	$ traceroute m.weibo.cn
	traceroute: Warning: m.weibo.cn has multiple addresses; using 202.108.7.133
	traceroute to weibo.cn (202.108.7.133), 64 hops max, 52 byte packets
	 1  localhost (192.168.1.1)  2.170 ms  2.538 ms  1.578 ms
	 2  114.249.224.1 (114.249.224.1)  50.709 ms  134.246 ms  79.752 ms
	 3  61.51.246.165 (61.51.246.165)  5.262 ms  4.654 ms  4.134 ms
	 4  124.65.57.245 (124.65.57.245)  2.980 ms  3.936 ms  3.969 ms
	 5  61.148.143.22 (61.148.143.22)  2.058 ms  2.049 ms  3.188 ms
	 6  210.74.178.198 (210.74.178.198)  2.991 ms  4.344 ms  3.471 ms
	 7  202.108.7.133 (202.108.7.133)  1.834 ms  2.076 ms  2.080 ms

## mtr
mtr - a network diagnostic tool
mtr命令比traceroute要好, 提供更多信息

	mtr weibo.com
