---
title: SSL OCSP（Online Certificate Status Protoco）线证书状态协议
date: 2023-03-24
private: true
---
# OCSP
虽然系统本身有CA, 但是用户怎么知道证书被吊销了呢？
用户收到cert from https website　后，会通过 OCSP 在线查询证书是否被吊销

OCSP缺点:
1. 性能问题: 浏览器需要为每个新的HTTPS连接执行附加的HTTP请求
2. 安全问题: 如果无法连接OCSP　server，或者超时，就会认为证书有效
3. 隐私问题: OCSP　server　可以知道用户访问过哪些网站

OCSP装订 （OCSP Stapling）可弥补这些缺点
## OCSP装订 （OCSP Stapling）
OCSP装订 （OCSP Stapling）作为对OCSP协议缺陷的弥补
1. 服务器可以事先模拟浏览器对证书链进行验证，并将带有CA机构签名的OCSP验证结果响应保存到本地，最多可缓存7天。
2. 等到真正的握手阶段，再将OCSP响应和证书链一起下发给浏览器，以此避免增加浏览器的握手延时。
2. 由于浏览器不需要直接向 CA 站点(OCSP)查询证书状态，这个功能对访问速度的提升非常明显。

注意：OCSP信息有CA的签名，服务器伪造不了

### nginx开启stapling
    server{
        ...
        ssl_stapling on;
        ssl_stapling_verify on;
    }




