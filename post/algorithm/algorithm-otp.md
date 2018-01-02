---
layout: page
title:	利用google authentication 构建otp 动态口令
category: blog
description: 
---
# Preface
otp是一次密码，有两种: totp是基于时间的，htop是基于次数的。

> Google Authenticator这个开源的项目实现了基于时间的一次一密算法，也就是Time-based One-time Password (TOTP)，这个是客户端的实现。同时在GitHub上有服务器端的实现。大家在github厘搜搜，几乎任何语言的totp hotp的实现方式都有的，拿来就能用。

# todo
[google-ota-xiaorui](http://xiaorui.cc/2014/11/09/%E5%88%A9%E7%94%A8google-authenticator%E6%9E%84%E5%BB%BA%E5%B9%B3%E5%8F%B0%E7%9A%84otp%E5%8A%A8%E6%80%81%E5%8F%A3%E4%BB%A4/#6553914-tsina-1-86843-1435db7ae6428e307c2c15a8c8543b8f)

# Implement
https://github.com/stolendata/totp

# Reference
- [google-ota-xiaorui]

[google-ota-xiaorui]: http://xiaorui.cc/2014/11/09/%E5%88%A9%E7%94%A8google-authenticator%E6%9E%84%E5%BB%BA%E5%B9%B3%E5%8F%B0%E7%9A%84otp%E5%8A%A8%E6%80%81%E5%8F%A3%E4%BB%A4/#6553914-tsina-1-86843-1435db7ae6428e307c2c15a8c8543b8f
