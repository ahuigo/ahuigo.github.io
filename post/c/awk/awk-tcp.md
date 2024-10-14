---
title: gawk tcp
date: 2024-10-01
private: true
---
# gawk tcp

## tcp: read write
    header = "GET /abc HTTP/1.1\r\n" "Host: a.com\r\n" "Connection: close\r\n"
    HttpService = "/inet/tcp/0/localhost/8080"
    print(header "\r\n") |& HttpService
	while ((HttpService |& getline) > 0) {
		if (isBody) {
			content = content ? content "\n" $0 : $0
		} else if (length($0) <= 1) {
			isBody = 1
		}
	}
    close(HttpService) # 关闭pipe

`|&`  是一个双向管道操作符，它可以用于创建一个到另一个进程的双向通信管道
1. `print(header "\r\n") |& HttpService` 输出到管道
2. `(HttpService |& getline)` 输入到管道

虽然 `|&` 操作符出现了两次，但它们都是和同一个命令（HttpService 或 command）一起使用的。所以，AWK 只会创建一个到这个命令的双向管道，而不是两个管道。

    command |& getline
    print "data" |& command