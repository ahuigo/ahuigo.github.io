---
title: gpg 加密工具
date: 2022-04-09
private: true
---
# gpg 加密
> 参考: https://www.ruanyifeng.com/blog/2013/07/gpg.html
> https://www.bitlogs.tech/2019/01/gpg%E4%BD%BF%E7%94%A8%E6%95%99%E7%A8%8B/

安装

    brew install gpg

## 什么是GPG
GnuPG（GNU Privacy Guard，GPG）是一种加密软件，它是PGP加密软件的开源替代物。GnuPG依照由 IETF 制定的 OpenPGP 技术标准设计。**GnuPG是用于加密、数字签章及产生非对称匙对的软件。** GPG 兼容 PGP（Pretty Good Privacy）的功能。

## 安装
一般Linux发行版都包含GPG软件包，可以通过发行版的包管理器来安装（一般发行版都会默认安装，因为这个软件太重要了）。使用下面的命令确认当前系统是否安装了GPG

```
gpg --version
gpg --help
命令：

 -s, --sign                  生成一份签名
     --clear-sign            生成一份明文签名
 -b, --detach-sign           生成一份分离的签名
 -e, --encrypt               加密数据
 -c, --symmetric             仅使用对称密文加密
 -d, --decrypt               解密数据（默认）
     --verify                验证签名
 -k, --list-keys             列出密钥
     --list-signatures       列出密钥和签名
     --check-signatures      列出并检查密钥签名
     --fingerprint           列出密钥和指纹
 -K, --list-secret-keys      列出私钥
     --generate-key          生成一个新的密钥对
     --quick-generate-key    快速生成一个新的密钥对
     --quick-add-uid         快速添加一个新的用户标识
     --quick-revoke-uid      快速吊销一个用户标识
     --quick-set-expire      快速设置一个过期日期
     --full-generate-key     完整功能的密钥对生成
     --generate-revocation   生成一份吊销证书
     --delete-keys           从公钥钥匙环里删除密钥
     --delete-secret-keys    从私钥钥匙环里删除密钥
     --quick-sign-key        快速签名一个密钥
     --quick-lsign-key       快速本地签名一个密钥
     --quick-revoke-sig      quickly revoke a key signature
     --sign-key              签名一个密钥
     --lsign-key             本地签名一个密钥
     --edit-key              签名或编辑一个密钥
     --change-passphrase     更改密码
     --export                导出密钥
     --send-keys             个密钥导出到一个公钥服务器上
     --receive-keys          从公钥服务器上导入密钥
     --search-keys           在公钥服务器上搜索密钥
     --refresh-keys          从公钥服务器更新所有密钥
     --import                导入/合并密钥
     --card-status           打印卡片状态
     --edit-card             更改卡片上的数据
     --change-pin            更改卡片的 PIN
     --update-trustdb        更新信任数据库
     --print-md              打印消息摘要
     --server                以服务器模式运行
     --tofu-policy VALUE     设置一个密钥的 TOFU 政策

选项：

 -a, --armor                 创建 ASCII 字符封装的输出
 -r, --recipient USER-ID     为 USER-ID 加密
 -u, --local-user USER-ID    使用 USER-ID 来签名或者解密
 -z N                        设置压缩等级为 N （0 为禁用）
     --textmode              使用规范的文本模式
 -o, --output FILE           写输出到 FILE
 -v, --verbose               详细模式
 -n, --dry-run               不做任何更改
 -i, --interactive           覆盖前提示
     --openpgp               使用严格的 OpenPGP 行为

（请参考手册页以获得所有命令和选项的完整列表）

例子：

 -se -r Bob [file]          为用户 Bob 签名和加密
 --clear-sign [file]        创建一个明文签名
 --detach-sign [file]       创建一个分离签名
 --list-keys [names]        列出密钥
 --fingerprint [names]      显示指纹


```

## 常规操作

### 生成密钥对

```
## 生成新的密钥对
## 以专家模式生成可以添加 --expert 选项
gpg --gen-key
gpg --generate-key

## 以全功能形式生成新的密钥对（期间会有一些密钥的配置）
gpg --full-generate-key
gpg --full-gen-key

```

生成的密钥对一般放在`~/.gnupg`目录下

> `gpg --full-generate-key` 命令可以配置加密算法，密钥长度，过期时间，私钥的密码，等信息。
>
> 生成密钥对时，会要求你做一些随机的举动（敲打键盘、移动鼠标、读写硬盘之类），以使随机数生成器获得足够的熵。

```
$ gpg --expert --full-gen-key
gpg (GnuPG) 2.2.27; Copyright (C) 2021 Free Software Foundation, Inc.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

请选择您要使用的密钥类型：
   (1) RSA 和 RSA （默认）
   (2) DSA 和 Elgamal
   (3) DSA（仅用于签名）
   (4) RSA（仅用于签名）
   (7) DSA（自定义用途）
   (8) RSA（自定义用途）
   (9) ECC 和 ECC
  (10) ECC（仅用于签名）
  (11) ECC（自定义用途）
  (13) 现存的密钥
  (14) Existing key from card
您的选择是？ 1
RSA 密钥的长度应在 1024 位与 4096 位之间。
您想要使用的密钥长度？(3072) 4096
请求的密钥长度是 4096 位
RSA 密钥的长度应在 1024 位与 4096 位之间。
您想要为此子密钥使用的密钥长度？(3072) 4096
请求的密钥长度是 4096 位
请设定这个密钥的有效期限。
         0 = 密钥永不过期
      <n>  = 密钥在 n 天后过期
      <n>w = 密钥在 n 周后过期
      <n>m = 密钥在 n 月后过期
      <n>y = 密钥在 n 年后过期
密钥的有效期限是？(0) 0
密钥永远不会过期
这些内容正确吗？ (y/N) y

GnuPG 需要构建用户标识以辨认您的密钥。

真实姓名： xxxx
电子邮件地址： xxxx@xxxx.xxx
注释：
您选定了此用户标识：
    "xxxx <xxxx@xxxx.xxx>"

更改姓名（N）、注释（C）、电子邮件地址（E）或确定（O）/退出（Q）？ O
我们需要生成大量的随机字节。在质数生成期间做些其他操作（敲打键盘
、移动鼠标、读写硬盘之类的）将会是一个不错的主意；这会让随机数
发生器有更好的机会获得足够的熵。
我们需要生成大量的随机字节。在质数生成期间做些其他操作（敲打键盘
、移动鼠标、读写硬盘之类的）将会是一个不错的主意；这会让随机数
发生器有更好的机会获得足够的熵。
gpg: 密钥 FD2E492696DE0885 被标记为绝对信任
gpg: 吊销证书已被存储为'/home/${USER}/.gnupg/openpgp-revocs.d/3C567C3531972BD222B579A3FD2E492696DE0885.rev'
公钥和私钥已经生成并被签名。

pub   rsa4096 2021-11-25 [SC]
      3C567C3531972BD222B579A3FD2E492696DE0885
uid                      xxxx <xxxx@xxxx.xxx>
sub   rsa4096 2021-11-25 [E]

```

上面的命令生成了一个主公钥（pub 开头的部分），和一个UID（uid 开头的部分），以及一个子密钥对（sub 开头的部分）。

生成密钥之后 建议生成一张"撤销证书"，用于密钥作废时，可以请求外部的公钥服务器撤销公钥。

```
gpg --gen-revoke [用户ID]

```

> 此处的用户ID可以是生成密钥时的邮箱，也可以是第一行下面的ASCII串

```
$ gpg --gen-revoke 3C567C3531972BD222B579A3FD2E492696DE0885

sec  rsa4096/FD2E492696DE0885 2021-11-25 xxxx <xxxx@xxxx.xxx>

要为这个密钥创建一个吊销证书吗？(y/N) y
请选择吊销的原因：
  0 = 未指定原因
  1 = 密钥已泄漏
  2 = 密钥被替换
  3 = 密钥不再使用
  Q = 取消
（也许您会想要在这里选择 1）
您的决定是什么？ 3
请输入描述（可选）；以空白行结束：
>
吊销原因：密钥不再使用
（未给定描述）
这样可以吗？ (y/N) y
已强行使用 ASCII 字符封装过的输出。
-----BEGIN PGP PUBLIC KEY BLOCK-----
Comment: This is a revocation certificate

iQI2BCABCgAgFiEEPFZ8NTGXK9IitXmj/S5JJpbeCIUFAmGe+MwCHQMACgkQ/S5J
JpbeCIVNRA/+PG0DSXQlpLjaYG0sZWNKRy0v8S55qsKVIdTmNMBOefVE+sga90hf
I6D8I8kRWk37Zv8o+JTVRff6sr9IEO/AiYpeHSZ+h8lcWY2VSnkzm38cEPQzHDw0
88w8zX8H72tfZeyl4nMeBsgXhi+bdQcdek6uSDkLTnbt4QE62LwzWJJaz2Zx+595
6nsIl7jByX15hKU6uvkIJnDcAGRhxgnRkGSsqz+dW4kF0jHskfmI33PQ1j9AwLJc
Q2gYRrog849dEIDrW0cy8zxiBvK2BKlRaai9QOxadGEb4mCYVYAipt6xophkbnfW
MIyzhLMWIHGrVyscL8+X40LBl7Tmix3R6aVYzYKbIGDAHDEOU0V7Vck8RLqmd5MJ
m2c34HFHTcFgZ8T5WfH/qMIEdIoGp+3PQAcilJFvwzZ0rPMS/5QGhKjDZWeBpTpL
zhXy76SAgN87+yjyFQNEi5wdYlXN3GczH5ZZ/WPAttTCWso+U1dXcHMhRnTFKYkN
spHDIIVvHqFmIkmhqLu0ZNth269h9hfnF+a7Qp8DiRt3NYYAZ8lCcuArdHUfdyIi
EIKUQ9JdzK7pvvBCqokKwVhaFIyN+VcqyO6tTUtOD4G+B7dwcF4UfjtpIqCELEam
BT8Mtdvw+TFGifLVyWEaLCv+WR2raiBHEo2wsHffgsU7K6Uw5FS8PX0=
=3BPs
-----END PGP PUBLIC KEY BLOCK-----
已创建吊销证书。

请把这个文件转移到一个您可以藏起来的介质上；如果坏人获取到了这
份证书的话，那么他就能使用它并让您的密钥无法继续使用。把此证书
打印出来再存放到安全的地方也是很好的方法，以免您的保存媒体变得
不可读。但是千万小心：您机器上的打印系统可能会在打印过程中储存
这些数据，并使得其他人看到！

```

### 列出密钥

列出公钥

```
gpg --list-keys
gpg --list-key [用户ID]

```

列出私钥

```
gpg --list-secret-keys

```

```
$ gpg --list-keys --keyid-format long
/home/${USER}/.gnupg/pubring.kbx
--------------------------------
pub   rsa4096/FD2E492696DE0885 2021-11-25 [SC]
      3C567C3531972BD222B579A3FD2E492696DE0885
uid                 [ 绝对 ] xxxx <xxxx@xxxx.xxx>
sub   rsa4096/ABA8F7315521729D 2021-11-25 [E]

$ gpg --list-secret-keys --keyid-format long
/home/${USER}/.gnupg/pubring.kbx
--------------------------------
sec   rsa4096/FD2E492696DE0885 2021-11-25 [SC]
      3C567C3531972BD222B579A3FD2E492696DE0885
uid                 [ 绝对 ] xxxx <xxxx@xxxx.xxx>
ssb   rsa4096/ABA8F7315521729D 2021-11-25 [E]

```

输出的内容中，最前面的标识是密钥类型的标识。如果后面的标识带的 `#` ，则表示密钥已经被删除

> -   pub   主公钥
> -   sub   子公钥
> -   sec   主私钥
> -   ssb   子私钥

尾部被 `[]` 包围的部分是密钥的用途

> -   S   用于签名与验签
> -   E   用于加密与解密
> -   A   用于身份认证
> -   C   认证其他子密钥或UID

### 添加子密钥

一个主密钥可以包含多个子密钥，各子密钥用于不同的用途，注意，**尽量不要用主密钥执行实际的加解密或者签名验签操作**，主密钥只用于管理多个用于各操作的子密钥。

GPG 提供了交互式添加子密钥的方法，`gpg --expert --edit-key [用户ID]` 进入交互式密钥编辑，使用 `addkey` 添加子密钥。

以下操作添加两个子密钥，分别用于签名和认证

> 注意： 所有操作结束，一定要 save

```
$ gpg --expert --edit-key 3C567C3531972BD222B579A3FD2E492696DE0885
gpg (GnuPG) 2.2.27; Copyright (C) 2021 Free Software Foundation, Inc.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

私钥可用。

sec  rsa4096/FD2E492696DE0885
     创建于：2021-11-25  有效至：永不       可用于：SC
     信任度：绝对        有效性：绝对
ssb  rsa4096/ABA8F7315521729D
     创建于：2021-11-25  有效至：永不       可用于：E
[ 绝对 ] (1). xxxx <xxxx@xxxx.xxx>

gpg> addkey
请选择您要使用的密钥类型：
   (3) DSA（仅用于签名）
   (4) RSA（仅用于签名）
   (5) ElGamal（仅用于加密）
   (6) RSA（仅用于加密）
   (7) DSA（自定义用途）
   (8) RSA（自定义用途）
  (10) ECC（仅用于签名）
  (11) ECC（自定义用途）
  (12) ECC（仅用于加密）
  (13) 现存的密钥
  (14) Existing key from card
您的选择是？ 4
RSA 密钥的长度应在 1024 位与 4096 位之间。
您想要使用的密钥长度？(3072) 4096
请求的密钥长度是 4096 位
请设定这个密钥的有效期限。
         0 = 密钥永不过期
      <n>  = 密钥在 n 天后过期
      <n>w = 密钥在 n 周后过期
      <n>m = 密钥在 n 月后过期
      <n>y = 密钥在 n 年后过期
密钥的有效期限是？(0) 0
密钥永远不会过期
这些内容正确吗？ (y/N) y
真的要创建吗？(y/N) y
我们需要生成大量的随机字节。在质数生成期间做些其他操作（敲打键盘
、移动鼠标、读写硬盘之类的）将会是一个不错的主意；这会让随机数
发生器有更好的机会获得足够的熵。

sec  rsa4096/FD2E492696DE0885
     创建于：2021-11-25  有效至：永不       可用于：SC
     信任度：绝对        有效性：绝对
ssb  rsa4096/ABA8F7315521729D
     创建于：2021-11-25  有效至：永不       可用于：E
ssb  rsa4096/6469C3DB253D9A2D
     创建于：2021-11-25  有效至：永不       可用于：S
[ 绝对 ] (1). xxxx <xxxx@xxxx.xxx>

gpg> addkey
请选择您要使用的密钥类型：
   (3) DSA（仅用于签名）
   (4) RSA（仅用于签名）
   (5) ElGamal（仅用于加密）
   (6) RSA（仅用于加密）
   (7) DSA（自定义用途）
   (8) RSA（自定义用途）
  (10) ECC（仅用于签名）
  (11) ECC（自定义用途）
  (12) ECC（仅用于加密）
  (13) 现存的密钥
  (14) Existing key from card
您的选择是？ 8

RSA 密钥的可实现的功能： 签名（Sign） 加密（Encrypt） 身份验证（Authenticate）
目前启用的功能： 签名（Sign） 加密（Encrypt）

   (S) 签名功能开关
   (E) 加密功能开关
   (A) 身份验证功能开关
   (Q) 已完成

您的选择是？ S

RSA 密钥的可实现的功能： 签名（Sign） 加密（Encrypt） 身份验证（Authenticate）
目前启用的功能： 加密（Encrypt）

   (S) 签名功能开关
   (E) 加密功能开关
   (A) 身份验证功能开关
   (Q) 已完成

您的选择是？ E

RSA 密钥的可实现的功能： 签名（Sign） 加密（Encrypt） 身份验证（Authenticate）
目前启用的功能：

   (S) 签名功能开关
   (E) 加密功能开关
   (A) 身份验证功能开关
   (Q) 已完成

您的选择是？ A

RSA 密钥的可实现的功能： 签名（Sign） 加密（Encrypt） 身份验证（Authenticate）
目前启用的功能： 身份验证（Authenticate）

   (S) 签名功能开关
   (E) 加密功能开关
   (A) 身份验证功能开关
   (Q) 已完成

您的选择是？ Q
RSA 密钥的长度应在 1024 位与 4096 位之间。
您想要使用的密钥长度？(3072) 4096
请求的密钥长度是 4096 位
请设定这个密钥的有效期限。
         0 = 密钥永不过期
      <n>  = 密钥在 n 天后过期
      <n>w = 密钥在 n 周后过期
      <n>m = 密钥在 n 月后过期
      <n>y = 密钥在 n 年后过期
密钥的有效期限是？(0) 0
密钥永远不会过期
这些内容正确吗？ (y/N) y
真的要创建吗？(y/N) y
我们需要生成大量的随机字节。在质数生成期间做些其他操作（敲打键盘
、移动鼠标、读写硬盘之类的）将会是一个不错的主意；这会让随机数
发生器有更好的机会获得足够的熵。

sec  rsa4096/FD2E492696DE0885
     创建于：2021-11-25  有效至：永不       可用于：SC
     信任度：绝对        有效性：绝对
ssb  rsa4096/ABA8F7315521729D
     创建于：2021-11-25  有效至：永不       可用于：E
ssb  rsa4096/6469C3DB253D9A2D
     创建于：2021-11-25  有效至：永不       可用于：S
ssb  rsa4096/25FF45E4F19E6564
     创建于：2021-11-25  有效至：永不       可用于：A
[ 绝对 ] (1). xxxx <xxxx@xxxx.xxx>

gpg> save

```

### 导出密钥对

公钥文件（.gnupg/pubring.gpg）是二进制形式保存的，可以将其导出成ASCII码形式的文件，私钥也可以导出，但是一定要妥善保管，一旦泄露，会产生非常严重的泄露事故。

```
## 导出所有密钥对
gpg --armor --output 3C567C3531972BD222B579A3FD2E492696DE0885.sec.pem --export-secret-keys 3C567C3531972BD222B579A3FD2E492696DE0885

## 仅导出主密钥 在上面的命令后面加 ! 即可
gpg --armor --output 3C567C3531972BD222B579A3FD2E492696DE0885.private.sec.pem --export-secret-keys 3C567C3531972BD222B579A3FD2E492696DE0885!

## 导出所有子密钥对
gpg --armor --output 3C567C3531972BD222B579A3FD2E492696DE0885.sub.sec.pem --export-secret-subkeys 3C567C3531972BD222B579A3FD2E492696DE0885

## 导出单个子密钥对
gpg --armor --output ABA8F7315521729D.sub.sec.pem --export-secret-subkeys ABA8F7315521729D!

## 导出所有公钥
gpg --armor --output 3C567C3531972BD222B579A3FD2E492696DE0885.pub.pem --export 3C567C3531972BD222B579A3FD2E492696DE0885

## 导出单个公钥 这个一般不常用
gpg --armor --output ABA8F7315521729D.primary.pub.pem --export ABA8F7315521729D!

```

### 导入密钥

除了生成的密钥，为了验证其它系统分发的消息或者文件，需要导入其它人分发的密钥。这时可以使用import

```
gpg --import [密钥文件]

```

示例：

```
在A主机导出密钥

gpg --armor --output public-key.txt --export xxxxxxxxxxxx@xxxxx.xx

复制到B主机

scp public-key.txt xxxx@b:~

在B主机导入
gpg --import public-key.txt

验证指纹
gpg --fingerprint xxxxxxxxxxxx@xxxxx.xx

```

### 分发公钥

除了分发公钥文件，也可以从公钥服务器导入公钥。

公钥服务器是专门用于储存用户公钥的服务器。`--send-keys` 可以将公钥上传到指定的公钥服务器，供其它用户使用。

```
gpg --send-keys [用户ID] --keyserver hkp://subkeys.pgp.net

```

公钥服务器会使用同步机制使网络上的所有公钥服务器最终都会包含你的公钥。公钥服务器没有验证机制，所以任何人都可以上传公钥，无法保证服务器上的公钥完全可靠。通常，分发公钥指纹可以让用户验证公钥是否可靠：

```
gpg --fingerprint [用户ID]

```

```
$ gpg --fingerprint 3C567C3531972BD222B579A3FD2E492696DE0885
pub   rsa4096 2021-11-25 [SC]
      3C56 7C35 3197 2BD2 22B5  79A3 FD2E 4926 96DE 0885
uid           [ 绝对 ] xxxx <xxxx@xxxx.xxx>
sub   rsa4096 2021-11-25 [E]
sub   rsa4096 2021-11-25 [S]
sub   rsa4096 2021-11-25 [A]

```

### 获取公钥

公钥可以从公钥服务器上获取，`--search-keys` 可以在公钥服务器上搜索指定用户的公钥，`--recv-keys` 可以获取公钥服务器上的公钥。

以下以获取 [debian CD 发行签名](https://www.debian.org/CD/verify) 的公钥为例。

```
$ gpg --keyserver hkp://keys.openpgp.org --search-keys 10460DAD76165AD81FBC0CE9988021A964E6EA7D
gpg: data source: http://keys.openpgp.org:11371
(1)       4096 bit RSA key 988021A964E6EA7D, 创建于：2009-10-03
Keys 1-1 of 1 for "10460DAD76165AD81FBC0CE9988021A964E6EA7D".  输入数字以选择，输入 N 翻页，输入 Q 退出 > N

$ gpg --keyserver keyring.debian.org --recv-keys 6294BE9B
gpg: 密钥 DA87E80D6294BE9B：公钥 "Debian CD signing key <debian-cd@lists.debian.org>" 已导入
gpg: 处理的总数：1
gpg:               已导入：1

$ gpg --list-keys --keyid-format long 6294BE9B
pub   rsa4096/DA87E80D6294BE9B 2011-01-05 [SC]
      DF9B9C49EAA9298432589D76DA87E80D6294BE9B
uid                 [ 未知 ] Debian CD signing key <debian-cd@lists.debian.org>
sub   rsa4096/642A5AC311CD9819 2011-01-05 [E]

```

> 上面的示例，搜索公钥在 `keys.openpgp.org` 搜索，获取公钥在官方的 `keyring.debian.org` 获取，官方的密钥服务器没有实现搜索功能 :(

加密解密文件
------

### 加密

GPG加密操作，由发送方进行，首先获取接收方公钥，使用公钥加密文件。

```
 gpg --output 加密输出文件 --recipient xxxxxxxx --encrypt 待加密文件

```

假设现在要发送一份文件给 `debian-cd@lists.debian.org` ( **不要真的发送** )，可以使用相应的公钥加密文件

```
$ echo -e "HELLO\nThis is a messages for B \nplease decrypt it by secret key" > A.txt
$ echo -e "HELLO\please decrypt it by secret key \n This message is transported secrity" > B.txt

# 加密单个文件
$ gpg --output crypted.txt --recipient DF9B9C49EAA9298432589D76DA87E80D6294BE9B --encrypt A.txt

# 加密多个文件
$ gpg --recipient DF9B9C49EAA9298432589D76DA87E80D6294BE9B --encrypt-files A.txt B.txt

```

> 如果想生成可打印的内容，可以加上 `--armor` 选项
>
> 注意参数顺序，`--encrypt 待加密文件`在最后

### 解密

将加密后的文件发送到接收方，接收方使用自己的私钥解密

```
$ gpg --output 解密输出文件 --decrypt 加密后的文件

```

> 因为没有 `debian-cd@lists.debian.org` 的私钥，这里演示使用自己的公钥加密，使用自己的私钥解密

```
$ gpg --armor --output crypted.txt --recipient 3C567C3531972BD222B579A3FD2E492696DE0885 --encrypt A.txt
$ gpg --output decrypted.txt --decrypt crypted.txt

```

> 注意参数顺序，`--decrypt 加密后的文件`在最后
>
> 文本文件加密后，比源文件小很多。一开始以为加密失败了 ╮(￣▽￣)╭

文件签名与验签
-------

文件签名操作由文件分发方来做，首先，分发方使用自己的密钥对文件签名，并将签名后的文件（或者文件与文件签名）分发出去。

接收者使用分发方的公钥对文件进行验签，证明文件没有被篡改。

### 对文件签名

```
gpg --sign xxxx.xxx.gpg

```

这个命令会在当前目录下生成 xxxx.xxx.gpg，**这是签名后的文件**。采用二进制储存。

```
gpg --clear-sign xxxx.xxx

```

这个命令会生成 ASCII 签名后的文件。文件名为xxxx.xxx.asc。签名信息添加在文件尾

> 以上两个命令都是将签名添加到文件中，一般都不会用。

```
gpg --detach-sign xxxx.xxx

```

这个命令会在当前目录下生成 xxxx.xxx.sig **这是文件的签名**。采用二进制储存。

```
gpg --detach-sign --armor xxxx.xxx

```

这个命令会生成文件的ASCII签名xxxx.xxx.asc。

### 验证签名

```
gpg --verify --output xxxx.xxx xxxx.xxx.gpg

gpg --verify --output xxxx.xxx xxxx.xxx.asc

gpg --verify xxxx.xxx.sig

gpg --verify xxxx.xxx.asc

```

上面四种验签方式对应四种签名方式。

使用 GPG 密钥进行 SSH 身份验证
--------------------

使用 GPG 密钥进行 SSH 身份验证的功能，需要三步：

-   创建一个 Authenticate 的子密钥 （参见上面的示例）
-   启用 gpg-agent 的 SSH 支持
-   将 Authenticate 子密钥的 keygpid 添加到 `~/.gnupg/sshcontrol`
-   设置环境变量 `SSH_AUTH_SOCK`

**启用 gpg-agent 的 SSH 支持**

要启用 gpg-agent 的 SSH 支持，只需要把 `enable-ssh-support` 加入 `~/.gnupg/gpg-agent.conf` 并重启 `gpg-agent` 即可。

```
$ cat << EOF | tee -a ~/.gnupg/gpg-agent.conf
enable-ssh-support
EOF
$ gpgconf --kill gpg-agent

```

> 不需要手动重新启动 `gpg-agent`，GPG会在需要时重新启动它。

**将 Authenticate 子密钥的 keygpid 添加到 `~/.gnupg/sshcontrol`**

查看 Authenticate 子密钥的 keygpid

```
$ gpg --list-keys --with-keygrip
/home/xxxx/.gnupg/pubring.kbx
--------------------------------
pub   rsa4096 2021-11-25 [SC]
      3C567C3531972BD222B579A3FD2E492696DE0885
      Keygrip = 242CF907BB76E879C50B035208D2E8AF0DD95251
uid           [ 绝对 ] xxxx <xxxx@xxxx.xxx>
sub   rsa4096 2021-11-25 [E]
      Keygrip = FB37729B83A96584525D7D9947A9C514907FA4EB
sub   rsa4096 2021-11-25 [S]
      Keygrip = 1594044599385D24B8B5382CF5FA2294F55E3B93
sub   rsa4096 2021-11-25 [A]
      Keygrip = 434165545294FAAB5AEB7E20FFBE0D79F5C25CE0

```

最后一个 [A] 结尾的密钥就是用于 Authenticate 的密钥

```
echo "434165545294FAAB5AEB7E20FFBE0D79F5C25CE0 3600 confirm" >> ~/.gnupg/sshcontrol

```

> 三个字段分别为：Keygrip（必选），超时时间（秒为单位，可为空），Flag参数（是否每次使用时弹窗确认，仅支持参数：comfirm，可为空）

**设置环境变量 `SSH_AUTH_SOCK`**

```
$ echo -e "\nexport SSH_AUTH_SOCK=\$(gpgconf --list-dirs agent-ssh-socket)" >> ~/.profile
$ echo -e "\nexport SSH_AUTH_SOCK=\$(gpgconf --list-dirs agent-ssh-socket)" >> ~/.zprofile
$ export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)

```

验证

```
$ ssh-add -L
```