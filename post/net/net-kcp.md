---
title: kcp 
date: 2023-12-24
private: true
---
# kcp 是什么？ 
原神用的是TCP还是UDP? KCP是什么？ https://www.bilibili.com/video/BV1wC4y1D7H3/
- udp 无状态
- tcp: udp+ （传输层）可靠性保障：
    - 如果丢包，要等2RTO 时间重传
    - 漏3个包才触发重传
    - 拥塞控制：在丢包时，减少发包数量
- kcp: udp + （应用层）轻量重传: 乱充重排、滑动窗口、拥塞控制
    - 如果丢包，要等1.5RTO 时间重传
    - 漏2个包才触发重传
    - 可关拥塞控制

http3.0 也是基于udp 搞的