---
title: lua str serial
date: 2020-05-09
private: true
---
# lua str serial
# json(含openresty)
    luarocks install lua-cjson

then in lua:

    local json = require('cjson')
    data= {k="中国"}
    str = json.encode(data)
    d = json.decode(str)
    print(str, d)

error: 

    local success, res = pcall(json.decode, json_str);
    if success then
        -- res contains a valid json object
        ...
    else
        -- res contains the error message
        ...
    end