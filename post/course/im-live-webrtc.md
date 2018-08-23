# 基于webRTC 的p2p 直播架构
在[im-live-p2p](/a#/post/course/im-live-p2p.md) 提到了p2p 架构的两大缺点：

1. 节点层级多: 导致延时大
2. 节点退出: 导致不稳定

事实上，CDN 分级架构也存在这样的问题，只是通过大宽带、主干网、节点自适应弱化了这些问题。 
本文将在基于webRTC 的p2p 方案中探讨如何弱化这两个问题。(Note: 并非彻底解决这个问题)

## webRTC
WebRTC (Web Real-Time Communications) 是google 提出的下一代点对点(Peer to Peer)实时文音视通信技术。现代浏览器都已经实现了该协议。

[WebRTC Protocol](https://developer.mozilla.org/en-US/docs/Web/API/WebRTC_API/Protocols) 介绍了其中的重要协议

### ICE
你直接连接两个AB节点是不行的:
1. 你可能要穿透firewall 
2. 你可能没有public ip, 然后路由也限制节点直连，你需要中继relay 转发

ICE (Interactive Connectivity Establishment) 正是用来解决这些问题的, ICE 就是通过STUN 或则TURN 让你连接节点的框架。

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

## 基于WebRTC的p2p 架构
这种p2p 架构最重要的是Tracker. 至于编码传输什么的，webRTC 帮你解决！
![](/img/webrtc-p2p-ahui.png)

Tracker 要负责：
1. 主播注册：主播需要告诉Tracker 主播的IP, 上行带宽，码率等信息
2. 观众注册：观众需要告诉Tracker 自己的IP, 上行带宽信息
2. 观众接入：观众注册后，需要根据 就近原则、播放点上行冗余情况向观众分配播放点的接入。
3. 观众选举：接入并拥有上行资源的观众自动被选举为次级播放点。从一级开始排序。
4. 播放点删除(自适应)：当播放点清除后，次级播放点自动进入再接入、再选举
5. 播放点健康检查：
    1. Tracker 可以通过心跳、次级观众播放点报告，判断播放点的健康
    2. 不健康的节点要被动态清除
6. 播放点动态排序：排序算法是核心
    1. 就近原则:接入应该选择最近的播放点, 降低网络包的路径时延
    2. 上行冗余优先：有足够冗余的节点，越先接入，分享率越高, 层级数量就越少，劲量避免因为层级多带来的延时