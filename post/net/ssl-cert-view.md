---
title: ssl debug
date: 2023-03-22
private: true
---
# ssl 证书类型
## 证书分类
> Refer to: http://www.ruanyifeng.com/blog/2016/08/migrate-from-http-to-https.html

### 证书级别

    域名认证（Domain Validation）：最低级别认证，可以确认申请人拥有这个域名。对于这种证书，浏览器会在地址栏显示一把锁。
    公司认证（Company Validation）：确认域名所有人是哪一家公司，证书里面会包含公司信息。
    扩展认证（Extended Validation）：最高级别的认证，浏览器地址栏会显示公司名。

### 三种覆盖范围

    单域名证书：只能用于单一域名，foo.com的证书不能用于www.foo.com
    通配符证书：可以用于某个域名及其所有一级子域名，比如*.foo.com的证书可以用于foo.com，也可以用于www.foo.com
    多域名证书：可以用于多个域名，比如foo.com和bar.com

### CA vs Self-Signed
Certificate type:
1. CA: request one from a `certificate authority` like Let’s Encrypt, Comodo, etc. 
2. self signed: generate a `self-signed certificate` on the command line.
    1. 根证书(root.pem)本质上也是自签名证书
    1. 自签名(self.pem)也可以加入到keychain（如果它配置了`basicConstraints = CA:FALSE`，它就不能签发）

## SNI(SSL/TLS Server Name Indication)
同一IP地址和端口下不同域名HTTPS请求的需要服务端和客户端均支持SNI（Server Name Indication）https://en.wikipedia.org/wiki/Server_Name_Indication 协议，在HTTPS请求握手开始阶段指定要请求的域名，以便服务端选择使用相应的证书。

1. 服务端Nginx配置支持是TSL1.0及以上版本，均支持SNI协议，
2. 但若客户端不支持SNI协议，即没有指定要请求的域名，Nginx会优先查找default server中的证书配置，
3. 若没有找到则会按照配置文件字母序查找对应IP端口上第一个配置有证书的域名的证书做为默认证书使用。

## CN vs SAN
> 最新go/chrome 已经不再依赖 CN 来验证服务器的身份，而是优先使用 SAN。这是因为 SAN 提供了更大的灵活性，允许一个证书用于多个服务器域名:

### CN（Common Name）：
> 对于`CN(Common Name) = *.wiki.cn`, chrome 匹配`a.wiki.cn`, 但是不会认匹配`a.b.wiki.cn`, safari 则都匹配
这是证书的主要名称。在 SSL/TLS 证书中，CN 通常是服务器的主机名，例如 www.example.com。在早期的 SSL/TLS 规范中，客户端会检查 CN 是否与服务器的主机名匹配，以验证服务器的身份。

### SAN（Subject Alternative Name）：
这是一个或多个备用的服务器名称，可以是域名、IP 地址、电子邮件地址等。客户端会检查 SAN 列表中的所有名称，如果任何一个名称与服务器的主机名匹配，那么证书就被视为有效。

RFC 2818 describes two methods to match a domain name against a certificate
1. using the available names within the subjectAlternativeName extension
2. or, in the absence of a SAN extension, falling back to the commonName。　This is dprecated, i.e. 
    1. android browser/IoT(Internet of Thing).  
    2. go>=1.15也不支持commonName(certificate relies on legacy Common Name field, use SANs instead)
    3. 参考：https://jfrog.com/knowledge-base/general-what-should-i-do-if-i-get-an-x509-certificate-relies-on-legacy-common-name-field-error/

So now the domain name must be defined in the `Subject Alternative Name (SAN)` section (i.e. `extension`) of the certificate:

![](/img/net/ssl-ca-san.png)

## 证书扩展名(证书格式)
> `openssl` 可以用来生成ssl 密钥(.key), 证书请求(.csr), 签名证书(.crt).

X.509 格式

    X.509 是一个最基本的公钥格式标准(PKCS,  Public-Key Cryptography Standards)，里面规定了证书需要包含的各种信息

扩展名：

    私钥(Private Key): *.key 
        —–BEGIN RSA PRIVATE KEY—–
        通常是rsa算法，分带口令和不带口令的版本

    证书签名请求(Certificate signing request): *.csr
        包含公钥和其他信息. 用于申请.crt 

    证书(Certificate): *.cer *.crt 都是X509证书格式（包含的是公钥）
        可用openssl 查看到网站的cert `——BEGIN CERTIFICATE——`

        # 二者可以互转: 
        .cer 是二进制 
        .crt 是ascii 

        # 二者没有固定的编码格式，都可以用选用下面的方法编码
        二进制编码的 .pem(linux常用)
        base64编码的 .der(windows) 


编码:

    der: 二进制编码
    pem: base64编码

# 证书操作

## 查看证书
### 查看网站crt 
crt 一般是pem编码（base64）

    openssl s_client -connect baidu.com:443 < /dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > baidu.crt

或者: https://curl.se/docs/sslcerts.html 指定 servername（SNI, Server Name Indication）指定SNI证书（同一ip:prot 上提供多个 SSL 证书时需要）

    openssl s_client -showcerts -servername local.io -connect local.io:443 

msg: 用于显示所有 SSL/TLS 协议消息体。这些消息包括握手过程中的所有来回消息，如 ClientHello、ServerHello、Certificate、ServerKeyExchange 等。

    openssl s_client -showcerts -servername local.io -connect local.io:443 -msg

或者在chrome 的地址栏点证书安全图标，切换到Detail，再点export

### 解析证书请求文件csr

    openssl req -in server.csr -text -noout

### 解析pem/crt

    openssl x509 -in baidu.crt -text -noout

### Show Ceritificate Info
Show all information about a certificate:

	openssl x509 -noout -text < x.crt
	openssl x509 -noout -text -in x.crt

Calculate the MD5 fingerprint of a certificate:

	openssl x509 -noout -fingerprint < x.crt

Calculate the SHA1 fingerprint of a certificate:

	openssl x509 -sha1 -noout -fingerprint < x.crt

### 查看SAN(Subject Alternative Name)
SAN取代了CN(Common Name)

    # csr(请求文件)
    openssl req -text -in server.csr | grep "X509v3 Subject Alternative Name"
    # crt
    openssl x509 -noout -text -in server.crt | grep "X509v3 Subject Alternative Name"

## 格式转换
.pem(.crt), .der

    # .pem -> .der
    openssl x509 -outform der -in baidu.pem -out baidu.der
    # .der -> .pem 
    openssl x509 -inform der -in baidu.der -out baidu.crt
# debug cert
调试证书

## curl with cert
    curl -v --cacert /etc/ssl/cert.pem  https://baidu.com
    curl -v https://baidu.com
## ssl 延迟

    $ curl -w "TCP handshake: %{time_connect}, SSL handshake: %{time_appconnect}\n" -so /dev/null https://www.alipay.com

    TCP handshake: 0.022, SSL handshake: 0.064

## Openssl Certificate chain
https://curl.se/docs/sslcerts.html SSL Certificate Verification

    $ openssl s_client -showcerts -servername local.io -connect local.io:443
	$ openssl s_client -connect www.godaddy.com:443
	...
	Certificate chain
	 0 s:/C=US/ST=Arizona/L=Scottsdale/1.3.6.1.4.1.311.60.2.1.3=US
		 /1.3.6.1.4.1.311.60.2.1.2=AZ/O=GoDaddy.com, Inc
		 /OU=MIS Department/CN=www.GoDaddy.com
		 /serialNumber=0796928-7/2.5.4.15=V1.0, Clause 5.(b)
	   i:/C=US/ST=Arizona/L=Scottsdale/O=GoDaddy.com, Inc.
		 /OU=http://certificates.godaddy.com/repository
		 /CN=Go Daddy Secure Certification Authority
		 /serialNumber=07969287
	 1 s:/C=US/ST=Arizona/L=Scottsdale/O=GoDaddy.com, Inc.
		 /OU=http://certificates.godaddy.com/repository
		 /CN=Go Daddy Secure Certification Authority
		 /serialNumber=07969287
	   i:/C=US/O=The Go Daddy Group, Inc.
		 /OU=Go Daddy Class 2 Certification Authority
	 2 s:/C=US/O=The Go Daddy Group, Inc.
		 /OU=Go Daddy Class 2 Certification Authority
	   i:/L=ValiCert Validation Network/O=ValiCert, Inc.
		 /OU=ValiCert Class 2 Policy Validation Authority
		 /CN=http://www.valicert.com//emailAddress=info@valicert.com
