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

# Authorization
对于中小企业而言，构建自己的帐户系统成本可能过大：主要是安全问题, 存储成本.
对于用户而言，访问一个新网站，就注册一个新号：用户体验不好，太多的密码用户也记不住

有没有一种办法，用户不注册帐号也让能让网站获取用户的身份呢？
浏览器useragent/ip/cookie/mac 等都能或多或少的表示用户的身份，但是这是不可靠的。可靠的办法有：

1. OpenID	用户可授权第三方网站获取它的身份标识，但第三方网站无法获得用户的资料
1. OAuth2.0 用户可授权第三方网站获取它的身份标识，同时授权第三方访问它的个人资料

# oAuth2
本文参考：
1. [理解oAuth2.0-阮一峰](http://www.ruanyifeng.com/blog/2014/05/oauth_2_0.html)
2. [oAuth2.0-rfc](http://www.rfcreader.com/#rfc6749)

## Protocol Flow
oAuth2.0 认证流程

	+--------+                               +---------------+
	|        |--(A)- Authorization Request ->|   Resource    |
	|        |                               |     Owner     |
	|        |<-(B)-- Authorization Grant ---|               |
	|        |                               +---------------+
	|        |
	|        |                               +---------------+
	|        |--(C)-- Authorization Grant -->| Authorization |
	| Client |                               |     Server    |
	|        |<-(D)----- Access Token -------|               |
	|        |                               +---------------+
	|        |
	|        |                               +---------------+
	|        |--(E)----- Access Token ------>|    Resource   |
	|        |                               |     Server    |
	|        |<-(F)--- Protected Resource ---|               |
	+--------+                               +---------------+

                     Figure 1: Abstract Protocol Flow

其中：

- Client: Third Party Application
- Resource Owner: User, User Agent
- Resource Server, Authorization Server:

token 所包含的信息有：
用户身份，Client 身份(client_id)，过期时间，scope 授权范围

## authorization grant, 授权模式
在上面的Flow 中，B 获取用户授权是关键步骤. 实际上存在4种授权模式。

### authorization mode, 授权码模式
这是功能最完整，流程最严密的模式：它是通过客户端的后台服务器与"服务提供商"的认证服务进行互动

	 +----------+
	 | Resource |
	 |   Owner  |
	 |          |
	 +----------+
		  ^
		  |
		 (B)
	 +----|-----+          Client Identifier      +---------------+
	 |         -+----(A)-- & Redirection URI ---->|               |
	 |  User-   |                                 | Authorization |
	 |  Agent  -+----(B)-- User authenticates --->|     Server    |
	 |          |                                 |               |
	 |         -+----(C)-- Authorization Code ---<|               |
	 +-|----|---+                                 +---------------+
	   |    |                                         ^      v
	  (A)  (C)                                        |      |
	   |    |                                         |      |
	   ^    v                                         |      |
	 +---------+                                      |      |
	 |         |>---(D)-- Authorization Code ---------'      |
	 |  Client |          & Redirection URI                  |
	 |         |                                             |
	 |         |<---(E)----- Access Token -------------------'
	 +---------+       (w/ Optional Refresh Token)

	Note: The lines illustrating steps (A), (B), and (C) are broken into
	two parts as they pass through the user-agent.

                     Figure 3: Authorization Code Flow

A步骤中，客户端申请认证的URI，包含以下参数：

	response_type：表示授权类型，必选项，此处的值固定为"code"
	client_id：表示客户端的ID，必选项
	redirect_uri：表示重定向URI，可选项
	scope：表示申请的权限范围，可选项
	state：表示客户端的当前状态，可以指定任意值，认证服务器会原封不动地返回这个值。

C步骤中，服务器回应客户端的URI，包含以下参数：

	code：表示授权码，必选项。该码的有效期应该很短，通常设为10分钟，客户端只能使用该码一次，否则会被授权服务器拒绝。该码与客户端ID和重定向URI，是一一对应关系。
	state：如果客户端的请求中包含这个参数，认证服务器的回应也必须一模一样包含这个参数。

D步骤中，客户端向认证服务器申请令牌的HTTP请求，包含以下参数：

	grant_type：表示使用的授权模式，必选项，此处的值固定为"authorization_code"。
	code：表示上一步获得的授权码，必选项。
	redirect_uri：表示重定向URI，必选项，且必须与A步骤中的该参数值保持一致。
	client_id：表示客户端ID，必选项。

E步骤中，认证服务器发送的HTTP回复，包含以下参数：

	access_token：表示访问令牌，必选项。
	token_type：表示令牌类型，该值大小写不敏感，必选项，可以是bearer类型或mac类型。
	expires_in：表示过期时间，单位为秒。如果省略该参数，必须其他方式设置过期时间。
	refresh_token：表示更新令牌，用来获取下一次的访问令牌，可选项。
	scope：表示权限范围，如果与客户端申请的范围一致，此项可省略。

### implicit grant type, 简化模式
与授权码模式相比，implicit grant type 跳过了Authorization code, 直接返回access token.
不过这个access token 不直接发给client, client 需要用一个js script 获取到这个token
令牌对访问者是可见的，不需要client 认证


	 +----------+
	 | Resource |
	 |  Owner   |
	 |          |
	 +----------+
		  ^
		  |
		 (B)
	 +----|-----+          Client Identifier     +---------------+
	 |         -+----(A)-- & Redirection URI --->|               |
	 |  User-   |                                | Authorization |
	 |  Agent  -|----(B)-- User authenticates -->|     Server    |
	 |          |                                |               |
	 |          |<---(C)--- Redirection URI ----<|               |
	 |          |          with Access Token     +---------------+
	 |          |            in Fragment
	 |          |                                +---------------+
	 |          |----(D)--- Redirection URI ---->|   Web-Hosted  |
	 |          |          without Fragment      |     Client    |
	 |          |                                |    Resource   |
	 |     (F)  |<---(E)------- Script ---------<|               |
	 |          |                                +---------------+
	 +-|--------+
	   |    |
	  (A)  (G) Access Token
	   |    |
	   ^    v
	 +---------+
	 |         |
	 |  Client |
	 |         |
	 +---------+

	Note: The lines illustrating steps (A) and (B) are broken into two
	parts as they pass through the user-agent.

                       Figure 4: Implicit Grant Flow

### Resource Owner Password Credentials Grant, 密码模式
在Password Credential 中，用户需要将自己的帐户与密码交给client, client 用这个凭据向认证服务器索要access token.

Client 不得存储这些密码，通常用于用户对客户端高度信任的情况下，比如客户端是操作系统的一部分或者著名的公司. 认证服务器也需要考虑这个信任问题

	 +----------+
	 | Resource |
	 |  Owner   |
	 |          |
	 +----------+
		  v
		  |    Resource Owner
		 (A) Password Credentials
		  |
		  v
	 +---------+                                  +---------------+
	 |         |>--(B)---- Resource Owner ------->|               |
	 |         |         Password Credentials     | Authorization |
	 | Client  |                                  |     Server    |
	 |         |<--(C)---- Access Token ---------<|               |
	 |         |    (w/ Optional Refresh Token)   |               |
	 +---------+                                  +---------------+

			Figure 5: Resource Owner Password Credentials Flow

B步骤中，客户端发出的HTTP请求，包含以下参数：

	grant_type：表示授权类型，此处的值固定为"password"，必选项。
	username：表示用户名，必选项。
	password：表示用户的密码，必选项。
	scope：表示权限范围，可选项。

### Client Credentials Grant, 客户端模式
客户端模式是以用户自己的名义向认证服务器获取token, 而不是以用户的名义。所以这种模式就没有授权的问题

	+---------+                                  +---------------+
	|         |                                  |               |
	|         |>--(A)- Client Authentication --->| Authorization |
	| Client  |                                  |     Server    |
	|         |<--(B)---- Access Token ---------<|               |
	|         |                                  |               |
	+---------+                                  +---------------+

				 Figure 6: Client Credentials Flow

## Rfresh Token, 更新令牌
client 可以直接请求认证服务索取新token(认证服务器需要提供更新机制)

	grant_type
		 REQUIRED.  Value MUST be set to "refresh_token".
	refresh_token
		 REQUIRED.  The refresh token issued to the client.
	scope
		 OPTIONAL.

Example:

	POST /token HTTP/1.1
	Host: server.example.com
	Authorization: Basic czZCaGRSa3F0MzpnWDFmQmF0M2JW
	Content-Type: application/x-www-form-urlencoded

	grant_type=refresh_token&refresh_token=tGzv3JOkF0XG5Qx2TlKWIA

# SSO
There are many Single Sign-On Service(SSO) implement Protocols.

1. OpenID: 是IDP提供一个身份唯一标识把第三方的应用帐号绑定到唯一标识上，只起到了认证的作用。
2. CAS(Central Authentication Service): 本身没有权限控制，但是CAS支持SAML(SAML支持XACML协议进行权限控制)，所以就支持了权限控制。
	SAML协议较OAUTH来说比较复杂，但是功能也十分强大，支持认证，权限控制和用户属性。
	https://github.com/Jasig/phpCAS
4. LADP

CAS vs OAuth :

- CAS: Both CAS and SAML act as an gateway in front of a group of applications which belong to one organization.
- OAuth: is used to authorize and authenticate between different organizations.

## LDAP 认证
http://www.ossxp.com/doc/redmine/admin_guide/admin_guide.html#id32
