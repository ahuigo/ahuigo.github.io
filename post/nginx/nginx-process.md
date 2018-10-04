---
title: nginx process
date: 2018-10-04
---
# nginx process
nginx是比apache 更先进的web server. 以BSD许可证发布. 内核简洁, 模块强大(与apache不同, 其所有的模块都是静态编译的, 更快). 简单的是nginx接收到http请求后. 
1. 当分析到请求是js/css/img等静态资源, 就交给静态资源模块去处理. 
2. 如果是php/python等动态资源, 就交给FastCGI去处理.

> FastCGI = web server 与 动态脚本语言间的接口

## I/O消息通知机制
Nginx支持epoll(linux系) 和 kqueue(bsd) 系事件通知机制. 还有:
	`use [ kqueue | rtsig | epoll | /dev/poll | select | poll ];`


## 多进程
nginx 每进来一个request，会有一个worker:
1. 处理到可能发生阻塞的地方，比如向上游（后端）服务器转发request，并等待请求返回。
2. 这个处理的worker不会这么傻等着，他会在发送完请求后，注册一个事件：“如果upstream返回了，告诉我一声，我再接着干”。
3. 于是他就休息去了。此时，如果再有request 进来，他就可以很快再按这种方式处理。而一旦上游服务器返回了，就会触发这个事件，

如果master发现, worker死掉了, 它会再开一个worker. worker会用到epoll通知机制.

## events

	worker_rlimit_nofile 51200; #文件描述符数量限制
	worker_processes 4|auto; #如果有4个cpu
		worker_cpu_affinity cpumask ...;
		worker_cpu_affinity 0001 0010 0100 1000;
			# Bind worker processes to CPUs. Each CPU set if represent by a bitmask of allowed CPUs.
		worker_priority 0;
			# the nice command: a negative means a higher priority. Ranges from -20 to 20.
	events {
		use epoll;  #epoll（>linux2.6） kqueue(bsd)
			worker_aio_requests 32; # When using aio with the epoll, maxium of aio for a single worker
		worker_connections 51200; #每个进程最大连接数
		multi_accept on; 
			# default off # worker process accept all new connections instead of one at a time
	}