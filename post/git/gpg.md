---
title: gpg 加密工具
date: 2022-04-09
private: true
---
# gpg 加密
> 参考: https://www.ruanyifeng.com/blog/2013/07/gpg.html

gpg 是gnu 出品的加密工具

安装

    brew install gpg

# 生成key
　　gpg --gen-key

生成密钥时，为了防止误操作，或者系统被侵入时有人擅自动用私钥。 可以用一个密码来保护您的私钥(也可为空)


# 密钥管理
## 输出公钥
公钥文件（.gnupg/pubring.gpg）以二进制形式储存，armor参数可以将其转换为ASCII码显示。

　　gpg --armor --output public-key.txt --export [用户ID]

## 上传公钥
公钥服务器是网络上专门储存用户公钥的服务器。send-keys参数可以将公钥上传到服务器。

　　gpg --send-keys [用户ID] --keyserver hkp://subkeys.pgp.net
