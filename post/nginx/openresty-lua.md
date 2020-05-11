---
title: openresty response
date: 2020-05-09
private: true
---
# lua ngx module
> https://github.com/openresty/lua-nginx-module
该模块通过标准 Lua5.1 解释器或 LuaJIT 2.0/2.1，把 Lua 嵌入到 Nginx 里面

与 Apache's mod_lua、Lighttpd's mod_magnet 不同的是, 该模块的 Lua 代码被执行在网络上是 100% 非阻塞的。其中上游请求服务有：MySQL、PostgreSQL、Memcached、Redis或upstream HTTP web 服务等。

# npx 常量/变量

    ngx.arg[index]    #ngx指令参数，当这个变量在set_by_lua或者set_by_lua_file内使用的时候是只读的，指的是在配置指令输入的参数。
    ngx.var.varname    #读写NGINX变量的值，最好在lua脚本里缓存变量值，避免在当前请求的声明周期内内存的泄露
    ngx.config.ngx_lua_version   #当前ngx_lua模块的版本号
    ngx.config.nginx_version   #nginx版本
    ngx.worker.exiting    #当前worker进程是否正在关闭
    ngx.worker.pid    #当前worker进程的PID
    ngx.config.nginx_configure #编译时的./configure命令选项
    ngx.config.prefix    #编译时的prefix选项

npx.var 存储请求上下文nginx的变量

    ngx.var.proxy_port = port
    
## nginx变量:ngx.var.VAR_NAME
    syntax: ngx.var.VAR_NAME
    context: set_by_lua*, rewrite_by_lua*, access_by_lua*, content_by_lua*, header_filter_by_lua*, body_filter_by_lua*, log_by_lua*

Read and write Nginx variable values.

    set $a 'yes';  -- 先定义
    rewrite_by_lua_block {
        -- 不能say: ngx.say(ngx.var.a), say 会覆盖后面的echo
        ngx.var.a='no'
    }
    echo $a;

### regex group capturing variables
Nginx regex group capturing variables `$1, $2, $3`, and etc, can be read by this interface as well, by writing `ngx.var[1], ngx.var[2], ngx.var[3]`, and etc.

## ngx.ctx
This table can be used to store `per-request Lua context data` (as with the Nginx variables).

    location /test {
        rewrite_by_lua_block {
            ngx.ctx.foo = 76
        }
        access_by_lua_block {
            ngx.ctx.foo = ngx.ctx.foo + 3
        }
        content_by_lua_block {
            ngx.say(ngx.ctx.foo)
        }
    }

## ngx.shared
`Shared memory` zones are always shared by `all the Nginx worker processes`

    lua_shared_dict mycache 100m;

    access_by_lua_block {
        ngx.shared.mycache:set("key", "value")
        ngx.shared.mycache:get("key")
    }

# lua log
    ngx.log(level, ...)
        ngx.log(1, 'msg')   
        ngx.log(ngx.ERR, 'msg') #写log 到logs/error.log
    print()               #与ngx.print()方法有区别，print()相当于ngx.log()???

# lua api
![](/img/openresty/lua-api.png)

    init_by_lua     (master?)
    init_worker_by_lua
    
    set_by_lua
    rewrite_by_lua
    access_by_lua

    content_by_lua
    header_filter_by_lua
    body_filter_by_lua

    log_by_lua

## request
    for k,v in pairs(ngx.req) do
        npx.say(k)
    end

output:

    get_post_args
    get_uri_args
    set_uri
    set_method
    get_method
    get_query_args
    start_time
    set_body_file
    clear_header
    get_headers
    discard_body
    set_header
    get_body_data
    read_body
    get_body_file
    set_uri_args

### header
    local h, err = ngx.req.get_headers()
    if err == "truncated" then
        -- one can choose to ignore or reject the current request here
    end

    for k, v in pairs(h) do
        ...
    end

#### set header(request)

    ngx.req.set_header("Content-Type", "text/css")
    ngx.req.set_header("Foo", {"a", "abc"})

clear

    ngx.req.set_header("X-Foo", nil)
    ngx.req.clear_header("X-Foo")

#### set header(response)
Nginx Syntax:	`add_header name value`;

### cookie

#### read cookie
##### 读取cookie一（原生）
    print(ngx.req.get_headers()["cookie"])
    print(ngx.var.http_cookie) -- 获取所有cookie
    print(ngx.var.cookie_username) -- 获取单个cookie

##### 获取cookie二（lua-resty-cookie）
    local cookie = resty_cookie:new()
    local all_cookie = cookie:get_all() -- 这里获取到所有的cookie，是一个table，如果不存在则返回nil
    print(cjson.encode(all_cookie))

    -- 获取单个cookie的值，如果不存在则返回nil
    print(cookie:get('c'))             
#### set cookie(request)
两者不能同时读取`http_cookie`，否则优先级高的cookie会被放弃

    // 优先级低
	proxy_set_header Cookie "$http_cookie;ck1=cv1"; 
    // 优先级高
    access_by_lua_block{
        ngx.req.set_header("Cookie", ngx.var.http_cookie..";ck2=cv2")
    }
    proxy_pass http://localhost:5002/pre;

#### set cookie (response)
##### 设置cookie一（原生）
    add_header Set-Cookie foo=bar;
    ngx.header['Set-Cookie'] = {'a=32; path=/', 'b=4; path=/'}  -- 批量设置cookie

设置单个cookie，通过多次调用来设置多个值

    ngx.header['Set-Cookie'] = 'a=32; path=/' 
    ngx.header['Set-Cookie'] = 'c=5; path=/; Expires=' .. ngx.cookie_time(ngx.time() + 60 * 30) -- 设置Cookie过期时间为30分钟

##### 设置cookie二（lua-resty-cookie）
    cookie:set({
        key = "c",
        value = "123456",
        path = "/",
        domain = "localhost",
        expires = ngx.cookie_time(ngx.time() + 60 * 13)
    })

### get args
query string:

    if ngx.var.query_string then

args:

    # try access /nginx_var?a=hello,world
    content_by_lua_block {
        ngx.say(ngx.var.arg_a)
    }

### post data

    ngx.req.read_body()
    local args, err = ngx.req.get_post_args()

    for key, val in pairs(args) do
        if type(val) == "table" then
            ngx.say(key, ": ", table.concat(val, ", "))
        else
            ngx.say(key, ": ", val)
        end
    end

### body
    ngx.req.read_body()  -- explicitly read the req body
    local data = ngx.req.get_body_data()
    if data then
        ngx.say("body data:")
        ngx.print(data)
        return
    end

file:

    local file = ngx.req.get_body_file()
    if file then
        ngx.say("body is in file ", file)
    end

### rewrite/set_uri

    rewrite ^ /foo last;
    ngx.req.set_uri("/foo", true)

Similarly, Nginx config

    rewrite ^ /foo break;
    ngx.req.set_uri("/foo", false)
    ngx.req.set_uri("/foo")

## response
### content_by_lua

    location /foo {
        content_by_lua '
            ngx.status = 401
            local jsonStr = '{"name":"foo"}'
            ngx.header['Content-Type'] = 'application/json'
            ngx.say(jsonStr)
            ngx.exit(200)
        ';
    }

### header
    local key = ngx.var.http_user_agent
     -- equivalent to ngx.header["Content-Type"] = 'text/plain'
    ngx.header.content_type = 'text/plain';

# router
### 中断

#### exit 403
    ngx.exit(ngx.HTTP_FORBIDDEN)

#### location
    ngx.redirect(uri, args)  #执行301或者302的重定向。
