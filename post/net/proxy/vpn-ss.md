---
title: vpn ss
category: blog
private: true
---
# IP security
webrtc会暴露自己的真实ips
https://diafygi.github.io/webrtc-ips/ 通过js webrtc 获取ip

禁用 WebRTC
https://chrome.google.com/webstore/detail/webrtc-block/nphkkbaidamjmhfanlpblblcadhfbkdm?hl=en


# VPS
## 机场
- https://github.com/jichangzhu/JichangTuijian?tab=readme-ov-file

## 自建
- tcp 最强协议：Xray core 的 reality 协议
    singbox + reality 协议，nftables 设置端口白名单，指定 ip 才能访问
- udp 最强协议：hysteria2
### trojan-go
> 与SS/SSR等工具不同，trojan将通信流量转换成https/tls
v2ray和trojan有如下区别及特点：

1. v2ray是一个网络框架，功能齐全；
2. v2ray和trojan都能实现https流量伪装；

# 客户端
## ss
## clash
> bwg.md
1. clash
2. clash.meta  基于clash开源的二次开发
3. clash verge (v2ex推荐 tauri 开发)
    Clash.Meta(mihomo)内核
    Clash Verge Rev会显示节点类型，比如SS或者Trojan，以及是否支持UDP。默认就显示节点延迟。


## openvpn on mac osx
1. 可在 https://tunnelblick.net/downloads.html 下载最新版本
2. 双击刚下载到的安装包完成tunnelblick软件安装
3. 从vpn.xxx.com下载VPN配置文件（client.ovpn），放在桌面。新建一个文件夹，将client.ovpn放入新建文件夹中，并将文件夹重命名为deshi.tblk(后缀必须是tblk)
重命名后，文件夹的图标会发生变化，再双击deshi.tblk根据指引完成后续操作
4. 再就可以在应用程序中找到tunnelblick，运行并选择deshi配置来连接VPN了
5. 请记得24小时内需要登录一次vpn.xxx.com。初次运行时会要求mac的用户名和密码，以便于tunnelblick修改network
6. tunnelblick的Set DNS/WINS请选择set nameserver 3.1，否则可能链接不上

## citrix
http://wiki.open.qq.com/index.php?title=%E8%B7%B3%E6%9D%BF%E6%9C%BA%E7%99%BB%E5%BD%95%E8%AF%B4%E6%98%8E&oldid=22191#.E4.BD.BF.E7.94.A8Linux.E8.B7.B3.E6.9D.BF.E6.9C.BA.E7.99.BB.E5.BD.95.E5.88.B0Linux.E5.BA.94.E7.94.A8.E6.9C.8D.E5.8A.A1.E5.99.A8.E7.9A.84.E6.AD.A5.E9.AA.A4


# google ip
## find ip
命令行输入：nslookup g.cn

    nslookup g.cn ns1.google.com
    dig g.cn @ns1.google.com

google的dns服务器常见的有：

ns1.google.com
ns2.google.com
ns3.google.com
ns4.google.com
8.8.8.8
8.8.4.4

## google 最新打开方法
因为google香港禁用了安全搜索 这个时候你需要 https://google.com/ncr 打开这个网址 Google就不会自动跳转了 或者进入https://encrypted.google.com 解除google的搜索限制 这个是完全加密的

Chrome浏览器可以用地址栏搜索 用ncr的参数应该是

	https://www.google.com/#lr=lang_zh-CN&newwindow=1&q=%s
