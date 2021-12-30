---
title: 关于go dns 解析：cgo vs go
date: 2021-07-06
private: true
---
# dns 解析：
## dns 解析：cgo vs go
根据官方说明, go 存在两种dns解析：
1. 第一种是纯go 解析: It can use a pure Go resolver that sends DNS requests directly to the servers listed in /etc/resolv.conf, 
2. 第二种是cgo 解析: it can use a cgo-based resolver that calls C library routines such as getaddrinfo and getnameinfo.

默认使用 go resolver, 因为:
1. Go resolver: a blocked DNS request consumes only a `goroutine`, 
2. Cgo resolver: a blocked C call consumes an `operating system thread`. 

当cgo存在，在以下条件下中会被使用
1. on systems that do not let programs make direct DNS requests (OS X), 
2. when the `LOCALDOMAIN` environment variable is present (even if empty), 
2. when the `RES_OPTIONS or HOSTALIASES` environment variable is non-empty, 
3. when the `ASR_CONFIG` environment variable is non-empty (OpenBSD only), 
4. when /`etc/resolv.conf or /etc/nsswitch.conf` specify the use of **features that the Go resolver does not implement**, 
7. and when the name being looked up ends in `.local` or is an `mDNS` name.

The resolver decision can be overridden by setting the netdns value of the GODEBUG environment variable (see package runtime) to go or cgo, as in:

    export GODEBUG=netdns=go    # force pure Go resolver
    export GODEBUG=netdns=cgo   # force cgo resolver
    export GODEBUG=netdns=1   # debug mode
    export GODEBUG=netdns=2   # debug mode very verbose
    export GODEBUG=netdns=go+1   # debug mode with pure go resolver

### 示例代码
/go-lib/net/dns-go.go
/go-lib/net/dns-cgo.go