---
title: lua str serial
date: 2020-05-09
private: true
---
# lua str serial
# json
    luarocks install lua-cjson

then in lua:

    local json = require('cjson')
    data= {k="中国"}
    str = json.encode(data)
    d = json.decode(str)
    print(str, d)