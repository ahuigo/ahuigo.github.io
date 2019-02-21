---
title: 内网穿透 ngrok
date: 2019-02-21
private:
---
# 内网穿透
都是通过公网做转接: https://zhuanlan.zhihu.com/p/28820926

- ngrok
    流量重放
    ./ngrok -config=ngrok.cfg -subdomain <domain> 80
    ./ngrok -config=ngrok.cfg -hostname xxx.xxx.xxx 80
- frp 支持 tcp, udp, http, https 协议, 高性能
- 用反向隧道的ssh
- lanproxy: 支持tcp流量转发
- natapp: 基于ngrok, 比花生壳好用

# 工具
作者：予墨白 链接：https://www.zhihu.com/question/49629610/answer/190228044

GO实现的：
- longXboy/lunnel  这个功能挺多的看介绍跟frp差不多了
- mirrors/dog-tunnel 这个看起来似乎更多使用

javascript实现的：
- localtunnel/localtunnel  这个就不上档次了，貌似只支持http协议的隧道；不过star数可不比上面两个差；

python实现：
- hauntek/python-ngrokd  见名知义， python版本的ngrok；协议都是一样的

C语言版：
- dosgo/ngrok-c

php实现的；也是予墨白近期的一个作品；
- slince/spike；基于reactphp的io多路复用模型，类似于nodejs的执行方式；简单测评并没有比go语言实现的差太多；
