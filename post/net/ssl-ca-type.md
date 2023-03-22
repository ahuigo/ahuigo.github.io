---
title: ssl 证书类型
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


## SNI(SSL/TLS Server Name Indication)
同一IP地址和端口下不同域名HTTPS请求的需要服务端和客户端均支持SNI（Server Name Indication）https://en.wikipedia.org/wiki/Server_Name_Indication 协议，在HTTPS请求握手开始阶段指定要请求的域名，以便服务端选择使用相应的证书。

1. 服务端Nginx配置支持是TSL1.0及以上版本，均支持SNI协议，
2. 但若客户端不支持SNI协议，即没有指定要请求的域名，Nginx会优先查找default server中的证书配置，
3. 若没有找到则会按照配置文件字母序查找对应IP端口上第一个配置有证书的域名的证书做为默认证书使用。

### SNI in Android SDK(>=4.x)
The current situation is the following:

1. Since the Gingerbread release TLS connection with the HttpsURLConnection API supports SNI.
2. Apache HTTP client library shipped with Android does not support SNI
3. The Android web browser does not support SNI neither (since using the Apache HTTP client API)
4. There is an opened ticket regarding this issue in the Android bug tracker.

It is also possible to test the SNI support by making a connection to this URL: https://sni.velox.ch/
