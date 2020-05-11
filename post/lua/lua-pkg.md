---
title: lua pkg
date: 2020-05-08
private: true
---
# lua pkg

    brew install luarocks

如果要绑定特定的lua 版本，就手工编译吧：

    -$ wget https://luarocks.org/releases/luarocks-3.3.1.tar.gz
    -$ tar zxpf luarocks-3.3.1.tar.gz
    -$ cd luarocks-3.3.1
    ./configure -h
    ./configure  --with-lua-bin=/usr/local/opt/lua@5.1/bin
    make && make install

## install pkg
    $ luarocks install md5

代码：

    local md5 = require "md5"

    luarocks install lua-cjson
    require("cjson")
