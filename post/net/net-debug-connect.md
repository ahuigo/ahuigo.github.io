# connection refused
从自己到别人查找

## 目标端口
1. 没有打开，可能是监听端口的进程的已经挂了

## 没有绑定合适的ip:
'127.0.0.1', 而应该是'0.0.0.0' 面向所有接口, 查绑定的IP
```
    $ sudo netstat -tnlp | grep :9000
    Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
    tcp        0      0 0.0.0.0:9000            0.0.0.0:*               LISTEN      16855/python3
    $ sudo netstat -tnlp | grep :9000
    tcp        0      0 127.0.0.1:9000          0.0.0.0:*               LISTEN      16855/python3
```

$ tcpdump -D
```
1.eth0 内网ip
4.eth1  外网ip
5.usbmon1 (USB bus number 1)
6.any (Pseudo-device that captures on all interfaces)
7.lo 127.0.0.1
```

## 监听端口对应的tcp backlog已经满了
后端连接数限制逻辑

## Port is blocked by a firewall
1. If the port is blocked by a firewall 
2. and the firewall has been configured to respond with icmp-port-unreachable 

this will also cause a connection refused message. 

    $ sudo tcpdump -n icmp 
    IP 192.0.2.1 > 192.0.2.2: ICMP 192.0.2.1 tcp port 22222 unreachable, length 68

## 网络质量问题