# 基于webRTC 的p2p 直播架构
在[im-live-p2p](/a#/post/course/im-live-p2p.md) 我提到了p2p 架构的两大缺点：

1. 节点层级，导致延时大
2. 节点退出, 导致的不稳定

本文提出一种基于webRTC 的p2p 改良的方案.

## webRTC
先回顾下webRTC, WebRTC (Web Real-Time Communications) 是google 提出的全新通用的点对点(Peer to Peer)实时文音视通信技术。现代浏览器都已经实现了该协议。

[WebRTC Protocol](https://developer.mozilla.org/en-US/docs/Web/API/WebRTC_API/Protocols) 介绍了其中的重要协议

### ICE
你直接连接两个AB节点是不行的:
2. 可能要穿透firewall 
1. 你可能没有public ip, 加路由限制节点直连，你需要中继relay 转发

你需要ICE (Interactive Connectivity Establishment) 解决这些问题, ICE 就是通过STUN 或则TURN 让你连接节点的框架。

### STUN
Session Traversal Utilities for NAT (STUN) 协议作用，当client 向STUN 发出一个请求后，他会返回
1. 你的公网IP
2. 你的路由是否阻止点对点(也就是路由器NAT 背后的是client 是否可被访问)
![](/img/im/webrtc-stun.png)

### TURN
一些路由使用对称NAT(‘Symmetric NAT’). 这意味着路由只接受你之前连接过了节点。

这时就需要TURN(Traversal Using Relays around NAT) 穿NAT。
1. 你需要通过TURN 创建连接
2. 告诉所有的节点通过TURN 连接向你发数据。
![](/img/im/webrtc-turn.png)

### SDP
SDP(Session Description Protocol) 用来描述文、音、视数据内容meta 的标准, 节点之间基于这个标准解析处理数据。
包括不限: resolution, formats, codecs, encryption, etc.

## 改良的p2p 结构
