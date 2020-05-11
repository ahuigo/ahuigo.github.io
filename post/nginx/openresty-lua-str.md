---
title: openresty lua str
date: 2020-05-11
private: true
---
# openresty lua str
## url
    ngx.escape_uri()        #将URI编码(本函数对逗号，不编码，而php的uriencode会编码)
    ngx.unescape_uri()     #将uri解码

## split

    local t, err = ngx_re.split(cookie, ";")
    if not err then
        for pos, v in ipairs(t) do
            print(v)
        end
    end