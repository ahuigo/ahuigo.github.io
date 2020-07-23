---
layout: page
title: security-web
category: blog
description: 
date: 2018-10-04
---
# Preface


# click-jacking vulnerability

## opacity

	<a href="http://example.com/attack.html" style="display: block; z-index: 100000; opacity: 0.1; position: fixed; top: 0px; left: 0; width: 1000000px; height: 100000px; background-color: red;"> </a>

# CSP 白名单(XSS)
W3C 的 Content Security Policy，简称 CSP，主要是用来定义页面可以加载哪些资源，减少 XSS 的发生

    只允许本站资源
    Content-Security-Policy: default-src 'self'
    只允许本站资源以及trusted.com
    Content-Security-Policy: default-src 'self' *.trusted.com
    Content-Security-Policy： default-src ‘self’； img-src *；
    script-src http://trustedscripts.example.com

# SSRF 的防范
通过 Server-Side Request Forgery(SSRF), 攻击者可以操作内部网络的资源. 比如sina url

# iframe
X-Frame-Options 这个安全头来防止 iframe 钓鱼。默认值为 SAMEORIGIN，只允许同域把本页面当作 iframe 嵌入。

# CSRF
Cross-site request forgery跨站请求伪造，也被称为“one click attack”或者session riding，

Solutions:

- check referer
- one time token(一次性令牌)

## token
1. 通过cookie
2. 通过url query/body
3. Header: xhr.setRequestHeader('x-csrf-token', Cookies.get('csrfToken'));

egg-view-nunjucks 等 View 插件会自动对 Form 进行注入

    <form method="POST" action="/upload?_csrf={{ ctx.csrf | safe }}" enctype="multipart/form-data">
    // config/config.default.js
    module.exports = {
        security: {
            csrf: {
                queryName: '_csrf', // 通过 query 传递 CSRF token 的默认字段为 _csrf
                bodyName: '_csrf', // 通过 body 传递 CSRF token 的默认字段为 _csrf
            },
        },
    };

## Referer

### 为空
利用ftp://,http://,https://,file://,javascript:,data:这个时候浏览器地址栏是file://开头的，如果这个HTML页面向任何http站点提交请求的话，这些请求的Referer都是空的。

    <iframe src="data:text/html;base64,PGZvcm0gbWV0aG9kPXBvc3QgYWN0aW9uPWh0dHA6Ly9hLmIuY29tL2Q+PGlucHV0IHR5cGU9dGV4dCBuYW1lPSdpZCcgdmFsdWU9JzEyMycvPjwvZm9ybT48c2NyaXB0PmRvY3VtZW50LmZvcm1zWzBdLnN1Ym1pdCgpOzwvc2NyaXB0Pg==">

利用https协议（https向http跳转的时候Referer为空）

    <iframe src="https://xxxxx.xxxxx/attack.php">

利用:
    x.126.com.xxx.com

## SameSite 与csrf
sameSite同站指: 
1. 我们在www.bank.com, bank.com 等页面 访问其它子域名如image.bank.com 被视为samesite. 
2. 如果是第三方网站hack.com 访问image.bank.com 就是非同站。

如果不限制cookie samesite 就存在风险
1. hack.com 诱导用户提交post 表单发password.bank.com
1. hack.com 内嵌image.bank.com 图片，用户bank追踪用户。

Sameite 可以限制三方请求带cookie

    Set-Cookie: sess=abc123; path=/; Domain=bank.com; SameSite

SameSite 分三种:
1. SameSite=Strict  在第三方站放一个github.com 的链接，点击跳github.com 永远是是未登录
2. SameSite=Lax,(chrome 新版默认值)  GET请求都会带cookie, 其它都不带cookie
3. SameSite=None,  全允许带cookie. 这种模式必须同时设置Secure属性（Cookie 只能通过 HTTPS 协议发送）


# app

## 本地存储密钥

比如某app 将手势密码存放到本地，并以md5 加密。我们可以通过彩虹表破解这个key

## Active 保护
根据android 的官方说明，如果acitity，默认没有声明export，其在声明了filter，该acitity将默认发布出去。

	Intent qq = new Intent();
	ComponentName com = new ComponentName("com.tencent.mobileqq", "com.tencent.mobileqq.activity.ForwardRecentActivity");
	qq.setComponent(com);
	startActivity(qq);

如果该activity只是qq内部使用，建议将sign级别的签名或者干脆就不要暴露出去，即添加android:exported="false"

- app内使用的私有Activity不应配置intent-filter，如果配置了intent-filter需设置exported属性为false。
- 签名验证内部（in-house）app
- 当Activity返回数据时候需注意目标Activity是否有泄露信息的风险
- 验证目标Activity是否恶意app，以免受到intent欺骗，可用hash签名验证

## 跨域和明文存储
遵守同源策略

# Session
- 定期生成session
- 检测ip
- 二次令牌: 验证码，短信，动态口令

# File System

## File Inclusion, 文件包含
不要以用户输入做文件名

	$file = $_GET['file'];

限制文件打开范围

	;open_basedir = /dir #限制php的访问路径

## Dir Loop
避免目录遍历, nginx 一般都打到index.php

## File Upload, 文件上传

# References
http://wiki.open.qq.com/wiki/Web%E6%BC%8F%E6%B4%9E%E6%A3%80%E6%B5%8B%E5%8F%8A%E4%BF%AE%E5%A4%8D#1.2_XSS.E6.BC.8F.E6.B4.9E
