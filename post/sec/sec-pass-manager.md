---
title: 安全的密码管理软件
date: 2019-02-27
private:
---

# 安全的密码管理软件

1. lastpass: 适合web 网站, 远端存储密码
2. keepass: 开源，需要自己在本地存储密码, 可以同步到网盘
    1. keepass 官方只有Windows版本(c#)，在linux系统上要借助mono运行
    2. keepassXC: 基于c++/qt 的跨平台开源版本
3. pass: standard unix password manager for cli terminal.
   1. brew install pass
4. 用qq/weibo快捷登录：不适合不支持qq/weibo 的网站

# Pass

Refer to: https://www.passwordstore.org/

## pass philosophy

With pass,

1. each password lives inside of `a gpg encrypted file` whose filename is the
   `title of the website`
2. organized into folder hierarchies
3. All passwords live in `~/.password-store/`, tracking password changes using
   `git`.

## install

    brew install pass libtasn1, nettle, p11-kit, gnutls, libgpg-error, libassuan, libgcrypt, libusb, npth, pinentry, gnupg, qrencode

source:

    git clone https://git.zx2c4.com/password-store

## Setting it up

To begin, there is a single command to initialize the password store:

    zx2c4@laptop ~ $ pass init "gpgid"
    mkdir: created directory ‘/home/zx2c4/.password-store’

Here, `gpgid` is the ID of my GPG key`.password-store/.gpg-id`. different
folders can have different GPG keys, by using `-p`.

We can additionally initialize the password store as a git repository:

    zx2c4@laptop ~ $ pass git init
    Initialized empty Git repository in /home/zx2c4/.password-store/.git/
    zx2c4@laptop ~ $ pass git remote add origin kexec.com:pass-store
    If a git repository is initialized, pass creates a git commit each time the password store is manipulated.

### pass git

If the password store is a git repository, since each manipulation creates a git
commit, you can synchronize the password store using :

    pass git push
    pass git pull

# Using the password store

We can list all the existing passwords in the store:

    zx2c4@laptop ~ $ pass
    Password Store
    ├── Business
    │   ├── some-silly-business-site.com
    │   └── another-business-site.net
    ├── Email
    │   ├── donenfeld.com
    │   └── zx2c4.com
    └── France
        ├── bank
        ├── freebox
        └── mobilephone

And we can show passwords too:

    zx2c4@laptop ~ $ pass Email/zx2c4.com
    sup3rh4x3rizmynam3
    Or copy them to the clipboard:

    zx2c4@laptop ~ $ pass -c Email/zx2c4.com
    Copied Email/jason@zx2c4.com to clipboard. Will clear in 45 seconds.

## insert remove

We can add existing passwords to the store with insert:

    zx2c4@laptop ~ $ pass insert Business/cheese-whiz-factory
    Enter password for Business/cheese-whiz-factory: omg so much cheese what am i gonna do

The utility can generate new passwords using /dev/urandom internally:

    zx2c4@laptop ~ $ pass generate Email/jasondonenfeld.com 15
    The generated password to Email/jasondonenfeld.com is:
    $(-QF&Q=IN2nFBx

It's possible to generate passwords with no symbols using `--no-symbols or -n`,
and we can copy it to the clipboard instead of displaying it at the console
using `--clip or -c`

And of course, passwords can be removed:

    zx2c4@laptop ~ $ pass rm Business/cheese-whiz-factory
    rm: remove regular file ‘/home/zx2c4/.password-store/Business/cheese-whiz-factory.gpg’? y

### multiple info

This also handles multiline passwords or other data with `--multiline or -m`,
and passwords can be edited in your default text editor using
`pass edit pass-name`. e.g. For example, `Amazon/bookreader`

    Yw|ZSNH!}z"6{ym9pI
    URL: *.amazon.com/*
    Username: AmazonianChicken@example.com
    Secret Question 1: What is your childhood best friend's most bizarre superhero fantasy? Oh god, Amazon, it's too awful to say...
    Phone Support PIN #: 84719

## git https with pass

git https 每次输入密码太麻烦了，可以利用pass 来管理 https://github.com/muxueqz/git-credential-pass

    git config --global credential.helper /usr/local/bin/git-credential-pass.py
    git config credential.helper /usr/local/bin/git-credential-pass.py
