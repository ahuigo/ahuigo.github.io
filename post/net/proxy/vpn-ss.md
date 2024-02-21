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

# 科学上网
## ss
## clash

    clash
    clash.meta 
    clash verge (v2ex推荐)

## VPS
一元机场

## 其它网站的科学上网
如果你所访问的网站被q了，你可以通过以下地址查找网站对应的ip, 选择一个速度快一点ip 并在hosts中做绑定，可以实现对绝大部分网站的访问（除了facebook/twitter 等, 无论ipv4还是ipv6都不行）

Query site's ip:
- 1. http://just-ping.com/
- 2. http://whatismyipaddress.com/
- 3. PingInfoView (software)

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
## test ip
给两个测试google ip的方法

1. 最简单的测试方法就是在Chrome中以https方式访问该IP地址，如果返回信息中提示该服务器为google.com或带国家地区后缀如google.com.hk的服务器，则此IP确认100%可用。如果返回信息是其他Goolge服务器，则不建议使用。
2. 使用wget

	wget --content-disposition --no-check-certificate --tries=1 -T 10 https://ip
	#Example
	wget --content-disposition --no-check-certificate --tries=1 -T 10 https://149.126.86.44

## find ip
1.先在命令行输入：nslookup g.cn

得到的是本地dns服务器解析出的g.cn的IP地址。

2.在命令行下输入：nslookup g.cn ns1.google.com
得到的是使用google的dns服务器ns1.google.com解析出的g.cn的IP地址。
google的dns服务器常见的有：

ns1.google.com
ns2.google.com
ns3.google.com
ns4.google.com
8.8.8.8
8.8.4.4

- http://www.kookle.co.nr/ 也有数千个 GGC IP 地址，还嫌少的可以去看看。

## 解除youtube限制
解除地区限制方法一：goagent的GAE代理方式可以通过修改配置文件的方法解除部分限制，简单原理就是让Youtube判断你访问视频使用的ip为中国ip，而不是默认的GAE出口ip。这项设置在新版本配置文件中本身就有，只不过默认没有开启，将该行前面的注释符;编辑掉即可开启，参考如下。

	https?://www.youtube.com/watch = google_hk

方法二：选择没有限制的出口ip做代理。可以自己找个无限制ip的php或者PaaS空间.

参阅：[解除youtube限制](http://www.faith.ga/1976.html)


## google 最新打开方法
因为google香港禁用了安全搜索 这个时候你需要 https://google.com/ncr 打开这个网址 Google就不会自动跳转了 或者进入https://encrypted.google.com 解除google的搜索限制 这个是完全加密的

Chrome浏览器可以用地址栏搜索 用ncr的参数应该是

	https://www.google.com/#lr=lang_zh-CN&newwindow=1&q=%s