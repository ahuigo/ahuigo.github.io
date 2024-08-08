---
title: gonic http block
date: 2024-08-08
private: true
---
# gonic http 阻塞
可能因为请求时的 'Content-Length: ' 超过了实际的body大小.
这导致　gonic　清空reqBody时被阻塞在这一句：

    ////go/1.22.1/libexec/src/net/http/server.go:1408
    _, err := io.CopyN(io.Discard, w.reqBody, maxPostHandlerReadBytes+1)

## 内部实际阻塞在
实际阻塞在netpollblock

    //libexec/src/net/net.go:179
    n,err:=c.fd.Read(b)

    //libexec/src/internal/poll/fd_unix.go:159
    for {
		n, err := ignoringEINTRIO(syscall.Read, fd.Sysfd, p)
		if err != nil {
			n = 0
			if err == syscall.EAGAIN && fd.pd.pollable() {
				if err = fd.pd.waitRead(fd.isFile); err == nil {
					continue
				}
			}
		}
		err = fd.eofError(n, err)
		return n, err
	}

    ////libexec/src/runtime/netpoll.go :345
    for !netpollblock(pd, int32(mode), false) {
		errcode = netpollcheckerr(pd, int32(mode))
		if errcode != pollNoError {
			return errcode
		}
	}

## Content-Length　是怎么触发阻塞的呢？
go是通过 LimitedReader 去读取 reqBody 的.
1. golang 收到http 请求时，会根据`N=Content-Length` 生成 `LimitedReader{N:N}`

    ```go
    /go/1.22.1/libexec/src/net/http/transfer.go:572
    t.Body = &body{src: io.LimitReader(r, realLength), closing: t.Close}
    ```

2. 后续读取body时，就会根据LimitedReader.N 读取(N)

N过大、过小都会有问题：
1. 如果N　大于实际的值时，gonic http 响应时, 会阻塞等待客户端发送后续的request body(gonic)
2. 如果N　小于实际的值时: bind josn解析request body会因为bytes 不全，触发`unexpected EOF`
    1. 当Read(reqBody)后，N变成0，err就会变成EOF，不再读取bytes。(正常)
    2. 但是, unmarsh(json bytes) 就会得到  `unexpected EOF(io.ErrUnexpectedEOF)`
        1. 正常情况下，stateEndValue(&dec.scan, ' ') == scanEnd　得到true

