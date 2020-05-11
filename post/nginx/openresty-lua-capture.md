---
title: openresty capture
date: 2020-05-11
private: true
---
# openresty capture
# location capture
几乎所有的 Nginx 模块都可以通过 ngx.location.capture 或 ngx.location.capture_multi 与 ngx_lua 模块完成调用

capture 自己的location 时，可传参数

    location = /redis {
        echo user_name $arg_user_name;
    }

    location = /capture {
        content_by_lua_block {
            local res = ngx.location.capture( "/redis", 
                { args = { user_name = "ahui" } }
            )
            if res then
                ngx.say("status: ", res.status) -- 200 ?
                ngx.say("body:")
                ngx.print(res.body)
                ngx.print(res.header) -- table
            end
        }
    }

其它可传参：

    method 
    body
    args GET args
    ctx 
        specify a Lua table to be the ngx.ctx table for the subrequest. 
    vars 
        specified Nginx variables in the subrequest 
    copy_all_vars 
        specify whether to copy over all the Nginx variable values of the current request to the subrequest in question. 
    share_all_vars 
        specify whether to share all the Nginx variables of the subrequest with the current (parent) request. 

## method

    res = ngx.location.capture(
        '/foo/bar',
        { method = ngx.HTTP_POST, body = 'hello, world' }
    )

## The args (GET)

    -- ngx.location.capture('/foo?a=1&b=3&c=%3a')
    ngx.location.capture('/foo?a=1',
        { args = { b = 3, c = ':' } }
    )

## vars(ngx.var)
ngx.var in subrequest will not affect the current (parent) request. 

    location /other {
        content_by_lua_block {
            ngx.say("dog = ", ngx.var.dog)
            ngx.say("cat = ", ngx.var.cat)
        }
    }

    location /lua {
        set $dog '';
        set $cat '';
        content_by_lua_block {
            res = ngx.location.capture("/other",
                { vars = { dog = "hello", cat = 32 }});

            ngx.print(res.body)
        }
    }

## copy_all_vars
    location /other {
        set $dog "$dog world";
        echo "$uri dog: $dog";
    }

    location /lua {
        set $dog 'hello';
        content_by_lua_block {
            res = ngx.location.capture("/other",
                { copy_all_vars = true });

            ngx.print(res.body)
            ngx.say(ngx.var.uri, ": ", ngx.var.dog)
        }
    }

## share_all_vars
> modifications of the Nginx variables in the subrequest will affect the current (parent) request. 

This option is set to false by default

    location /other {
        set $dog "$dog world";
        echo "$uri dog: $dog";
    }

    location /lua {
        set $dog 'hello';
        content_by_lua_block {
            res = ngx.location.capture("/other",
                { share_all_vars = true });
            ngx.print(res.body)
            ngx.say(ngx.var.uri, ": ", ngx.var.dog)
        }
    }

Accessing location /lua gives

    /other dog: hello world
    /lua: hello world

## ngx.ctx
共享同一个 ngx.ctx 表。

    location /sub {
        content_by_lua_block {
            ngx.ctx.foo = "bar";
        }
    }
    location /lua {
        content_by_lua_block {
            res = ngx.location.capture("/sub", { ctx = ngx.ctx })
            -- ctx = {}
            --res = ngx.location.capture("/sub", { ctx = ctx })
            ngx.say(ngx.ctx.foo);
        }
    }

## always_forward_body 
    when set to true, the current (parent) request's request body will be forwarded to the subrequest 
