---
title: nginx 相关
date: 2018-10-04
---
# nginx 相关
- nginx-install.md
- nginx-tcp.md

## backlog & nproc
http://www.t086.com/article/5182

## thread-pools 线程池
https://www.nginx.com/blog/thread-pools-boost-performance-9x/

## dev
http://tengine.taobao.org/book/index.html
https://github.com/taobao/nginx-book


## Apache vs nginx: 
[nginx-performance]
引述 http://tengine.taobao.org/book/chapter_02.html 的话：

- Apache works by using a dedicated thread per client with blocking I/O.(一个线程只能阻塞处理一个请求)
    1. Apache 的多线程模式，必需要开启TSRM 线程安全，也影响性能(https://segmentfault.com/a/1190000010004035)
- Nginx uses a *single threaded* non-blocking I/O mechnism to serve requests. As it uses non-blocking I/O, one single process can server too many connection requests.

nginx master 不处理网络事件，只管理worker进程实现重启、更换日志文件、配置文件实时生效等功能，slave 才监听网络(惊群效应已经解决)(https://blog.csdn.net/yusiguyuan/article/details/40924415 nginx模型)

# TOC
- nginx-conf.md 待整理