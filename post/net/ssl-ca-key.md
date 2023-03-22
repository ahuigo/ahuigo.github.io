---
title: 证书的key
date: 2023-03-23
private: true
---
# Key 类型
## des3
生成des3 key(对称), 至少4位密码

    openssl genrsa -des3 -out server.key 2048

将des3转成rsa：

    openssl rsa -in server.key -out server.key

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
1、私钥(一般用.key)

    openssl genrsa -out ./testdata/server.key 2048
	openssl genrsa -out my_rsa_private_key.pem 1024


2、证书、公钥

    openssl req -new -x509 -key ./testdata/server.key -out ./testdata/server.pem -days 365
	openssl rsa -in my_rsa_private_key.pem -pubout -out my_rsa_public_key.pem