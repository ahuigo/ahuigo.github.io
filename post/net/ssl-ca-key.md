---
title: 证书的key
date: 2023-03-23
private: true
---
# 支持算法
https://zhuanlan.zhihu.com/p/365954921
## 常用算法
    密钥协商算法：
        ECDHE：优先选择ECDHE作为密钥协商算法，椭圆曲线选择x25519, 其次P-256
        DHE: 长度选择2048bit

    身份验证算法
        ECDSA：优先选择ECDSA，椭圆曲线选择x25519, 其次P-256
        RSA：长度选择2048bit
    加密算法和分组模式
        AES_128_GCM： 长度是128bit
        CHACHA20_POLY1305
        AES_256_GCM: 长度是256bit

## DHE算法(一种Diffie-Hellman Key Pair)
ECDHE（DHE）算法属于DH类密钥交换算法， 私钥不参与密钥的协商，故即使私钥泄漏，客户端和服务器之间加密的报文都无法被解密，这叫 前向安全（forward secrity）

    # 若使用DHE密钥协商算法需要配置DHE Param, 不配会报错，DHE-Param要求2048bit
    # 可通过openssl dhparam -out tmp/ssl/dhparam.pem 2048 生成dhparam.pem
    ssl_dhparam tmp/ssl/dhparam.pem;

`DH_RSA` 私钥会存硬盘，`DHE_RSA`临时存内存，更安全
`ECDHE`的运算是把`DHE`中模幂运算替换成了点乘运算，速度更快，可逆更难

# Key 类型
可用file 看key文件类型

    $ file nginx.key 
    nginx.key: PEM RSA private key
    $ file nginx.csr 
    nginx.csr: PEM certificate request

## des3 rsa
生成带des3 key(对称)的RSA, 至少4位密码

    openssl genrsa -des3 -out server.key 2048

去除des3密码，转成不带密码的rsa：

    openssl rsa -in server.key -out server.key

## DSA(todo)
1、私钥：一般命名`*.key`, 很少用`*.pem`

    # Key considerations for algorithm "ECDSA" (X25519 || ≥ secp384r1)
    # https://safecurves.cr.yp.to/
    # List ECDSA the supported curves (openssl ecparam -list_curves)
    openssl ecparam -genkey -name secp384r1 -out server.key

    # Key considerations for algorithm "DSA"
	openssl dsaparam -out dsaparam.pem 1024
	openssl gendsa -out private.pem dsaparam.pem

	openssl pkcs8 -topk8 -nocrypt -in private.pem -outform PEM -out java_private.key

2、公钥

	openssl dsa -in private.pem -out public.pem -pubout

## RSA
4.1.2、RSA
1、私钥(一般用.key)

    # Key considerations for algorithm "RSA" ≥ 2048-bit
    openssl genrsa -out ./server.key 2048
	openssl genrsa -out ./server_rsa.pem 1024


2、公钥

	openssl rsa -in ./server_rsa.pem -pubout -out ./my_rsa_public_key.pem

