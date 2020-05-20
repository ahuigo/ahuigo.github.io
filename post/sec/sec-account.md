---
title:	安全的帐号设计
priority:
---
# Preface
帐号设计可以涉及到很多细节，本文主要从安全的角度作一个总结:

1. password 安全
1. sid 的设计
3. 内部Api 授权
4. SSO 单点登录

# password 安全
密码安全问题请参考[密码安全](/p/security-cryptography)
通常的网站的密码是用md5/sha256 等方式hash过的

# sid
这里的sid 是指用于标识用户身份的sid(session id)

1. sid 生成(Forge, 伪造)
2. sid 算法保密
1. sid 更新
2. 防止CSRF, HTTP Only

## create sid(Forge sid, 伪造sid)
防止伪造sid 方法就是签名(这里指的是广义的签名，而非专指证书签名)，签名的方法有很多，但是签名要注意问题是：

1. 签名必须足够的长, 这样才能防止碰撞(签名足够长才能保证碰撞出无效的值的概率最大)、防止暴力攻击
1. 签名密钥要保密(可是对称加密、非对称加密、不可拟加密md5 sha1)

## sid 算法保密
sid 算法保密主要有以下方法

1. 密钥保密：让更少的人知道sid 的生成算法的密钥(帐号系统管理者):
sid 的生成算法对于做业务的开发者必须保密, 一般通过帐号接口生成；只要帐号接口的实现者能保密sid 的生成算法，sid 就是安全的。
相应的，解sid 时需要提供相应的解密接口。如果采用非对称加密算法，解密时也不需要接口，直接用公钥解密就行
2. 算法保密 vs 暴力破解
   1. 如果算法不能保密，就得小心暴力破解。为了应对暴力破解：需要设置足够长的秘钥+IP登录限制。

3. sid 的生成要带有随机数, 作用有以下方面：
用于更新sid
避免帐号管理者伪造sid: sid 必须存放在到mc/redis中才生效。只有当管理员登录服务器，才能产生带随机数的sid 并种入mc/redis 才产生新的sid。管理员在服务器外产生的随机数sid 是不生效的(服务器缓存中没有此sid)

## sid 存储

### sid 包含的数据
sid 可以包括的数据有: uid , sid version 等
存储这些信息一般需要经过base64、移位、随机数(用于更新sid, 避免帐号管理者伪造sid)、签名等处理

### sid 的存储
如果用户更改了密码，或者用户的sid 被窃取了，sid 就必须及时更新. 所以sid 的生成必须的失效性. 可以将这个sid 存放到一个集合中. 这个集成可以允许添加、更新(删除).

1. 建议不要选择bloom filter 存储sid. bloom filter 有几个问题：
	用户更新sid 时就意味着要删除老的sid, 删除老的sid 可能会删除不相关的sid(这和错误率有关); 还需要防止sid 应该过期而没有过期的情况(没有成功清理sid)
	有的sid 是无效的，却在bloom filter是有效的。因为 bloom filter 可以做到很低的错误率，并且sid 有签名检验。这种情况发生的概率非常低

2. 通常使用hash 表（`uid->sid`）存储更新sid

# Api Token
在大型项目中，一般都分业务开发和接口服务方。对于业务开发者而言，他需要调用各种内部接口(api). 有时候，业务服务器访问内部api 时，就需要出示用户身份(uid)。 在内网中这种访问通常是明文传输的, uid 作为用户的身份标识就需要保密、防伪造。通常我们会将uid 签名为token, 方法如下：

1. 用 md5/sha1签名，签名key 需要由开发者保密. 这个方法无法避免内网中间人侦听，也无法避免开发者在服务端使坏。
2. 如要避免业务开发者使坏，可以在开发机上提供开发者自己的uid token 白名单, 也就是限制开发机上的用户。只有线上的机器才能访问token 的生成密钥或者生成接口
2. 如要避免内网中间人，将其它所有的请求参数加密

## what token
I think it's well explained here -- quoting just the key sentences of the long article:

> The general concept behind a token-based authentication system is simple. Allow users to enter their username and password in order to obtain a token which allows them to fetch a specific resource - without using their username and password. Once their token has been obtained, the user can offer the token - which offers access to a specific resource for a time period - to the remote site.

In other words: add one level of indirection for authentication -- instead of having to authenticate with username and password for each protected resource,
obtains a time-limited token in return, and uses that token for further authentication during the session.

Advantages are many -- e.g., the user could pass the token, once they've obtained it, on to some other automated system which they're willing to trust for a limited time and a limited set of resources, but would not be willing to trust with their username and password (i.e., with every resource they're allowed to access, forevermore or at least until they change their password).

## 设计api token
简单的token(不安全，泄露就不可挽回了)

    token = hash(uid)

需要加把钥匙：

    token = hash(uid+key)
    hash_hmac("sha1", $str, $key)
    crc32($str.$key)
    
团队开发一般有业务组和核心组，为了防止组间`$key`泄露，还可以通过非对称的方式向核心平台组获取这个`$key`, 每个业务组分配不同的`$key`, 对应不用的gsid

## access token 有效期设计
oAuth2 rfc 或许有讨论。
初步想法两种：
1. 用redis/mc 实现access token 过期
1. token 自带时间戳+二次st(token) 验证(st key 泄露风险比较大)

## uid+st
以前微博wap曾采用这种方式防止csrf：uid 是从cookie中取的真实的，st=hash(uid)是需要保密的(位于url中), 通过校验st防止CSRF

## gsid 
weibo 身份认证，主要存储于cookie. 他不同于token, 它不仅用验证用户身份，还可解析用户数据

# AD and ldap and openID
2. AD supports LDAP(Lightweight Directory Access Protocol)
    1. Ldap uses the TCP/IP stack and a string encoding scheme of the X.500 Directory Access Protocol (DAP), giving it more relevance on the Internet.
1. Active Directory is a directory services implemented by Microsoft, 
    1. based on this LDAP/X.500 stack, Microsoft implemented a modern directory service for Windows, originating from the X.500 directory, created for use in Exchange Server. And this implementation is called Active Directory.

Active Directory (AD) supports both [`Kerberos and LDAP`](https://www.varonis.com/blog/the-difference-between-active-directory-and-ldap/)
:

1. AD provides Single-SignOn (SSO) and works well in the office and over VPN. 
2. AD and Kerberos are not cross platform, which is one of the reasons companies are implementing access management software to manage logins from many different devices and platforms in a single place. 
3. AD does support LDAP, which means it can still be part of your overall access management scheme.

## openid 协议
CAS as a protocol is a mechanism to `provide web single signon`. There is also CAS, the software platform that implements that protocol amongst many others, including openid.

OpenId is also an authentication protocol, similar to CAS, able to achieve `web single sign` on but more in a `federated fashion`.

LDAP is a protocol that defines `how one should talk to a directory server`. Most systems use LDAP to talk to a directory to `retrieve user accounts`, `verify them and retrieve attributes associated with them`. It has nothing to do with authentication or single sign on. CAS, the software, can be configured to find user accounts from ldap, find attributes from ldap or do other things with ldap.

# ldap
公司DC：domain component一般为公司名，例如：dc=163,dc=com
部门OU：organization unit为组织单元，最多可以有四级，每级最长32个字符，可以为中文
用户组CN：common name为用户名或者服务器名，最长可以到80个字符，可以为中文
唯一性的记录项DN：distinguished name为一条LDAP记录项的名字，有唯一性，例如：dc:”cn=admin,ou=developer,dc=163,dc=com”