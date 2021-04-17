---
layout: page
title: net-ssl
category: blog
description: 
date: 2018-09-28
---
# Preface
参考阮一峰的[ssl运行机制]，TLS/SSL 基于非对称加密，它解决了以下风险：

1. 窃听风险(eavesdropping): 通过私钥加密避免第三方窃取风险
2. 篡改风险(tampering): 通过检验, 在第三方修改数据时，通信双方可立即检测到. (伪造的私钥所加密的数据无法通过检测)
3. 冒充风险(pretending): 通过证书, 避免中间人攻击. (公钥是和证书一起的，证书可信，公钥就可信)

# TLS/SSL
传输层安全协议（Transport Layer Security，缩写为 TLS），
及其前身安全套接层（Secure Sockets Layer，SSL）是一种安全协议，目的是为互联网通信，提供安全及数据完整性保障。在网景公司（Netscape）推出首版Web浏览器的同时提出SSL，IETF将SSL进行标准化，1999年公布了 TLS标准文件。

TLS/SSL 本身属于应用层，高层的应用层协议（例如：HTTP、FTP、Telnet等等）能透明的建立于TLS协议之上。
它可和http 一起构成了https

TLS 有1.0 1.1 1.2 1.3 三个规范, 目前主流浏览器都支持 TLS1.2

## TLS 协议组成
http://segmentfault.com/a/1190000002963044#articleHeader4
https://segmentfault.com/a/1190000004631778#articleHeader3

协议由两层构成：`TLS Record Protocol`和`TLS Handshake Protocol`

`TLS Record Protocol`处于较低的一层，基于一些可信任的协议，如TCP，为高层协议提供数据封装、压缩、加密等基本功能的支持。它保证了通信的两个基本安全属性：

	1．保密连接。数据传输使用对称加密算法，如AES，RC4等，该对称加密算法的密钥对于每个连接是唯一的，基于密钥协商协议生成，比如TLS handshake protocol，Record Protocol也可以不使用加密。
	2．可信连接。消息的传输包括了基于密钥的消息认证码（keyed MAC），使用安全Hash函数计算MAC，用于完整性检查。Record Protocol也可以不使用MAC，但是这种模式只用于安全参数协商时。

`Record Protocol`用于封装多种高层的协议，其中一个就是`TLS handshake protocol`，这种协议允许客户与服务器相互认证，在应用程序通信前，协商加密算法和加密密钥。`TLS handshake protocol`保证了连接的三个基本安全属性：

	1．两端的身份可以通过非对称或者公钥加密算法（DSA，RSA等）进行认证。认证过程是可选的，但至少要求一端被认证。
	2．共享密钥的协商是安全的。密钥协商对于监听者和任何被认证的连接都是不可见的。
	3．协商是可信的。攻击者无法修改协商信息。

TLS协议提供的服务主要有：

	1）认证用户和服务器，确保数据发送到正确的客户机和服务器；
	2）加密数据以防止数据中途被攻击者监听；
	3）维护数据的完整性，确保数据在传输过程中不被攻击者篡改。

TLS协议在协议栈中如下图所示：

![net-ssl-1.png](/img/net-ssl-1.png)

## 握手过程(TLS Handshake Protocol)
再来看HTTPs链接，它也采用TCP协议发送数据，所以它也需要上面三步握手过程。而且，在这三步结束以后，它还有一个SSL握手:

（1） 客户端向服务器端索要并验证公钥。
（2） 双方协商生成"对话密钥"。
（3） 双方采用"对话密钥"进行加密通信。

4步握手图
![net-ssl-2.png](/img/net-ssl-2.png)
握手抓包图
![net-ssl-4.png](/img/net-ssl-4.png)

### 客户端发出请求（ClientHello）
首先，客户端先向服务器发出加密通信的请求，这被叫做ClientHello请求。

	（1） 支持的协议版本，比如TLS 1.0版。
	（2） 一个客户端生成的随机数，稍后用于生成"对话密钥"。
	（3） 支持的加密方法(Cipher Specs/Suite)，比如RSA公钥加密。
	（4） 支持的压缩方法。

![net-ssl-5.png](/img/net-ssl-5.png)

Cipher Specs/Suite字段是一个枚举类型，说明了客户端所支持算法

    cipher suites(26 suites)
        Cipher Suite: TLS_EMPTY_RENEGOTIATION_INFO_SCSV (0x00ff)
        Cipher Suite: TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384 (0xc02c)
        Cipher Suite: TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256 (0xc02b)
        Cipher Suite: TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384 (0xc024)
        ...

### 服务器回应（SeverHello）
服务器收到客户端请求后，向客户端发出回应，这叫做SeverHello。服务器的回应包含以下内容。

	（1）Version: 确认使用的加密通信协议版本，比如TLS 1.0版本。如果浏览器与服务器支持的版本不一致，服务器关闭加密通信。
	（2）Random(PRF): 一个服务器生成的随机数，稍后用于生成"对话密钥"。
	（3）Cipher Suite: 确认使用的加密方法，比如RSA公钥加密。
	（4）Certificate:(第二个响应) 服务器证书。

![net-ssl-7.png](/img/net-ssl-7.png)
![net-ssl-8.png](/img/net-ssl-8.png)

除了上面这些信息，如果服务器需要确认客户端的身份，就会再包含一项请求，要求客户端提供"客户端证书"。比如，USB密钥，里面就包含了一张客户端证书。

### 客户端回应
客户端收到服务器回应以后，首先验证服务器证书。 如果证书没有问题，客户端就会从证书中取出服务器的公钥。然后，向服务器发送下面三项信息。

	（1） 一个随机数。该随机数用服务器公钥加密，防止被窃听。
	（2） 编码改变通知，表示随后的信息都将用双方商定的加密方法和密钥发送。
	（3） 客户端握手结束通知，表示客户端的握手阶段已经结束。这一项同时也是前面发送的所有内容的hash值，用来供服务器校验。

上面第一项的随机数，是整个握手阶段出现的第三个随机数，又称"pre-master key"。
然后用服务器证书的公钥对其加密，然后将加密后的“预主密钥”传给服务器（Handshake:Client key exchange）

![net-ssl-9.png](/img/net-ssl-9.png)

1. 预主密钥的传输使用*RSA*进行了加密，所以无法在抓取的数据包中显示出来（在上图中的Encrypted Handshake Message），从而保证了握手过程的保密性。

2. 如果服务端要求客户的身份认证，用户将这个含有签名的*随机数*和客户*自己的证书*以及加密过的*预主密码*（Premaster secret）一起传给服务端。

#### 随机数
客户端和服务器就同时有了三个随机数，最终双方会用事先商定的加密方法，各自生成本次会话所用的同一把"*会话主密钥*（Master secret）"

至于为什么一定要用三个随机数:
1. 不信任双方产生的随机数足够随机uu
2. 客户端和服务器加上pre master secret三个随机数一同生成的密钥就不容易被猜出了，一个伪随机可能完全不随机，可是是三个伪随机就十分接近随机了，每增加一个自由度，随机性增加的可不是一。"

### 确认主密钥及结束握手
客户端向服务器端发出信息（Change cipher spec），指明数据通讯将使用主密码为对称密钥, 同时通知对方握手结束
服务器向客户端发出信息（Change Cipher Spec），指明数据通讯将使用主密码为对称密钥，同时通知客户端服务器端的握手过程结束。

![net-ssl-11.png](/img/net-ssl-11.png)

### http 通信
SSL 的握手部分结束，SSL 安全通道的数据通讯开始，客户和服务器开始使用相同的对称密钥进行数据通讯，
![net-ssl-10.png](/img/net-ssl-10.png)
从此过程开始，TLS Record层使用Application Data Protocol: http通信，

![net-ssl-3.png](/img/net-ssl-3.png)

# cdn的https
http://www.ruanyifeng.com/blog/2014/09/illustration-ssl.html

某些客户（比如银行）想要使用外部CDN，加快自家网站的访问速度，但是出于安全考虑，不能把私钥交给CDN服务商。这时，完全可以把私钥留在自家服务器，只用来解密对话密钥，其他步骤都让CDN服务商去完成。

![net-ssl-cdn.png](/img/net-ssl-cdn.png)

# 密钥交换和密钥协商
在客户端和服务器开始交换 TLS 所保护的加密信息之前，他们必须安全地交换或协定加密密钥和加密数据时要使用的密码。

用于密钥交换的方法包括：

- 使用 RSA 算法生成公钥和私钥（在 TLS 握手协议中被称为 TLS_RSA），
- Diffie-Hellman（在 TLS 握手协议中被称为 TLS_DH），
- 临时 Diffie-Hellman（在 TLS 握手协议中被称为 TLS_DHE），
- 椭圆曲线 Diffie-Hellman （在 TLS 握手协议中被称为 TLS_ECDH），
- 临时椭圆曲线 Diffie-Hellman（在 TLS 握手协议中被称为 TLS_ECDHE），
- 匿名 Diffie-Hellman（在 TLS 握手协议中被称为 TLS_DH_anon）[12]
- 和预共享密钥（在 TLS 握手协议中被称为 TLS_PSK）。[13]

只有临时 TLS_DHE 和 TLS_ECDHE 提供前向保密能力。

## DH 算法握手
*整个握手阶段都不加密*（也没法加密），都是明文的。因此，如果有人窃听通信，他可以知道双方选择的加密方法，以及三个随机数中的两个。整个通话的安全，只取决于第三个随机数（Premaster secret）能不能被破解。

虽然理论上，只要服务器的公钥足够长（比如2048位），那么Premaster secret可以保证不被破解。但是为了足够*安全*，我们可以考虑把握手阶段的算法从默认的RSA算法，改为 *Diffie-Hellman算法*（简称DH算法）。

采用DH算法后，Premaster secret不需要在第3步第4步传递，双方只要交换各自的参数，就可以算出这个随机数。
这样就提高了安全性。
![net-ssl-dh.png](/img/net-ssl-dh.png)

## session的恢复
对话中断，就需要重新握手, 这时有两种方法可以恢复原来的session：

1. 一种叫做session ID: 下次重连的时候，只要客户端给出这个编号，且服务器有这个编号的记录
2. 另一种叫做session ticket: 客户端发送过来的session ticket，只有服务器才能解密，其中包括: 本次对话的主要信息，比如对话密钥和加密方法。

session ID往往只保留在一台服务器上。所以，如果客户端的请求发到另一台服务器，就无法恢复对话, 就可以使用session ticket 恢复

# CA
SSL/TLS 是基于非对称加密的，客户端需要通过服务端的公钥以确认服务端的身份，所以：

*确认服务器的身份*

1. 客户端需要先拿到服务端的公钥, 这个公钥放在服务端的证书中。但是如何确认证书可信？
2. CA 确认

*生成对话密钥*
确认身份后，如何通信呢? 如果用服务端的公钥/私钥通信，会存在一些问题：

1. 如果用客户端用服务端的公钥加密信息A，第三方也可以用这个公钥加密信息, 但是第三方拿不到原始的消息A. 所以第三方无法冒充客户发送消息
2. 如果服务用私钥加密消息，客户端和第三方都有公钥，大家都可以解出这个消息. 所以服务器的私钥加密的消息必须是公开性质的，比如服务器的证书.
	所以服务端返回的消息需要用其它密钥加密，比如会话密钥。
3. 非对称加密速度非常慢, 而对称密钥通信很快。

所以实际的SSL 数据通信方法是：
每次会话(session) 客户端和服务端之间都生成一个对话密钥(session key), 这个基于对称加密的密钥 用于加密数据，速度非常快

*进行加密通信*

总结一下通信过程：

	（1） 客户端向服务器端索要并验证公钥。
	（2） 双方协商生成"对话密钥"。
	（3） 双方采用"对话密钥"进行加密通信。

# References
- [nginx_https]
- [wiki_ssl]
- [ssl运行机制]
- [illustration-ssl]
- [nginx ssl]

[nginx ssl]: http://www.lovelucy.info/nginx-ssl-certificate-https-website.html
[ssl运行机制]: http://www.ruanyifeng.com/blog/2014/02/ssl_tls.html
[illustration-ssl]: http://www.ruanyifeng.com/blog/2014/09/illustration-ssl.html
[wiki_ssl]: http://zh.wikipedia.org/wiki/%E5%82%B3%E8%BC%B8%E5%B1%A4%E5%AE%89%E5%85%A8%E5%8D%94%E8%AD%B0
[nginx_https]: http://nginx.org/cn/docs/http/configuring_https_servers.html
