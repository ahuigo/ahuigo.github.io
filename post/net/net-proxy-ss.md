---
title: ss 代理实现
date: 2019-02-21
private:
---
private:
# ss 代理实现
ss_local 和 ss_server 之间就是对称加密的 tcp 数据

    [client] -socks5-> [ss-local] -ss-> [ss-server] --> [destination] 

[demo](/demo/py-demo/socket/proxy-ss-local.py) 

# 参考
由浅入深写代理(8)-ss-代理 https://zhuanlan.zhihu.com/p/28798090