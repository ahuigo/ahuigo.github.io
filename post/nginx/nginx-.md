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

- Apache works by using a dedicated thread per client with blocking I/O.(线程对内存占用太大了)
- Nginx uses a single threaded non-blocking I/O mechnism to serve requests. As it uses non-blocking I/O, one single process can server too many connection requests.


# TOC
- nginx-conf.md 待整理