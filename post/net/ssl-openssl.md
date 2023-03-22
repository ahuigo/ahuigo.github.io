---
layout: page
title: net-ssl-tool
category: blog
description: 
date: 2018-09-28
---
# mkcert
mkcert 是一个签发本地证书的工具，用于开发环境，最大特色是可以签发 localhost 的证书 (阮一峰博客看到的)
https://blog.filippo.io/mkcert-valid-https-certificates-for-localhost/

    brew install mkcert
    brew install nss # if you use Firefox

# openssl


## self cert(RSA)
下例生成一个自签名证书(self sign certificate), 而非[ssl-ca](/p/ssl-ca) 中CA 签名证书(`CA -sign`)

	# 生成一个RSA密钥
	openssl genrsa -des3 -out my.key 1024

	# 拷贝一个不需要输入密码的密钥文件(public)
	openssl rsa -in my.key -out my_nopass.key

	# 生成一个证书请求
	openssl req -new -key my.key -out my.csr
	#会提示输入省份、城市、域名信息等 //common name 一定要填写实际的域名，否则浏览器会报: ERR_CERT_COMMON_NAME_INVAID

	# 自己签发证书
	openssl x509 -req -days 365 -in my.csr -signkey my.key -out my.crt

这样就有一个 csr 文件了，提交给 ssl 提供商的时候就是这个 csr 文件。当然我这里并没有向证书提供商申请，而是在第4步自己签发了证书。