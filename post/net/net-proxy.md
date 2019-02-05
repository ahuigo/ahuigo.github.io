---
layout: page
title:	shell proxy
category: blog
description:
---
# Android
HowTo: Proxy Non-Proxy-Aware Android Applications through Burp
http://blog.dornea.nu/2014/12/02/howto-proxy-non-proxy-aware-android-applications-through-burp/

# Within shell

## http proxy
### http proxy env
Set http_proxy shell variable on Linux/OS X/Unix bash shell

Type the following command to set proxy server:

	$ export http_proxy=http://server-ip:port/
	export http_proxy=http://127.0.0.1:8888/

If the proxy server requires a username and password then add these to the URL. For example, to include the username foo and the password bar:

	$ export http_proxy=http://foo:bar@server-ip:port/
	$ export http_proxy=http://foo:bar@127.0.0.1:3128/
	$ export http_proxy=http://USERNAME:PASSWORD@proxy-server.mycorp.com:3128/

> 另外，还有一个https_proxy

### node-http-proxy
support https

    var http = require('http');
    var httpProxy = require('http-proxy');
    var proxy = httpProxy.createProxyServer({});

    var server = http.createServer(function(req, res) {
        console.log(req.url);
        proxy.web(req, res, { target: 'http://127.0.0.1:7001' }); 
    }).listen(3399, function(){
        console.log("listen chrome request");
    });

### fiddle/charles

## socks5
参考: [在终端下间接使用Socks5代理的几种方法(privoxy,tsocks,proxychains) ][privoxy,tsocks,proxychains]
Comparison_of_proxifiers:
https://en.wikipedia.org/wiki/Comparison_of_proxifiers

### graftcp
graftcp 可以把任何指定程序（应用程序、脚本、shell 等）的 TCP 连接重定向到 SOCKS5 代理。
https://www.v2ex.com/t/476594

1. 对比 tsocks、proxychains 或 proxyChains-ng，graftcp 并不使用 LD_PRELOAD 技巧来劫持共享库的 connect()、getaddrinfo() 等系列函数达到重定向目的，这种方法只对使用动态链接编译的程序有效，对于静态链接编译出来的程序，例如默认选项编译的 Go 程序，proxychains-ng 就无效了。
2. graftcp 使用 ptrace(2) 系统调用跟踪或修改任意指定程序的 connect 信息，对任何程序都有效。

工作原理后面将会解释。

#### 使用
假设你正在运行默认地址 "localhost:1080" 的 SOCKS5 代理，首先启动 graftcp-local：

    ./graftcp-local/graftcp-local

通过 graftcp 安装来自 golang.org 的 Go 包:

    ./graftcp go get -v golang.org/x/net/proxy

如果是一个已经运行的程序， graftcp 目前没有实现对正在运行的进程 attach 进行跟踪。
1. Linux 里 ptrace 可以跟踪一个没有血缘关系的运行时进程，但需要以 root 权限修改默认的 `/proc/sys/kernel/yama/ptrace_scope` 值为 0：
    1. `echo "0" > /proc/sys/kernel/yama/ptrace_scope`

### proxychains
> https://github.com/shadowsocks/shadowsocks/wiki/Using-Shadowsocks-with-Command-Line-Tools

proxychains 调用的好像是Privoxy, 在mac 需要:

1. csrutil enable --without debug
2. cp /usr/bin/xx /usr/local/bin

On Mac OS X:

	brew install proxychains-ng

Make a config file at `~/.proxychains/proxychains.conf` with content:

	strict_chain
	proxy_dns
	remote_dns_subnet 224
	tcp_read_time_out 15000
	tcp_connect_time_out 8000
	localnet 127.0.0.0/255.0.0.0
	quiet_mode

	[ProxyList]
	# type host port [user pass]
	socks5  127.0.0.1 1080

Then run command with proxychains. Examples:

	proxychains4 curl https://www.twitter.com/
	proxychains4 git push origin master
    proxychains4 curl 'http://1212.ip138.com/ic.asp'

Or just proxify bash:

	proxychains4 bash
	curl https://www.twitter.com/
	git push origin master

### Proximac
Proximac is an command-line alternative to Proxifier.
1. It can fowward `any App's` traffic to a certain Socks5 proxy
2. Moreover, Proximac now can forward all network traffic in your system to a proxy which means you may not need a VPN to do this job.

#### Usage
If you plan to use Proximac on OSX 10.10+, please run

	sudo nvram boot-args="debug=0x146 kext-dev-mode=1"

For 10.11, do Restart -> Press COMMAND + R -> Recovery Mode -> Terminal ->

	csrutil enable --without kext --without debug.

### tsocks
需要这样使用 比如使用curl  的使用 tsocks curl 这样启动软件才能走代理

	sudo apt-get install tsocks
	vim /etc/tsocks.conf
        server = 127.0.0.1
        server_type = 5
        server_port = 1080

brew install tsocks: https://github.com/Anakros/homebrew-tsocks

	tap repo: brew tap Anakros/homebrew-tsocks
	install tsocks: brew install --HEAD tsocks
	set up socks proxy: ssh -D 1080 server
	edit configuration file: vim /usr/local/etc/tsocks.conf
	set server as localhost: server = localhost
	set server port as 5555: server_port = 1080
	check that everything works: tsocks curl ifconfig.me

配置：

	#本地子网不使用代理
	local = 192.168.0.0/255.255.255.0
	local = 10.0.0.0/255.0.0.0
	local = 127.0.0.1/255.255.255.255

	#例外网站。这里列出来的网站不通过默认服务器走，而是通过特定的服务器走。server_type规定了这是一个socks5代理服务器
	path {
	        reaches = 150.0.0.0/255.255.0.0
	        reaches = 150.1.0.0:80/255.255.0.0
	        server = 10.1.7.25
	        server_type = 5
	        default_user = delius
	        default_pass = hello
	}

	# socks server
	server = 192.168.0.1
	# Server type defaults to 4 so we need to specify it as 5 for this one
	server_type = 5
	server_port = 1080

只是，tsocks 不支持`setuid program`(eg. [ssh](http://tsocks.sourceforge.net/faq.php#ssh)),
> 其官方网站推荐了另外一个替代品,Dante，这个配置有点复杂

使用：

	$ tsocks wget ....

### Privoxy
1. 将http代理转发至 socks5/socks4 代理: 能支持http 代理的命令就可以用了
2. 支持类似PAC 的自动代理

Privoxy 配置

	forward-socks5	/	127.0.0.1:1080	.    # socks v5
	forward-socks5t	/	127.0.0.1:1080	.    # socks v5, reduce the latency for the newly connection.(可能有问题)

默认的`listen-address 127.0.0.1:8080`, 转发到socks5:
1. /代表所有的URL都转发，
2. 127.0.0.1:1080 是socks代理的位置，
3. `.`代表没有设置http代理地址。

安装(Mac osx)

	$ brew install Privoxy
	echo "forward-socks5   /               127.0.0.1:1080 .  " >> /usr/local/etc/privoxy/config
	gsed  -ir 's/^listen-address  127.0.0.1:8118/listen-address :8080/' /usr/local/etc/privoxy/config

启动

	$ brew info Privoxy
	To have launchd start privoxy at login:
	  ln -sfv /usr/local/opt/privoxy/*.plist ~/Library/LaunchAgents
	Then to load privoxy now:
	  launchctl load ~/Library/LaunchAgents/homebrew.mxcl.privoxy.plist
	Or, if you don't want/need launchctl, you can just run:
	  privoxy /usr/local/etc/privoxy/config

# iptables 全局代理
http://blog.csdn.net/decken_h/article/details/45306391
linux下实现全局  使用 iptables 做 REDIRECT

另外 Linux 里可以用 iptables + redsocks + shadowsocks 实现系统全局代理

> 试下 proxyCap

# shell proxy
You can simply use wget command as follows:

	$ export https_proxy=http://proxy-server.mycorp.com:3128/
	$ export https_proxy=http://USERNAME:PASSWORD@proxy-server.mycorp.com:3128/
	$ wget --proxy-user=USERNAME --proxy-password=PASSWORD http://path.to.domain.com/some.html

Lynx command has the following syntax:

	$ lynx -pauth=USER:PASSWORD http://domain.com/path/html.file

Curl command has following syntax:

	$ curl --proxy-user user:password http://url.com/
	$ curl --proxy-user user:password -x proxy:port http://url.com/
	$ curl -U user:password -x proxy:port http://url.com/

	curl --socks5 127.0.0.1:1080

ab command

	-X proxy:port   Proxyserver and port number to use
	-P attribute    Add Basic Proxy Authentication, the attributes
                    are a colon separated username and password. "user:pwd"
                    
## curl proxy
curl 可以用配置全局代理， 编辑~/.curlrc:
    
    socks5 = "127.0.0.1:1080"


## wget proxy
Via ~/.wgetrc file:

	use_proxy=yes
	http_proxy=127.0.0.1:8080

or via -e options placed after the URL:

	wget ... -e use_proxy=yes -e http_proxy=127.0.0.1:8080 ...

# 内网穿透
都是通过公网做转接

- ngrok
将处于内网的开发机服务暴露到公网上，就是类似 花生壳[ngrok](/p/net-proxy-ngrok)
./ngrok -config=ngrok.cfg -subdomain <domain> 80
./ngrok -config=ngrok.cfg -hostname xxx.xxx.xxx 80
-frp
frp 比较ngrok 是开源的

- 用反向隧道的方式ssh

- GO实现的：
longXboy/lunnel  这个功能挺多的看介绍跟frp差不多了
mirrors/dog-tunnel 这个看起来似乎更多使用

javascript实现的：
- localtunnel/localtunnel  这个就不上档次了，貌似只支持http协议的隧道；不过star数可不比上面两个差；

python实现：
- hauntek/python-ngrokd  见名知义， python版本的ngrok；协议都是一样的

C语言版：
- dosgo/ngrok-c

php实现的；也是予墨白近期的一个作品；
- slince/spike；基于reactphp的io多路复用模型，类似于nodejs的执行方式；简单测评并没有比go语言实现的差太多；

作者：予墨白
链接：https://www.zhihu.com/question/49629610/answer/190228044

# PAC Proxy
Proxies in network

## WPAD (Auto Proxy Discovery)
Setting up Web Proxy Autodiscovery Protocol (WPAD) using DNS
Refer to :
http://tektab.com/2012/09/26/setting-up-web-proxy-autodiscovery-protocol-wpad-using-dns/

1. To use WPAD using DNS method a DNS entry is needed for a host named WPAD. This name should be resolvable from the clients machine
1. Web server must be configured to serve the WPAD file with a MIME type of “application/x-ns-proxy-autoconfig”
1. A file named wpad.dat must be located in the WPAD Web server’s root directory.
1. The host at the WPAD address must be able to serve a Web page.
So if you are a member of example.com domain the browser is looking for this url for the PAC file http://wpad.example.com/wpad.dat

wpad.dat example:

	function FindProxyForURL(url, host) {
		var PROXY = "PROXY 192.168.0.100:8080";
		var PROXY_US = "SOCKS 192.168.0.100:9090";
		var PROXY_US_NEW = "PROXY 192.168.0.102:8080";
		var DEFAULT = "DIRECT";

		if(shExpMatch(host, "*pandora.com")) return PROXY_US;
		if(shExpMatch(host, "*blog.udn.com")) return PROXY;
		return DEFAULT;
	}

## Automatic Proxy Configuration
Proxy Auto Configuration file(PAC)

	http://127.0.0.1:8090/proxy.pac

1. In the `Network` Configure `Proxies` dropdown menu, select Using A PAC File
1. In the PAC File URL field, enter
`http://wpad/wpad.dat`
1. Click on Apply

# vpn
smart vpn
http://huzi.name/2015/04/28/mac-smart-vpn/

# UniFi
https://help.ubnt.com/hc/en-us/articles/360002426234-UniFi-USG-VPN-How-to-Configure-Site-to-Site-VPN

# Reference
- [在终端下间接使用Socks5代理的几种方法(privoxy,tsocks,proxychains) ][privoxy,tsocks,proxychains]

[privoxy,tsocks,proxychains]: http://blog.ihipop.info/2011/01/1988.html
