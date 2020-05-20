---
title: openresty lua api
date: 2020-05-09
private: true
---
# openresty lua api

# API指令
![](/img/openresty/lua-api.png)
https://openresty-reference.readthedocs.io/en/latest/Lua_Nginx_API/#ngxredirect

# openresty opm 包管理
自1.11.2.2开始，OpenResty版本已经包含并默认安装opm。所以通常你不需要自己安装opm ， 只需要做一个软连接 。附：踩坑之旅

    cd /usr/local/openresty/bin
    sudo ln -s `pwd`/opm /usr/local/bin/opm
    
    opm search 包名  #搜索包名
    opm get 包名 #默认下载路径：/usr/local/openresty/site/lualib/resty
    
    #规范包安装目录
    /usr/local/openresty/lualib/resty
    #正确安装方法：
    opm --install-dir=/usr/local/openresty get 包名

# 参考文献
https://github.com/openresty/lua-nginx-module#locations-configured-by-subrequest-directives-of-other-modules
https://github.com/iresty/nginx-lua-module-zh-wiki
