---
layout: page
title:	SSL Certificate Authority(CA)
category: blog
description: 
---
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

有了这些证书后，就可以

    server {
        server_name YOUR_DOMAINNAME_HERE;
        listen 443 ssl;
        ssl_certificate /usr/local/nginx/conf/33iq.crt;
        ssl_certificate_key /usr/local/nginx/conf/33iq_nopass.key;
        # 若ssl_certificate_key使用33iq.key，则每次启动Nginx服务器都要求输入key的密码。
    }

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
RFC 2818 describes two methods to match a domain name against a certificate
1. using the available names within the subjectAlternativeName extension
2. or, in the absence of a SAN extension, falling back to the commonName。　This is dprecated, i.e. 
    1. android browser/IoT(Internet of Thing).  
    2. go>=1.15也不支持commonName(certificate relies on legacy Common Name field, use SANs instead)
    3. 参考：https://jfrog.com/knowledge-base/general-what-should-i-do-if-i-get-an-x509-certificate-relies-on-legacy-common-name-field-error/

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

### Adding the Root Certificate to macOS Keychain
#### Via the CLI
    sudo security add-trusted-cert -d -r trustRoot -k "/Library/Keychains/System.keychain" myCA.pem
#### Via the UI
Open the macOS Keychain app

1. Go to File > Import Items…
1. Select your private key file (i.e. myCA.pem)
1. Search for whatever you answered as the Common Name name above
2. Double click on your root certificate in the list
3. Expand the Trust section
4. Change the When using this certificate: select box to “Always Trust”
![](/img/net/net-ssl-ca/trust-keychain.png)

### Adding the Root Certificate to iOS
following these steps:

1. Email the root certificate to yourself so you can access it on your iOS device
1. Click on the attachment in the email on your iOS device
1. Go to the settings app and click ‘Profile Downloaded’ near the top
1. Click install in the top right
1. Once installed, hit close and go back to the main Settings page
1. Go to “General” > “About”
1. Scroll to the bottom and click on “Certificate Trust Settings”
1. Enable your root certificate under “ENABLE FULL TRUST FOR ROOT CERTIFICATES”
![](/img/net/net-ssl-ca/import-ca-ios.png)

## Creating CA-Signed Certificates for Your Dev Sites
> Now that we’re a CA on all our devices, we can sign certificates for any new dev sites that need HTTPS. 

First, we create a private key:

    openssl genrsa -out dev.deliciousbrains.com.key 2048

Then we create a CSR:

    openssl req -new -key dev.deliciousbrains.com.key -out dev.deliciousbrains.com.csr

Create a config file((`dev.deliciousbrains.com.ext`) It define the `Subject Alternative Name (SAN)` extension 

    authorityKeyIdentifier=keyid,issuer
    basicConstraints=CA:FALSE
    keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
    subjectAltName = @alt_names

    [alt_names]
    DNS.1 = dev.deliciousbrains.com
    DNS.2 = dev2.deliciousbrains.com

 run the command to create the certificate( signing with the root certificate and private key.)

    openssl x509 -req -in dev.deliciousbrains.com.csr -CA myCA.pem -CAkey myCA.key -CAcreateserial -out dev.deliciousbrains.com.crt -days 825 -sha256 -extfile dev.deliciousbrains.com.ext

## nginx conf
Use signed crt:

	server {
		listen       80;
        listen 443 default_server ssl;
        ssl_certificate /Users/hilojack/ssl/s/localhost.crt;           
        ssl_certificate_key /Users/hilojack/ssl/s/localhost.key; #cert.key
    }

# Reference
## Creating a User Certificate for Authentication/Mail
https://www.wikihow.com/Be-Your-Own-Certificate-Authority#Creating_your_CA_Certificate_sub

For more details:

- http://datacenteroverlords.com/2012/03/01/creating-your-own-ssl-certificate-authority/

> 根证书(root.pem)本质上是自签名证书，根证书可以用于对其它子证书签名(参考上面的链接)

## CA Bundle Path(system)

| Distro                                                       	| Package         	| Path to CA                               	|
|--------------------------------------------------------------	|-----------------	|------------------------------------------	|
| Fedora, RHEL, CentOS                                         	| ca-certificates 	| /etc/pki/tls/certs/ca-bundle.crt         	|
| Debian, Ubuntu, Gentoo, Arch Linux                           	| ca-certificates 	| /etc/ssl/certs/ca-certificates.crt       	|
| SUSE, openSUSE                                               	| ca-certificates 	| /etc/ssl/ca-bundle.pem                   	|
| FreeBSD                                                      	| ca_root_nss     	| /usr/local/share/certs/ca-root-nss.crt   	|
| Cygwin                                                       	| -               	| /usr/ssl/certs/ca-bundle.crt             	|
| macOS (MacPorts)                                             	| curl-ca-bundle  	| /opt/local/share/curl/curl-ca-bundle.crt 	|
| Default cURL CA bunde path (without --with-ca-bundle option) 	|                 	| /usr/local/share/curl/curl-ca-bundle.crt 	|
| Really old RedHat?                                           	|                 	| /usr/share/ssl/certs/ca-bundle.crt       	|

