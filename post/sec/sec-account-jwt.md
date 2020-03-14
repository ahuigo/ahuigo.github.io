---
title: Jwt 权限
date: 2020-03-10
private: true
---
# Jwt 权限
jwt token 一般是由以下部分经base64组成的：

    //header
    {
        "alg": "HS256",
        "typ": "JWT"
    }
    //Payload 实际的数据
    {
        "sub": "1234567890",//主题
        "name": "John Doe",
        "exp": 1234567890, (expiration time)：过期时间
        "admin": true
    }
    //Signature
    HMACSHA256(
        base64UrlEncode(header) + "." +
        base64UrlEncode(payload),
        secret)

signature 中的secret 是保密的。

另外 Base64URL 算法与Base64不同：

    有三个字符+、/和=，在 URL 里面有特殊含义，所以要被替换掉：=被省略、+替换成-，/替换成_ 

## secret 的生成
secret 一般要保：
1. 允许用户修改密码时失效
2. 不同用户不能相同
3. 生成算法保密
3. 生成数据保密, 数据的组成一般为
    1. key 
    1. 盐salt(不同用户不同salt):作为seed
    2. hash(password): 不是必须的

生成方法一般是：`hash(key+salt+hash(password))`

## 可重放攻击
可以做一个签名，同时nonce需要做存储（防止别人伪造nonce）

    sign=采用时间戳 + 随机数nonce

