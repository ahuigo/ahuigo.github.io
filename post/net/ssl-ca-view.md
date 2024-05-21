---
title: ssl debug
date: 2023-03-22
private: true
---
# 证书操作
## 证书扩展名(证书格式)
X.509 格式

    X.509 是一个最基本的公钥格式标准(PKCS,  Public-Key Cryptography Standards)，里面规定了证书需要包含的各种信息

扩展名：

    证书(Certificate): *.cer *.crt 都是X509证书格式（包含的是公钥）
        可用openssl 查看到网站的cert
        ——BEGIN CERTIFICATE——

        # 二者可以互转: 
        .cer 是二进制 
        .crt 是ascii 

        # 二者没有固定的编码格式，都可以用选用下面的方法编码
        二进制编码的 .pem(linux常用)
        base64编码的 .der(windows) 

    私钥(Private Key): *.key 
        —–BEGIN RSA PRIVATE KEY—–
        通常是rsa算法，分带口令和不带口令的版本

    证书签名请求(Certificate signing request): *.csr
        包含公钥和其他信息. 用于申请.crt 

编码:

    der: 二进制编码
    pem: base64编码

## 查看证书
### 查看网站crt 
crt 一般是pem编码（base64）

    openssl s_client -connect baidu.com:443 < /dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > baidu.crt

或者: https://curl.se/docs/sslcerts.html

    openssl s_client -showcerts -servername local.io -connect local.io:443 

### 解析pem/crt

    openssl x509 -in baidu.crt -text -noout

### Show Ceritificate Info
Show all information about a certificate:

	openssl x509 -noout -text < crt

Calculate the MD5 fingerprint of a certificate:

	openssl x509 -noout -fingerprint < crt

Calculate the SHA1 fingerprint of a certificate:

	openssl x509 -sha1 -noout -fingerprint < crt

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

## Certificate chain
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
