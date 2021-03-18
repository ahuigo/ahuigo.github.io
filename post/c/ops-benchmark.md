---
layout: page
title: 压测工具
category: blog
description: 
---
# Preface
性能/压力测试的分类：

	基准/基线测试 base line testing / benchmark testing
	负载测试 load testing
	压力测试 stress testing
	稳定性测试 scalability testing
	疲劳测试 endurance testing
	组合测试 combination testing
	远程/机房测试 remote/local testing

测试指标有哪些要关注的：

	响应时间：从用户角度
	服务器资源：从系统角度
	吞吐量：从业务角度

# stress testing(压力测试)
压力测试的工具有

    ab/siege/wrk/webbench: web server
    sysbench: mysql,mssql(TPS, Transactions Per Second)

有很多不错的压测工作
- boom
https://github.com/rakyll/boom
HTTP(S) load generator, ApacheBench (ab) replacement, written in Go

- wrk
https://github.com/wg/wrk
Modern HTTP benchmarking tool

- tcpkali
https://github.com/machinezone/tcpkali
Fast multi-core TCP and WebSockets load generator.

- gor
https://github.com/buger/gor
HTTP traffic replay in real-time. Replay traffic from production to staging and dev environments.

压力测试的指标

	Queries per second(QPS):    582.71 [#/sec] (mean)
	Time per request(RT,resopns time):       1716.108 [ms] (mean)
	Time per request:       1.716 [ms] (mean, across all concurrent requests)
	Transfer rate:          2516.51 [Kbytes/sec] received

> 建议测试时，关注http://host/nginx_status

## wrk
https://github.com/wg/wrk

	wrk -t12 -c400 -d30s http://127.0.0.1:8080/index.html
	-t12  使用 12 个线程
	-c    使用 40连接
	-d30s 请求30秒

## go-wrk

    go-wrk [flags] url

with the flags being

    -H="User-Agent: go-wrk 0.1 bechmark\nContent-Type: text/html;": the http headers sent separated by '\n'
    -c=100: the max numbers of connections used
    -k=true: if keep-alives are disabled
    -i=false: if TLS security checks are disabled
    -m="GET": the http request method
    -n=1000: the total number of calls processed
    -t=1: the numbers of threads used
    -b="" the http request body
    -s="" if specified, it counts how often the searched string s is contained in the responses

for example

    go-wrk -c=400 -t=8 -n=100000 http://localhost:8080/index.html

## tcpkali
https://github.com/machinezone/tcpkali
Fast multi-core TCP and WebSockets load generator.

## tcpcopy 压测
或者用 gor:
gor 已经上线的 远程api 回调 ,调试的时候直接把流量复制到本地方便测试

## siege
ab 只支持http1.0, 而siege 支持1.1

	-f, --file=FILE           FILE, select a specific URLS FILE.
		-f urls.txt, a url each line
	-c concurrency
	-r, --reps=NUM            REPS(repeats), number of times to run the test.
	-H, --header="text"       Add a header to request (can be many)
	-t, --time=NUMm           TIMED testing where "m" is modifier S, M, or H
						ex: --time=1H, one hour test.
	-b, --benchmark           BENCHMARK: no delays between requests.(default: 1 seconds)
	-d, --delay=NUM           Time DELAY, random delay before each requst
                            between 1 and NUM. (NOT COUNTED IN STATS)

Example:

	siege -b -c 300 -r 5 http://localhost/

### msl
Mac OS X has only 16K ports available that won't be released until socket
TIME_WAIT is passed. The default timeout for TIME_WAIT is 15 seconds.
Consider reducing in case of available port bottleneck.

You can check whether this is a problem with netstat:

    # sysctl net.inet.tcp.msl
    net.inet.tcp.msl: 15000

    # sudo sysctl -w net.inet.tcp.msl=1000
    net.inet.tcp.msl: 15000 -> 1000

Run siege.config to create the ~/.siegerc config file.

### debug
如果压测的时候出现大量的`[error] socket: 2001824064 address is unavailable.: Cannot assign requested address`

客户端频繁的连服务器，由于每次连接都在很短的时间内结束，导致很多的TIME_WAIT，以至于用光了可用的端口号，所以新的连接没办法绑定端口，所以 要改客户端机器的配置

Refer: [tcp-ip](/p/tcp-ip)
在/etc/sysctl.conf里加, 或者在命令行：

	sysctl net.ipv4.tcp_tw_reuse=1 # 表示开启重用。允许将TIME-WAIT sockets重新用于新的TCP连接，默认为0，表示关闭；
	sysctl net.ipv4.tcp_timestamps=1 # 开启对于TCP时间戳的支持,若该项设置为0，则下面一项设置 不起作用
	sysctl net.ipv4.tcp_tw_recycle=1 # 表示开启TCP连接中TIME-WAIT sockets的快速回收

## vegeta(golang版本)
vegeta 是golang 写的压测工具

    go get -u github.com/tsenart/vegeta

### 简单get

    echo "GET http://host.com" | vegeta attack  -rate=10000  -duration=10s |vegeta report
    echo "GET http://host.com" | vegeta attack  -rate=10000  -duration=10s > result.bin

header:

    jq -ncM '{method: "GET", url: "http://goku", body: "Punch!" | @base64, header: {"Content-Type": ["text/plain"]}}' |
    vegeta attack -format=json -rate=100 | vegeta encode

vegeta attack 参数：

    -format 接收请求信息的格式，这里使用json
    -rate 每秒请求数
    -duration 压测持续时间。0代表一直执行。
    > 输出文件是二进制格式。


### post请求
    jq -ncM '{method: "POST", url: "http://baidu.com/", body: {key:"IDLE"} | @json }'

    jq -ncM '{method: "POST", url: "http://baidu.com/", body: {key:"IDLE"} | @base64 }' \
    | vegeta attack -format=json -rate=6000 -duration=60s > result.data-collection.6000qps.60s.bin;

    jq -ncM '{method: "GET", url: "http://goku", body: "Punch!" | @base64, header: {"Content-Type": ["text/plain"]}}' |
    vegeta attack -format=json -rate=100 | vegeta encode

以上jq脚本的解释：

    -n 没有stdin input
    -c 压缩到一行
    -M 去掉高亮彩色
    {key:"IDLE"} | @base64  // base64编码

### 变化请求

    jq -ncM 'while(true; .+1) | {method: "POST", url: "http://dev-data-collection-inner.hdmap.momenta.works:32000/api/v1/gps", body: {"box_id":("stress-test-"+(.|tostring)),"unix_time":1549878773321,"lon":116.1824618,"lat":39.8726543,"alt":37.5,"fix_quality":4,"sate_num":12,"hdop":0.9,"status":"IDLE","image_status":"IDLE"} | @base64 }' | vegeta attack -format=json -rate=6000 -lazy -duration=60s > result.data-collection.6000qps.60s.gen.bin;

    vegeta report result.data-collection.6000qps.60s.gen.bin | head -n 10;

以上jq脚本的解释：

    -n 没有stdin input
    -c 压缩到一行
    -M 去掉高亮彩色

    while(true; .+1) 生成自增ID
    ("stress-test-"+(.|tostring)) 将整数ID转为string并加上前缀

vegeta report： 分析attack的二进制输出，生成报告。

    vegeta report result.data-collection.6000qps.60s.gen.bin | head -n 10;

vegeta plot： 生成 html 格式的折线图，使用浏览器打开文件。

    vegeta plot result.key.200qps.60s.bin > result.key.200qps.60s.html

横轴是压测时刻，从0到duration。纵轴是滑窗内的平均响应时间，滑窗大小可以在左下角的小输入框里修改。

## ab ApacheBench 

    yum install httpd-tools
	Usage: ab [options] [http[s]://]hostname[:port]/path
	Options are:
		-n requests     Number of requests to perform
		-c concurrency  Number of multiple requests to make at a time
		-k              Use HTTP KeepAlive feature
		-l              Accept variable *document length* (use this for dynamic pages)
		-m method       Method name

		-r              Don't exit on socket receive errors.
        -s timeout      default 30s

### header+output
Example:

	 ab -r -l -n 200 -c 2 http://baidu.com/
	 ab -l -n 100 -c 2 -p post.txt -H 'Cookie: a=1; b=1'  -H 'Host:weibo.cn' 'http://192.168.0.1/'
     post.txt: <(echo 'a=1&b=1')

具体参数

	Document Length: 測試網頁回應的網頁大小(不含header大小)

	Connect
	Waiting: 建立连接后，到服务器response 第一个byte 的时间
	Processing: waiting + responsing
	Total:	Connect + Processing

### view response
-v 4 观察response 

    ab -n 100 -c 1 -C "$MY_COOKIE" -v 4 $url

### http1.0
ab 只支持1.0, 如果需要http1.1 可以考虑siege

### proxy

	-X proxy:port   Proxyserver and port number to use

### debug

	-v verbosity    How much troubleshooting info to print
	-v 5

### post
    ab -T 'application/x-www-form-urlencoded' -c 10 -n 100  -p <(echo 'password=1') 'http://localhost:1111/header.php'

### Failed requests

	Failed requests: 2303
	(Connect: 0, Length: 2303, Exceptions: 0)

只要出现Failed requests就会多一行数据来统计失败的原因，分别有Connect、Length、Exceptions。

	Connect 无法送出要求、目标主机连接失败、要求的过程中被中断。
	Length 响应的内容长度不一致 ( 以 Content-Length 头值为判断依据 )。对于动态脚本页面来说，ab 是以第一次请求时的Length 为基准
	Exception 发生无法预期的错误。

如果是非20x 状态码:

	Complete requests:      1360
	Failed requests:        0
	Non-2xx responses:      1360 //header("HTTP/1.0 502");

### transfer

	Transfer-Encoding:chunked

## webbench
Not support `-H` header

	webbench -c 10 -t 2 http://wap.weibo.cn
		-t <seconds>
		-c concurrency  Number of multiple requests to make at a time

## pylot
这是一个python 压测工具
http://www.pylot.org/gettingstarted.html

	brew install wxpython
	brew info wxpython

### usage
	python run.py -a 100 -d 20 -g
		-a concurrency
		-d timelimit for running


# optimize
QPS 与 RT 关系不大。
QPS: 与cpu 本身时间相关
RT: 与cpu+io 等相关, 更多的是io(api)相关

在一个高IO 系统中：如果cpu 10ms + IO(40ms) = 50ms 如果cpu 优化到5ms 那么RT 提升了5/50, QPS 却提升了一倍

Refer to : 服务端QPS 提升
http://wenku.baidu.com/link?url=9Yu7Ix_T4caE3OJZ9RCOalWJ8jCwTNWEiPeeWM9191ijP93zJjtz4ZsBy0DzzkrwTtfeUOLEIts4mjp-D3OjCjBB58YMP869GUUdee1CSwu

## nginx
Nginx 多进程模型是如何实现高并发的？
webserver刚好属于网络io密集
异步，非阻塞，使用epoll，和大量细节处的优化。

http://www.zhihu.com/question/22062795

# 负载均衡
http://www.ttlsa.com/web/the-difference-between-four-and-seven-load-balance/
http://www.ttlsa.com/nginx/using-nginx-as-http-loadbalancer/

DNS [负载均衡](https://zhuanlan.zhihu.com/p/34904010):
1. 4层:lvs、F5, 使用IP加端口的方式进行路由转发
    1. 通过配置的负载均衡算法选择一台后端服务器，并且将报文中的IP地址信息修改为后台服务器的IP地址信息，因此TCP三次握手连接是与后端服务器直接建立起来的。
2. 7层: nginx、apache等 可以过滤判断SYN Flood攻击(避免应用服务器直接连接)
    1. 只能先与负载均衡设备进行TCP连接，然后负载均衡设备再与后端服务器建立另外一条TCP连接通道。
3. haproxy 4层或7层, 
    1. haproxy 做均衡器时可以使用多个内网ip 连后端, 突我了port 数 65535 的限制

# 架构
Linux集群+MySQL优化+Nginx高并发+lvs负载均衡
cache + message queue + (chubby/zookeeper)

http://www.zhihu.com/question/23364686

# debug
## ip_conntrack: table full, dropping packet
http://www.vpsee.com/2011/11/how-to-solve-ip_conntrack-table-full-dropping-packet-problem/
