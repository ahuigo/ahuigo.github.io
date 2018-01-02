---
layout: page
title:
category: blog
description:
---
# Preface

# openssl

## DSA
4.1.1、DSA
1、私钥：

	openssl dsaparam -out dsaparam.pem 1024
	openssl gendsa -out private.pem dsaparam.pem
	openssl pkcs8 -topk8 -nocrypt -in private.pem -outform PEM -out java_private.key

2、公钥

	openssl dsa -in private.pem -out public.pem -pubout

## RSA
4.1.2、RSA
1、私钥

	openssl genrsa -out my_rsa_private_key.pem 1024

2、公钥

	openssl rsa -in my_rsa_private_key.pem -pubout -out my_rsa_public_key.pem

## self RSA
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
