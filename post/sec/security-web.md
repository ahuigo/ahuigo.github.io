---
layout: page
title:
category: blog
description:
---
# Preface


# click-jacking vulnerability

## opacity

	<a href="http://example.com/attack.html" style="display: block; z-index: 100000; opacity: 0.1; position: fixed; top: 0px; left: 0; width: 1000000px; height: 100000px; background-color: red;"> </a>

# XSS

# CSRF
Cross-site request forgery跨站请求伪造，也被称为“one click attack”或者session riding，

Solutions:

- check referer
- one time token(一次性令牌)

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

# Reference
http://wiki.open.qq.com/wiki/Web%E6%BC%8F%E6%B4%9E%E6%A3%80%E6%B5%8B%E5%8F%8A%E4%BF%AE%E5%A4%8D#1.2_XSS.E6.BC.8F.E6.B4.9E
