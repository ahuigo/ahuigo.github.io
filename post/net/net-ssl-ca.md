---
layout: page
title:	SSL Certificate Authority(CA)
category: blog
description: 
---
# 证书级别
http://www.ruanyifeng.com/blog/2016/08/migrate-from-http-to-https.html

# SNI(SSL/TLS Server Name Indication)
同一IP地址和端口下不同域名HTTPS请求的需要服务端和客户端均支持SNI（Server Name Indication）https://en.wikipedia.org/wiki/Server_Name_Indication 协议，在HTTPS请求握手开始阶段指定要请求的域名，以便服务端选择使用相应的证书。

1. 服务端Nginx配置支持是TSL1.0及以上版本，均支持SNI协议，
2. 但若客户端不支持SNI协议，即没有指定要请求的域名，Nginx会优先查找default server中的证书配置，
3. 若没有找到则会按照配置文件字母序查找对应IP端口上第一个配置有证书的域名的证书做为默认证书使用。

## support

	java >= 1.7
	android web >= 4.*


### SNI in Android SDK
The current situation is the following:

1. Since the Gingerbread release TLS connection with the HttpsURLConnection API supports SNI.
2. Apache HTTP client library shipped with Android does not support SNI
3. The Android web browser does not support SNI neither (since using the Apache HTTP client API)
4. There is an opened ticket regarding this issue in the Android bug tracker.

It is also possible to test the SNI support by making a connection to this URL: https://sni.velox.ch/

## Debug SNI
SNI should work completely transparently when running on Java 1.7 or newer. No configuration is required. If for whatever reason SSL handshake with SNI enabled server fails you should be able to find out why (and whether or not the SNI extension was properly employed) by turning on SSL debug logging as described here [1] and here [2]

'Debugging SSL/TLS Connections' may look outdated but it can still be useful when troubleshooting SSL related issues.

[1] http://docs.oracle.com/javase/1.5.0/docs/guide/security/jsse/ReadDebug.html

[2] http://docs.oracle.com/javase/7/docs/technotes/guides/security/jsse/JSSERefGuide.html#Debug

# debug

## ssl 延迟

    $ curl -w "TCP handshake: %{time_connect}, SSL handshake: %{time_appconnect}\n" -so /dev/null https://www.alipay.com

    TCP handshake: 0.022, SSL handshake: 0.064

## Certificate chain

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

# Show Ceritificate Info
Show all information about a certificate:

	openssl x509 -noout -text < crt

Calculate the MD5 fingerprint of a certificate:

	openssl x509 -noout -fingerprint < crt

Calculate the SHA1 fingerprint of a certificate:

	openssl x509 -sha1 -noout -fingerprint < crt

info of crt/pem

    openssl x509 -noout -text -in server.CA.crt


# CA vs Self-Signed
正常的生产证书：
1. 在你的服务器上，生成一个CSR文件（SSL证书请求文件，SSL Certificate Signing Request）。
2. 使用CSR文件，购买SSL证书。
3. 安装SSL证书。

ssl 证书转移:
IIS的做法是生成一个可以转移的.pfx文件，并加以密码保护。

Certificate type:

1. request one from a `certificate authority` like Let’s Encrypt, Comodo, etc. 
2. generate a `self-signed certificate` on the command line.


# Self-Signed Certificate
Refer to: https://deliciousbrains.com/https-locally-without-browser-privacy-errors/

There are 3 methods to create self-signed crt
1. generate seprately: `genrsa->.key, rsa->nopass.key, req->.csr, x509->.crt` -> .pem
2. gen with one command: `req`+`-x509` => `nopass.key, .crt`
3. with SAN: 

## 1. gen: key+pub.key+csr+crt
Refer to: http://www.lovelucy.info/nginx-ssl-certificate-https-website.html

通常使用开源的openssl 生成ssl 证书。
OpenSSL支持多种不同的加密算法, 它有LibreSSL 和 google 的BoringSSL 两个分支

- 加密：
AES, Blowfish, Camellia, SEED, CAST-128, DES, IDEA, RC2, RC4, RC5, Triple DES, GOST 28147-89[3]

- 散列函数：
	MD5, MD2, SHA-1, SHA-2, RIPEMD-160, MDC-2, GOST R 34.11-94[3]

- 公开密钥加密：
	RSA, DSA, Diffie–Hellman key exchange, Elliptic curve, GOST R 34.10-2001[3]

`openssl` 可以用来生成ssl 密钥(.key), 证书请求(.csr), 签名证书(.crt).

下例生成一个自签名证书(self sign certificate), 而非[ssl-ca](/p/ssl-ca) 中CA 签名证书(`CA -sign`)

	# 生成一个RSA密钥(私钥)
	openssl genrsa -des3 -out my.key 1024

	# 拷贝一个不需要输入密码的密钥文件(private key with no pass)
	openssl rsa -in my.key -out my_nopass.key

	# 生成一个证书请求
	openssl req -new -key my.key -out my.csr
	#会提示输入省份、城市、域名信息等 //Common Name 一定要填写实际的域名，否则浏览器会报: ERR_CERT_COMMON_NAME_INVAID

	# 自己签发证书
	openssl x509 -req -days 365 -in my.csr -signkey my.key -out my.crt

这样就有一个 `CSR(certificate signing request )` 文件了，提交给 ssl 提供商的时候就是这个 csr 文件。当然我这里并没有向证书提供商申请，而是在第4步自己签发了证书。

对于`Common Name = *.weibo.cn`, chrome 匹配`a.wiki.cn`, 但是不会认匹配`a.b.wiki.cn`, safari 则都匹配

### pem
If you like to use that certificate for an Apache web server you need to put the private key (.key) and the certificate (.crt) into the same file and call it apache.pem.

	cat my_nopass.key mydomain.crt > apache.pem

one cli line:

    $ openssl req -x509 -config openssl-ca.cnf -newkey rsa:4096 -sha256 -nodes -out cacert.pem -outform PEM

## 2. Creating a Self-Signed Certificate(one step)
Gen crt and key:

    openssl req \
    -new -sha256 -newkey rsa:2048 -nodes \
    -x509 -days 365 \
    -keyout dev.deliciousbrains.com.key \
    -out dev.deliciousbrains.com.crt

> You can also add `-nodes (short for no DES)` omits the passphrase, if you don't want to protect your `private key with a passphrase`.

the only question that really needed an answer was Common Name (CN). The answer to that question determined which domain the certificate was valid for.

    Common Name (e.g. server FQDN or YOUR name) []:dev.deliciousbrains.com

## 3.With Subject Alternative Name (SAN)
> RFC 2818 describes two methods to match a domain name against a certificate – using the available names within the subjectAlternativeName extension, or, in the absence of a SAN extension, falling back to the commonName(dprecated, i.e. android browser/IoT(Internet of Thing)). 

So now the domain name must be defined in the `Subject Alternative Name (SAN)` section (i.e. `extension`) of the certificate:

![](/img/net/ssl-ca-san.png)

Now when creating a self-signed certificate, we need to provide `<domain>.conf` to define the SAN in that configuration file. Our command becomes:

    openssl req -config dev.deliciousbrains.com.conf \
    -new -sha256 -newkey rsa:2048 -nodes \
    -x509 -days 365 \
    -keyout dev.deliciousbrains.com.key \
    -out dev.deliciousbrains.com.crt

replacing the `DNS.1 = example.com` line with `DNS.1 = dev.deliciousbrains.com`  in `dev.deliciousbrains.com.conf`
 
    [ req ]

    default_bits        = 2048
    default_keyfile     = server-key.pem
    distinguished_name  = subject
    req_extensions      = req_ext
    x509_extensions     = x509_ext
    string_mask         = utf8only

    [ subject ]

    countryName                 = Country Name (2 letter code)
    countryName_default         = US

    stateOrProvinceName         = State or Province Name (full name)
    stateOrProvinceName_default = NY

    localityName                = Locality Name (eg, city)
    localityName_default        = New York

    organizationName            = Organization Name (eg, company)
    organizationName_default    = Example, LLC

    commonName                  = Common Name (e.g. server FQDN or YOUR name)
    commonName_default          = Example Company

    emailAddress                = Email Address
    emailAddress_default        = test@example.com

    [ x509_ext ]

    subjectKeyIdentifier   = hash
    authorityKeyIdentifier = keyid,issuer

    basicConstraints       = CA:FALSE
    keyUsage               = digitalSignature, keyEncipherment
    subjectAltName         = @alternate_names
    nsComment              = "OpenSSL Generated Certificate"

    [ req_ext ]

    subjectKeyIdentifier = hash

    basicConstraints     = CA:FALSE
    keyUsage             = digitalSignature, keyEncipherment
    subjectAltName       = @alternate_names
    nsComment            = "OpenSSL Generated Certificate"

    [ alternate_names ]

    DNS.1       = dev.deliciousbrains.com
    DNS.2       = mail.deliciousbrains.com

    # DNS.5       = localhost
    # DNS.6       = localhost.localdomain
    # DNS.7       = 127.0.0.1

    # IPv6 localhost
    # DNS.8     = ::1

## nginx,apache with ssl

	server {
		listen       80;
		listen 443 default_server ssl;
		ssl_certificate /Users/hilojack/test/ssl/my.crt;
		ssl_certificate_key /Users/hilojack/test/ssl/my_nopass.key; 
            # nopass is public key
            # 若ssl_certificate_key使用my.key，则每次启动Nginx服务器都要求输入key的密码。

		#ssl_protocols       TLSv1 TLSv1.1 TLSv1.2;#defalut
		#ssl_ciphers         HIGH:!aNULL:!MD5; #default
	}

## Adding to macOS Keychain
1. Open Keychain
2. `File->Import Items(Shift+Cmd+i)` to import `my.crt`, `ca.crt` in `system` or `login`
3. Select *always trust*

# Create Own CA
The best way: https://stackoverflow.com/questions/10175812/how-to-create-a-self-signed-certificate-with-openssl/27931596#27931596

1. Create your own authority (i.e., become a CA)
    1. The Subject Key Identifier (SKI) is the same as the Authority Key Identifier (AKI)
2. Create a certificate signing request (CSR) for the server
3. Sign the server's CSR with your CA key
4. Install the server certificate on the server
5. Install the CA certificate on the client

Step: https://deliciousbrains.com/ssl-certificate-authority-for-local-https-development/

## gen Root Certificate

    # gen ca private key
    openssl genrsa -des3 -out myCA.key 2048

    # gen root certificate
    openssl req -x509 -new -nodes -key myCA.key -sha256 -days 1825 -out myCA.pem

## install to key chain
import CA
0. import CA.pem to key chain
1. trust all

Use signed crt:

	server {
		listen       80;
        listen 443 default_server ssl;
        ssl_certificate /Users/hilojack/ssl/s/localhost.crt;           
        ssl_certificate_key /Users/hilojack/ssl/s/localhost.key; #cert.key
    }

## Creating CA-Signed Certificates 
private key

    openssl genrsa -out localhost.key 2048

### CSR
Then we create a CSR(Signed Request):

    openssl req -new -key localhost.key -out localhost.csr

### CRT
Using our CSR, the CA private key, the CA certificate, and a config file to create: `localhost.crt`+`CAcreateserial: myCA.crl`

    openssl x509 -req -in localhost.csr -CA myCA.pem -CAkey myCA.key -CAcreateserial \
    -out localhost.crt -days 1825 -sha256 -extfile localhost.ext

The config file is needed to define the Subject Alternative Name (SAN) extension`localhost.ext`:

    authorityKeyIdentifier=keyid,issuer
    basicConstraints=CA:FALSE
    keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
    subjectAltName = @alt_names

    [alt_names]
    DNS.1 = localhost
    DNS.2 = localhost.192.168.1.19.xip.io


# Reference
## Creating a User Certificate for Authentication/Mail
https://www.wikihow.com/Be-Your-Own-Certificate-Authority#Creating_your_CA_Certificate_sub

For more details:

- http://datacenteroverlords.com/2012/03/01/creating-your-own-ssl-certificate-authority/

> 根证书(root.pem)本质上是自签名证书，根证书可以用于对其它子证书签名(参考上面的链接)
