---
title: openresty install
date: 2020-05-19
private: true
---

# brew 安装

    brew tap openresty/brew
    brew untap homebrew/nginx

    # or: brew install openresty 
    brew install openresty/brew/openresty-debug

## start:

    # mac
    brew services start openresty/brew/openresty
    brew services start openresty/brew/openresty-debug

    # start with conf
    openresty -c ./nginx.conf

### mac boot

    brew services
    $ cat ~/Library/LaunchAgents/homebrew.mxcl.openresty-debug.plist
    /opt/homebrew/opt/openresty-debug/bin/openresty -g 'daemon off;'
    /opt/homebrew/opt/openresty-debug/bin/openresty -h


## stop:

    brew services info openresty/brew/openresty
    brew services stop openresty/brew/openresty
    brew services restart openresty/brew/openresty

## restart
linux:

## conf:

    openresty -h 
    -c filename   : set configuration file (default: /opt/homebrew/etc/openresty/nginx.conf)

# 源码安装

## 预编译

安装到：/usr/local/opt/openresty

    ./configure --prefix=/usr/local/opt/openresty --with-http_iconv_module  --with-http_postgres_module --with-debug

如果openssl 找不到，两种方法

1. 方法1：下载openssl 源码, 用 `--with-openssl=OPENSSL_SOURCE_DIR`
2. 方法2： 或者用brew 下载安装openssl 源码

其中方法2：

    $ brew install openssl
    $ brew link --force openssl
    For compilers to find openssl@1.1 you may need to set:
        export LDFLAGS="-L/usr/local/opt/openssl@1.1/lib"
        export CPPFLAGS="-I/usr/local/opt/openssl@1.1/include"

    $ ./configure --with-cc-opt="-I/usr/local/opt/openssl@1.1/include" --with-ld-opt="-L/usr/local/opt/openssl@1.1/lib" `

    # 不要用下面这个！
    $ ./configure --with-openssl=/usr/local/opt/openssl@1.1/

## 编译-安装

最后：

    make && make install
    ln -sf /usr/local/opt/openresty/nginx/sbin/nginx /usr/local/opt/openresty/bin/openresty
    ln -sf /usr/local/opt/openresty/nginx/sbin/nginx /usr/local/bin/

# config

## config path

    $ openresty -t
    nginx: the configuration file /usr/local/etc/openresty/nginx.conf syntax is ok
    nginx: configuration file /usr/local/etc/openresty/nginx.conf test is successful
