---
layout: page
title: IP
category: blog
description: 
date: 2018-09-28
---
# IP
webrtc会暴露自己的真实ips
https://diafygi.github.io/webrtc-ips/ 通过js webrtc 获取ip

禁用 WebRTC
https://chrome.google.com/webstore/detail/webrtc-block/nphkkbaidamjmhfanlpblblcadhfbkdm?hl=en

# ss
给shadowsocks插上tcptun,bbr这对翅膀
http://farwmarth.com/vultr/
https://home4love.com/3154.html
救急用，不要滥用
https://free.wuqu.ml/

# 下载goagent-git
archlinux 下使用:

	yaourt -S goagent-git

## 安装 crt 在 firefox/chrome

## 下载  Proxy SwitchySharp in chrome
	并设置代理为goagent代理
	http://127.0.0.1:8087

## edit /opt/goagent/local/proxy.ini
	appid = appid1|appid2

# 上传 server
用sdk工具来上传其实很方便

## download appengine sdk
	https://developers.google.com/appengine/downloads

## upload

### 打开app.yaml指定自己的appid
	sudo vim /opt/goagent/server/python/app.yaml

### 上传server
	python google_appengine/appcfg.py update goagent/server/python/

> 撤消证书认证 如果你绑定过hosts，那么你无法通过证书验证

	fancy_urllib.InvalidCertificateException: Host appengine.google.com returned an invalid certificate (hostname mismatch):

> 那么就过滤掉认证代码： vim /home/hilo/test/google_appengine/lib/fancy_urllib/fancy_urllib/__init__.py

	#        if self.cert_reqs & ssl.CERT_REQUIRED:
	#          cert = self.sock.getpeercert()
	#          hostname = self.host.split(':', 0)[0]
	#          if not self._validate_certificate_hostname(cert, hostname):
	#            raise InvalidCertificateException(hostname, cert,
	#        'hostname mismatch')

# 运行

## 运行goagent代理
	sudo /opt/goagent/local/proxy.py

## 打开你的chrome访问这个代理
	利用proxy swith插件可以很方便的在代理和直连间切换
	如果你不会正则，也可以用通配符，比如*.google.com/*

# 科学上网
除了使用goagent 外, 还有一些简单的方法实现科学上网，我在此做一个归纳。

> 使用代理工具时，请尽量使用SwitchySharp 等具备pac 功能的工具, 实现在访问被q的网站时自动走代理

## google search的替代
如果只是想使用google 查资料，可以选择各位大神搭建的代理：

	http://www.glgoo.com
	http://www.clonegoogle.com
	http://www.gusou.co
	http://g.ttlsa.com

## VPN
方法一：
轻云,相比 曲径 来说，价格更优惠，设置简单

方法二：
购买 VPN:

1. Green 网络加速器：这家算下来也不算贵。也有不少人购买了这个服务。支持多平台，iOS/Android 上都有 App 应用，使用简单。
1. 风驰加速器：算是老牌 VPN 提供商了吧，我个人用了两年多，包括现在还有设备是使用它们家 VPN 的。Windows 下有客户端，其他终端上也提供配置文件一键安装，使用简单，适合新手使用。

1. CocoVPN：也是很老的一家了，价格很便宜，不提供每月免费使用额度，需要试用可以问客服要。够稳定，强烈推荐。

1. 红帽子网络加速器：这家做了大概两年时间吧，和风驰差不多，也提供 windows 客户端和各个平台的配置文件。

## VPS
oneasiahost, 12$/3 month
vultr, at japanese, 30RMB/month

## lantern
127.0.0.1:8787

## Ss

### 免费的ss
https://www.freess.party﻿
https://plus.google.com/communities/112474836283977223682

### bandwagonhost
用 bandwagonhost /digital ocean/linode 等搭建

## 购买
IAMSMART5FQ956
http://banwagong.cn/youhui.html

$3.99 年付的好像没有了

Monthly 价格
https://bandwagonhost.com/vps-hosting.php
$2.99 10G SSD/256M RAM/128M xSWAP/500M Bandwidth/
$4.99 20G SSD/512M RAM/256M xSWAP/1000M Bandwidth/

测试：
https://www.v2ex.com/t/97626


Install:
http://www.jianshu.com/p/08ba65d1f91a
or
https://github.com/ahuigo/php-lib/blob/master/app/ss.sh

Client:
https://github.com/shadowsocks/shadowsocks-gui

更多工具见:
http://www.jianshu.com/collection/b6b16295fc83

### config
/Applications/ShadowsocksX.app/Contents//Resources/abp.js

### debug
大量的 Error: read ECONNRESET，如何解决？
可能是公司的网关限制了socks5:
http://www.v2ex.com/t/117994


## 其它网站的科学上网
如果你所访问的网站被q了，你可以通过以下地址查找网站对应的ip, 选择一个速度快一点ip 并在hosts中做绑定，可以实现对绝大部分网站的访问（除了facebook/twitter 等, 无论ipv4还是ipv6都不行）

Query site's ip:
- 1. http://just-ping.com/
- 2. http://whatismyipaddress.com/
- 3. PingInfoView (software)

# citrix
http://wiki.open.qq.com/index.php?title=%E8%B7%B3%E6%9D%BF%E6%9C%BA%E7%99%BB%E5%BD%95%E8%AF%B4%E6%98%8E&oldid=22191#.E4.BD.BF.E7.94.A8Linux.E8.B7.B3.E6.9D.BF.E6.9C.BA.E7.99.BB.E5.BD.95.E5.88.B0Linux.E5.BA.94.E7.94.A8.E6.9C.8D.E5.8A.A1.E5.99.A8.E7.9A.84.E6.AD.A5.E9.AA.A4

# openvpn

## mac osx

1. 可在 https://tunnelblick.net/downloads.html 下载最新版本

2. 双击刚下载到的安装包完成tunnelblick软件安装

3. 从vpn.xxx.com下载VPN配置文件（client.ovpn），放在桌面。新建一个文件夹，将client.ovpn放入新建文件夹中，并将文件夹重命名为deshi.tblk(后缀必须是tblk)
重命名后，文件夹的图标会发生变化，再双击deshi.tblk根据指引完成后续操作

4. 再就可以在应用程序中找到tunnelblick，运行并选择deshi配置来连接VPN了

5. 请记得24小时内需要登录一次vpn.xxx.com。初次运行时会要求mac的用户名和密码，以便于tunnelblick修改network
6. tunnelblick的Set DNS/WINS请选择set nameserver 3.1，否则可能链接不上

# google ip
给两个测试google ip的方法

1. 最简单的测试方法就是在Chrome中以https方式访问该IP地址，如果返回信息中提示该服务器为google.com或带国家地区后缀如google.com.hk的服务器，则此IP确认100%可用。如果返回信息是其他Goolge服务器，则不建议使用。
2. 使用wget

	wget --content-disposition --no-check-certificate --tries=1 -T 10 https://ip
	#Example
	wget --content-disposition --no-check-certificate --tries=1 -T 10 https://149.126.86.44


149.126.86.44
74.125.12.3

美国：
74.125.128.*

北京：
203.208.46.*


/*Bulgaria*/
93.123.23.1/59

/*Egypt*/
197.199.253.1/59

/*Egypt*/
197.199.254.1/59

/*Hong Kong*/
218.189.25.129/187
218.253.0.76/92
218.253.0.140/187

/*Iceland*/
149.126.86.1/59

/*Indonesia*/
111.92.162.4/6
111.92.162.12/59

/*Iraq*/
62.201.216.196/251

/*Japan*/
218.176.242.4/251

/*Kenya*/
41.84.159.12/30

/*Korea*/
121.78.74.68/123

/*Mauritius*/
41.206.96.1/251

/*Netherlands*/
88.159.13.196/251

/*Norway*/
193.90.147.0/7
193.90.147.12/59
193.90.147.76/123

/*Philippines*/
103.25.178.4/6
103.25.178.12/59

/*Russia*/
178.45.251.4/123

/*Saudi Arabia*/
84.235.77.1/251

/*Serbia*/
213.240.44.5/27

/*Singapore*/
203.116.165.129/255
203.117.34.132/187

/*Slovakia*/
62.197.198.193/251
87.244.198.161/187

/*Taiwan*/
123.205.250.68/190
123.205.251.68/123
163.28.116.1/59
163.28.83.143/187
202.39.143.1/123
203.211.0.4/59
203.66.124.129/251
210.61.221.65/187
60.199.175.1/187
61.219.131.65/251

/*China*/
203.208.41.1/199
/*Beijing*/
203.208.32.0 - 203.208.63.255

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

# 解除youtube限制
解除地区限制方法一：goagent的GAE代理方式可以通过修改配置文件的方法解除部分限制，简单原理就是让Youtube判断你访问视频使用的ip为中国ip，而不是默认的GAE出口ip。这项设置在新版本配置文件中本身就有，只不过默认没有开启，将该行前面的注释符;编辑掉即可开启，参考如下。

	https?://www.youtube.com/watch = google_hk

方法二：选择没有限制的出口ip做代理。可以自己找个无限制ip的php或者PaaS空间.

参阅：[解除youtube限制](http://www.faith.ga/1976.html)


# google 最新打开方法

可靠的hosts 比如 https://git.oschina.net/kawaiiushio/misc/raw/master/hosts/pc/hosts

然后 你还需要个靠谱的DNS服务器 比如 https://code.google.com/p/openerdns/ 或者 http://alidns.com/

推荐各位使用Chrome浏览器 对自己家的Google有神秘加成 http://ippotsuko.com/blog/open-google/

或许你还需要https://code.google.com/p/smartladder/ 这样你就可以访问其他受限制的网站了 安卓手机可以用 https://fqrouter.duapp.com

如果上面那个也没用了 你可以尝试我的ss服务 http://ippotsuko.com/ss （支持全平台 包括Windows,Mac,Linux,iOS,Android等等 甚至你家的路由器也可以用）

Google搜索服务优化

Google会根据你的地区自动切换搜索的语言 在大陆是自动跳转到谷歌香港 你懂的 如果你要搜索一些奇奇怪怪的东西 是很难的 因为google香港禁用了安全搜索 这个时候你需要 https://google.com/ncr 打开这个网址 Google就不会自动跳转了 或者进入https://encrypted.google.com 解除google的搜索限制 这个是完全加密的

Chrome浏览器可以用地址栏搜索 用ncr的参数应该是

	https://www.google.com/#lr=lang_zh-CN&newwindow=1&q=%s