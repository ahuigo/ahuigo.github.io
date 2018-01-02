---
layout: page
title:	memcached
category: blog
description: 
---
# Preface

# 集成式Cache 分布式扩展
Refer to: http://blog.csdn.net/cenwenchu79/article/details/2981863

Memcached 服务端单实例的，但是可以通过客户端按照Key的hash 实现分布式存储, 或者通过一致性hash(Consistent Hashing) 分布存储
所以 Memcached 是集中式cache, 另外它支持分布式横向扩展.

## 集中式Cache 分两种架构

1. 节点均衡的网状(JBoss Tree Cache), 利用JGroup 的多播通信机制同步数据
2. Master-Slaves模式：Master 管理Slaves Master 存在单点问题

集中式Cache: 没有分布式Cache 的传播问题，但需要非单点(比如将多个Memcached 作为虚拟的cluster)支持

## Memcached支持*分布式扩展*:
将多台机器上的多个memcached 服务组成一个虚拟的服务端，对于调用者来说完全屏蔽和透明。这很容易scale out 扩展

使用一致性hash

	setOption(Memcached::OPT_DISTRIBUTION, Memcached::DISTRIBUTION_CONSISTENT)


# 跨机房同步mcproxy
Refer: http://www.ooso.net/archives/558

mcproxy 是facebook 开发的memcached 与 proxy结合。利用mcproxy来进行跨机房的全球同步或分发。facebook还没开源mcproxy，不过有两个替代:

	memagent
		a simple but useful proxy program for memcached servers.
	moxi
		memcached + integrated proxy

# 数据一致性
*并发数据一致性* 
Memcached提供了cas(Check And Set)命令，可以保证多个并发访问操作同一份数据的一致性问题。 redis 没有cas 但是提供的事务可以保证操作的原子性。

> http://weibo.com/p/1001603862417250608209

## CAS

	do {
		/* fetch IP list and its token */
		$ips = $m->get('ip_block', null, $cas);
		/* if list doesn't exist yet, create it and do
		   an atomic add which will fail if someone else already added it */
		if ($m->getResultCode() == Memcached::RES_NOTFOUND) {
			$ips = array($_SERVER['REMOTE_ADDR']);
			$m->add('ip_block', $ips);
		/* otherwise, add IP to the list and store via compare-and-swap
		   with the token, which will fail if someone else updated the list */
		} else { 
			$ips[] = $_SERVER['REMOTE_ADDR'];
			$m->cas($cas, 'ip_block', $ips);
		}   
	} while ($m->getResultCode() != Memcached::RES_SUCCESS);

*memcached 与 mysql 的一致性*

- HandlerSocket is a NoSQL plugin for MySQL/MariaDB. 集成了nosql, 不用担心与mysql 间的数据一致性
- 像网易那样用mysq user define UDF主动trigger 更新Cacher 会涉及到锁机制的问题

# Expire 超时时间
失效秒数不能超过60×60×24×30（30天时间的秒数）;如果失效的值大于这个值， 服务端会将其作为一个真实的Unix时间戳来处理而不是 自当前时间的偏移。

如果失效值被设置为0（默认），此元素永不过期（但是它可能由于服务端为了给其他新的元素分配空间而被删除）

# Daemon
`memcached -h`

	-p <num>      TCP port number to listen on (default: 11211)
	-U <num>      UDP port number to listen on (default: 11211, 0 is off)
	-s <file>     UNIX socket path to listen on (disables network support)
	-A            enable ascii "shutdown" command
	-a <mask>     access mask for UNIX socket, in octal (default: 0700)
	-d 			run as daemon
	-m <num>
              Use  <num>  MB  memory  max  to  use  for  object storage; the default is 64
              megabytes.
	-p <PORT>

Example:

	memcached -s /tmp/mc.sock -a 0755 -d -p 11211

## status

	-v            verbose (print errors/warnings while in event loop)
	-vv           very verbose (also print client commands/reponses)
	-vvv          extremely verbose (also print internal state transitions)

# Client

## shell client
To make a connection to Memcached using Telnet, use the following command:

	$ telnet localhost 11211
		Trying 127.0.0.1...
		Connected to localhost.
		Escape character is '^]'.
		If at any time you wish to terminate the Telnet session, simply type "quit" and hit return:

	> stats
	> quit
	Connection closed by foreign host.

## php client

	$m = new memcached;
	$m->setOption ( memcached::OPT_DISTRIBUTION, memcached::DISTRIBUTION_CONSISTENT );
	$m->setOption ( memcached::OPT_LIBKETAMA_COMPATIBLE, true );
	$m->setOption ( memcached::OPT_NO_BLOCK, true );
	$m->setOption ( memcached::OPT_COMPRESSION, true);
	$m->setOption ( memcached::OPT_CONNECT_TIMEOUT, 200 );
	$m->setOption ( memcached::OPT_RETRY_TIMEOUT, 1 );
	$m->addServers ($servers = [['host','port','weight']]);
	$m->addServer ('localhost', 11211);
	$m->set('key', 1, 3600);
	echo $m->get('key');

To use unix socket, you should:

	$m->addServer('/tmp/mc.sock', 0); // Socket port is 0, and do not use `unix:` prefix like `unix:/tmp/mc.sock`

## touch(expiration)

	public bool Memcached::touch ( string $key , int $expiration= time() + secs )

## increment

	public int Memcached::increment ( string $key [, int $offset = 1 ] )
	public int Memcached::decrement ( string $key [, int $offset = 1 ] )

## getDelayed
获取多个keys

	$m = new Memcached();
	$m->addServer('/tmp/mc.sock', 0);

	$m->set('int', 99);
	$m->set('string', 'a simple string');
	$m->set('array', array(11, 12));

	//延迟的获取int和array这两个key的值
	$m->getDelayed(array('int', 'array'), true);
	//循环抓取上面的延迟抓取得到的结果
	while ($result = $m->fetch()) {
		var_dump($result);
	}

Results:

	array(3) {
	  ["key"]=>
	  string(3) "int"
	  ["value"]=>
	  int(99)
	  ["cas"]=>
	  float(1)
	}

## proxy
Twemproxy(/usr/sbin/nutcracker)是一个代理服务器，可以通过它减少Memcached或Redis服务器所打开的连接数。Twemproxy速度很快，真的很快，它几乎与直接访问Redis速度一样快
https://github.com/twitter/twemproxy

	通过代理的方式减少缓存服务器的连接数
	自动在多台缓存服务器间共享数据
	通过不同的策略与散列函数支持一致性散列
	通过配置的方式禁用失败的结点
	运行在多个实例上，客户端可以连接到首个可用的代理服务器
	支持请求的流式与批处理，因而能够降低来回的消耗

> Refer: http://www.infoq.com/cn/news/2012/12/twemproxy

twemorxy config

	$ cat /etc/nutcracker/nutcracker.yml
	group1:
	  listen: /dev/mc1.sock
	  hash: fnv1a_64
	  distribution: ketama //setOption(Memcached::OPT_DISTRIBUTION, Memcached::DISTRIBUTION_CONSISTENT)
	  preconnect: true
	  backlog: 65535
	  timeout: 1000
	  server_connections: 16
	  auto_eject_hosts: false
	  server_retry_timeout: 1000
	  server_failure_limit: 5
	  servers:
	   - 192.168.0.1:11211:10
	   - 192.168.0.2:11211:10

# debug
> SERVER HAS FAILED AND IS DISABLED UNTIL TIMED RETRY

很可能是servers ip 不可用

# Security
This method is only available when the memcached extension is built with SASL support. Please refer to Memcached setup for how to do this.

	$mc->setSaslAuthData ( string $username , string $password )

you'll have to set the Memcached::OPT_BINARY_PROTOCOL option to true:

	$mc->setOption(Memcached::OPT_BINARY_PROTOCOL, true);
