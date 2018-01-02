---
layout: page
title:	
category: blog
description: 
---
# Preface
apache服务器配置文件httpd.conf里的一些描述： 
1、如何设 置请求等待时间 
　　在httpd.conf里面设置： 
　　TimeOut n 
　　其中n为整数，单位是秒。 
　　设置这个TimeOut适用于三种情况： 
　　2、如何接收一个get请求的总时间 
　　接收一个post和put请求的TCP包之间的时间 
　　TCP包传输中的响应（ack）时间间隔 
　　3、如何使得apache监听在特定的端口 
　　修改httpd.conf里面关于Listen的选项，例如： 
　　Listen 8000 
　　是使apache监听在8000端口 
　　而如果要同时指定监听端口和监听地址，可以使用： 
　　Listen 192.170.2.1:80 
　　Listen 192.170.2.5:8000 
　　这样就使得apache同时监听在192.170.2.1的80端口和192.170.2.5的8000端口。 
　　当然也可以在httpd.conf里面设置： 
　　Port 80 
　　这样来实现类似的效果。 

4、如何设置apache的最大空闲进程数 

　　修改httpd.conf，在里面设置： 
　　MaxSpareServers n 
　　其中n是一个整数。这样当空闲进程超过n的时候，apache主进程会杀掉多余的空闲进程而保持空闲进程在n，节省了系统资源。如果在一个apache非常繁忙的站点调节这个参数才是必要的，但是在任何时候把这个参数调到很大都不是一个好主意。 
　　同时也可以设置： 
　　MinSpareServers n 
　　来限制最少空闲进程数目来加快反应速度。 

5、apache如何设置启动时的子服务进程个数 

　　在httpd.conf里面设置： 
　　StartServers 5 
　　这样启动apache后就有5个空闲子进程等待接受请求。 
　　也可以参考MinSpareServers和MaxSpareServers设置。 

6、如何在apache中设置每个连接的最大请求数 

　　在httpd.conf里面设置： 
　　MaxKeepAliveRequests 100 
　　这样就能保证在一个连接中，如果同时请求数达到100就不再响应这个连接的新请求，保证了系统资源不会被某个连接大量占用。但是在实际配置中要求尽量把这个数值调高来获得较高的系统性能。 
　　7、如何在apache中设置session的持续时间 
　　在apache1.2以上的版本中，可以在httpd.conf里面设置： 
　　KeepAlive on 
　　KeepAliveTimeout 15 
　　这样就能限制每个session的保持时间是15秒。session的使用可以使得很多请求都可以通过同一个tcp连接来发送，节约了网络资源和系统资源。 
　　8、如何使得apache对客户端进行域名验证 
　　可以在httpd.conf里面设置： 
　　HostnameLookups on|off|double 
　　如果是使用on，那么只有进行一次反查，如果用double，那么进行反查之后还要进行一次正向解析，只有两次的结果互相符合才行，而off就是不进行域名验证。 
　　如果为了安全，建议使用double；为了加快访问速度，建议使用off。 
　　9、如何使得apache只监听在特定的ip 
　　修改httpd.conf，在里面使用 
　　BindAddress 192.168.0.1 
　　这样就能使得apache只监听外界对192.168.0.1的http请求。如果使用： 
　　BindAddress * 
　　就表明apache监听所有网络接口上的http请求。 
　　当然用防火墙也可以实现。 
10、apache中如何限制http请求的消息主体的大小 
　　在httpd.conf里面设置： 
　　LimitRequestBody n 
　　n是整数，单位是byte。 
　　cgi脚本一般把表单里面内容作为消息的主体提交给服务器处理，所以现在消息主体的大小在使用cgi的时候很有用。比如使用cgi来上传文件，如果有设置： 
　　LimitRequestBody 102400 
　　那么上传文件超过100k的时候就会报错。 
　　11、如何修改apache的文档根目录 
　　修改httpd.conf里面的DocumentRoot选项到指定的目录，比如： 
　　DocumentRoot /www/htdocs 
　　这样http://localhost/index.html就是对应/www/htdocs/index.html 
　　12、如何修改apache的最大连接数 
　　在httpd.conf中设置： 
　　MaxClients n 
　　n是整数，表示最大连接数，取值范围在1和256之间，如果要让apache支持更多的连接数，那么需要修改源码中的httpd.h文件，把定义的HARD_SERVER_LIMIT值改大然后再编译。 

　　13、如何使每个用户有独立的cgi-bin目录 
　　有两种可选择的方法： 
　　(1)在Apache配置文件里面关于public_html的设置后面加入下面的属性： 
　　ScriptAliasMatch ^/~([^/]*)/cgi-bin/(.*) /home/$1/cgi-bin/$2 
　　(2)在Apache配置文件里面关于public_html的设置里面加入下面的属性： 
　　<Directory /home/*/public_html/cgi-bin> 
　　　　Options ExecCGI 
　　　　SetHandler cgi-script 
　　</Directory> 
14、如何调整Apache的最大进程数 
Apache允许为请求开的最大进程数是256,MaxClients的限制是256.如果用户多了，用户就只能看到Waiting for reply....然后等到下一个可用进程的出现。这个最大数，是Apache的程序决定的--它的NT版可以有1024，但Unix版只有256，你可以在src/include/httpd.h中看到： 
	#ifndef HARD_SERVER_LIMIT 
	#ifdef WIN32 
	#define HARD_SERVER_LIMIT 1024 
	#else 
	#define HARD_SERVER_LIMIT 256 
	#endif 
	#endif 
	你可以把它调到1024，然后再编译你的系统。 
	　　15、如何屏蔽来自某个Internet地址的用户访问Apache服务器 
　　可以使用deny和allow来限制访问，比如要禁止202.202.202.xx网络的用户访问： 
　　<Directory /www/htdocs> 
　　order deny,allow 
　　deny from 202.202.202.0/24 
　　</Directory> 
　　16、如何在日志里面记录apache浏览器和引用信息 
　　你需要把mod_log_config编译到你的Apache服务器中，然后使用下面类似的配置： 
　　CustomLog logs/access_log "%h %l %u %t "%r" %s %b "%{Referer}i" "%{User-Agent}i"" 
　　17、如何修改Apache返回的头部信息 
　　问题分析：当客户端连接到Apache服务器的时候，Apache一般会返回服务器版本、非缺省模块等信息，例如： 
　　Server: Apache/1.3.26 (Unix) mod_perl/1.26 
　　解决： 
　　你可以在Apache的配置文件里面作如下设置让它返回的关于服务器的信息减少到最少： 
　　ServerTokens Prod 
　　注意： 
　　这样设置以后Apache还会返回一定的服务器信息，比如： 
　　Server: Apache 
　　但是这个不会对服务器安全产生太多的影响，因为很多扫描软件是扫描的时候是不顾你服务器返回的头部信息的。你如果想把服务器返回的相关信息变成： 
　　Server: It iS a nOnE-aPaCHe Server 
　　那么你就要去修改源码了。
