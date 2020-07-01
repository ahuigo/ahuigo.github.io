---
title: Jwt 权限
date: 2020-03-10
private: true
---
# Jwt 权限
jwt token 一般是由以下三个部分经 Base64Url 组成的：

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

## Payload
https://jwt.io/introduction/
payload 包含claims 数据，有三种claims

1. [**Registered claims**][iana jwt]:
These are a set of predefined claims which are not mandatory but recommended, to provide a set of useful, interoperable claims. Some of them are: **iss (issuer), exp (expiration time), sub (subject), aud (audience), and others**.

> Notice that the claim names are only three characters long as JWT is meant to be compact.

2. **Public claims**:
These can be defined at will by those using JWTs. But to avoid collisions they should be defined in the [**IANA JSON Web Token Registry**][iana jwt] or be defined as a URI that contains a collision resistant namespace.

3. **Private claims**: 
These are the custom claims created to share information between parties that agree on using them and are neither registered or public claims.


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

## sso
jwt 常用于单点登录，
1. get jwt: When users logs in using their **credentials(user+password)**, a JSON Web Token will be returned. 方式有很多：
    1. 比如用OpenID Connect 的`/token or /authorize endpoint` 用授权code换jwt. [authorization code flow](https://openid.net/specs/openid-connect-core-1_0.html#CodeFlowAuth)
        1. 请求参数：grant_type=authorization_code&code={code}
        2. 返回access token（jwt）

2. Browser access API with jwt: `Authorization: <token>`, 

## Ref
[iana jwt]: https://www.iana.org/assignments/jwt/jwt.xhtml