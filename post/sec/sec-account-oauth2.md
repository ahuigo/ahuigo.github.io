---
title: Oauth2 授权
private: true
---
# Oauth2 授权
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

其中名词：
1. user: Resource Owner
1. User Agent: Brower
2. Client: 3rd app
2. HTTP Serive: google/weibo/weixin/qq
2. Resource server: google/weibo/weixin/qq
2. Authorization server: google/weibo/weixin/qq

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

> 为什么第二步中，不直接返回accessToken 而用授权码(authorization code)换取access token呢？
因为授权code只代表确认用户授权，此时clientId代表的app还不确定是不是合法呢？
因为clientId那玩意公开的，用户都知道，所以如果我知道了clientId，我可以说我是你。
所以不安全，要做第二次验证。 第二次验证的就是在客户端后台完成的了，它得把clientId连同client Credentail（client secrect或者说密码）再加上获得的AuthorizationCode发给服务器做验证。
这才能获取最终使用的accessToken。

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