---
title: nginx/openresty 与权限网关分享
date: 2020-06-08
private: true
---
# nginx/openresty 与权限网关分享
目录
- 权限网关: 网关设计、代码实现
- nginx 变量: 内建变量、变量容器、变量生命周期、缓存
- nginx 指令：常用指令、生命周期、子请求
- nginx 调试：5xx 错误、日志、调试
---

# nginx/openresty介绍
1. nginx 提供反射代理、4/7层负载均衡、http-server功能
2. OpenResty是以Nginx为核心的Web开发平台，主要为nginx提供执行Lua的模块支持
![](/img/openresty/lua-api.png)
---
## 一种权限网关时序图设计
![img](/img/resty/auth-arch.png)
---
## nginx变量-内建变量
比如：

    $http_*     headers
    $cookie
        $cookie_<name>
    $args == $query_string  get args
        $arg_<name>
    $request_uri == $uri?$query_string;

---
## nginx变量-内建变量
大多数内建变量只能读，只有少数可写, 比如下面的$args

    location /test {
        set $args "a=3&b=4";
        echo "args: $args";
        echo "arg_a: $arg_a";
    }

改写`$args `会影响`$arg_x` 吗？
---
## nginx变量-内建变量

    location /test {
        set $args "a=3&b=4";
        echo "args: $args";
        echo "arg_a: $arg_a";
    }

改写`$args `会影响`$arg_x` 吗？

    $ curl 'http://localhost:8080/test?a=0&b=1&c=2'
    args: a=3&b=4
    arg_a: 3

---
### 变量生命周期
变量生命期是就是整个请求周期：

    location /foo {
        set $a hello;
        echo_exec /bar;
    }

    location /bar {
        echo "a = [$a]";
    }

---
### 变量容器
按变量是否存值，变量可分变两种
1. 拥有值容器的变量在 Nginx 核心中被称为“被索引的”（indexed）:如`$args`
2. 反之，则被称为“未索引的”（non-indexed）, 如`$arg_XXX`。

比如`$arg_XXX`并不实际存储值 我们读取 `$arg_XXX`时，是通过`get handler` 读的。

---
## 变量缓存
下列中foo 变量第一次被读取时会被缓存

    map $args $foo {
        default     0;
        debug       1;
    }
    server {
        listen 8080;

        location /test {
            set $orig_foo $foo;
            set $args debug;

            echo "original foo: $orig_foo";
            echo "foo: $foo";
        }
    }

---
## 变量缓存-测试一下
前面的例子中map 相当于`$foo = map[$args or default]`, 相当于为foo建立了get handler 

    $ curl 'http://localhost:8080/test' # default 是默认值
    original foo: 0
    foo: 0

    $ curl 'http://localhost:8080/test?debug'
    original foo: 1
    foo: 1

第一个结果全是0的原因是：
1. 第一次read `set $orig_foo $foo`时，取值为0
1. 第二次read $foo时，取`缓存`值0

---
## nginx指令生命周期与模块
猜一下结果：

    server {
        listen 8080;
        location /{
            set $a 32;
            echo $a;

            set $a 56;
            echo $a;
        }
    }
---
## nginx指令生命周期与模块
指令的生命周期按照执行顺序依次是

    post-read、server-rewrite、find-config、rewrite、post-rewrite、
    preaccess、access、post-access、try-files、content、log.

有很多模块提供各种生命周期的指令:

    set_misc, rewrite_by_lua, rewrite, allow/deny, access_by_lua, proxy_pass,  echo等模块

---
## nginx指令生命周期与模块
![](img/openresty/lua-api.png)
---
### find-config(location)
location 就是属于这个find-config 阶段
一个典型的conf:

    rewrite ^/v1/(.*) "/v2$1";

    location / {
        rewrite ^/v2/(.*) "/v3$1";
        proxy_pass http://127.0.0.1:5002/v2/;
    }
    location /v3 {
        proxy_pass http://127.0.0.1:5002/v3/;
    }

	location ~ "\.(png|js|jpg|css|jpeg|gif)$" {
		#mathes any static files
	}

---
### find-config(location)
location 优先级顺序：

    第一优先级：等号类型（=）的优先级最高。
    第二优先级：^~类型表达式
    第三优先级：正则表达式类型（~ ~*）的优先级次之。
        如果有多个location的正则的话，先定义的优先
    第四优先级：常规字符串匹配类型。
        按前缀匹配+长普通字符匹配优先

location 优先级顺序：

	location ~ "\.(png|js|jpg|css|jpeg|gif)$" {
		#mathes any static files
    }
	location = /favicon.ico {
		#first
    }

---
### find-config(location)
location 匹配规则:

	= /path #进行普通字符精确匹配
            相当于 $uri == "/path"
	^~ /path   #表示普通字符前缀匹配，
            相当于 $uri.startsWith("/path")
	~ "\.png$" #波浪线表示执行一个正则匹配，区分大小写
            相当于 reg.match($uri, /\.png$/)
        ~*    大小写不敏感匹配
        !~    大小写敏感不匹配(!~) 
        !~*   大小写不敏感不匹配(!~*)
    /     常规字符串匹配(前缀匹配)
         location /
	@     #"@" 定义一个命名的 location，使用在内部定向时，例如 error_page, try_files

---
### rewrite 生命期: set指令
set:

    location /test {
        set $value dog;
        more_set_input_headers "X-Species: $value";
        set $value cat;
    
        echo "X-Species: $http_x_species";
    }

    $ curl 'http://localhost:8080/test'
    X-Species: cat

---
### rewrite 生命期: rewrite 指令
rewirte:

    location ~ "/aa"{
        rewrite /aa(.*) /proxy/$1?q=a  ;
    }
    location ~ "/proxy/(.*)"{
        echo "proxy/$1";
        echo $scheme://$http_host$request_uri?$query_string;
    }

---
### rewrite 对变量的影响
是否改写变量，是由指令的本身决定的. 就rewrite 而言，它会影响到
- rewrite 会影响大多数URI变量: `$uri, $fastcgi_script_name, ....`
- 少数变量不受影响:`$request_uri,$request_method` 
- rewrite 会追加 `$query_string` 

---
### access 生命期
access 的指令有许多：

    deny/allow
    access_by_lua
    ...

example:

    location /hello {
        access_by_lua '
            if ngx.var.remote_addr == "127.0.0.1" then
                return
            end
            ngx.exit(403)
        ';
        echo "hello world";
    }

---
### content生命期
运行在这个阶段的指令有

    echo
    echo_exec
    echo_location
    content_by_lua
    proxy_pass
    ...

有些指令可出现多次, 如echo. \   
有些指令只能出现一次, 如`proxy_pass、contnet_lua`. 

别外，哪些指令的contnet 会输出是不确定的

    location /test {
        echo word1;
        echo word2;
        proxy_pass http://up1;
        proxy_pass http://up2;
    }
---
## nginx的子请求

不同于301/302, 内部跳转的请求就是subrequest

    echo_exec /bar; # 跳出
    rewrite ^ /bar; # 跳出
    echo_location /bar;# 跳出再跳回

子请求的例子：

    location /lua {
        set $dog 'hello';
        content_by_lua_block {
            res = ngx.location.capture("/other",
                { share_all_vars = true });
            ngx.print(res.body)
            ngx.say(ngx.var.uri, ": ", ngx.var.dog)
        }
    }

--- 
## nginx/openresty的5xx错误与调试
1.常见的nginx 500错误
1.怎么去找配置nginx.conf
1.怎么测试变量？
2.怎么输出日志?

---
### nginx 5xx 错误系列
### 500
`NGX_HTTP_INTERNAL_SERVER_ERROR`

常见于：golang/php/python 等http service 因语法、异常、panic等错误导致服务挂了

### 501
NGX_HTTP_NOT_IMPLEMENTED

经常见于：nginx的`transfer-encoding`现在只支持chunked,如果客户端随意设置这个值,会报501
 
    $ curl localhost:8070  -H 'Transfer-Encoding:1'
    501 Not Implemented

---
### 502
NGX_HTTP_BAD_GATEWAY

比如nginx配置为

    fastcgi_pass 127.0.0.1:8000;

然后指向一个未监听的端口, 就会报502

    curl localhost:8070/index.php -I
    HTTP/1.1 502 Bad Gateway
    ...

---
### 503
NGX_HTTP_SERVICE_UNAVAILABLE
修改nginx配置,限速为每分钟10个请求
 
    limit_req_zone $binary_remote_addr zone=one:10m rate=10r/m;
    limit_req zone=one;

连续发送两个请求，第二请求会报503

    curl localhost:8070/index.php -I
    HTTP/1.1 503 Service Temporarily Unavailable

### 504
NGX_HTTP_GATEWAY_TIME_OUT

---
## nginx调试: 查看日志、配置
查找nginx.conf 配置

    ps aux|grep nginx.conf
    nginx -V|grep nginx.conf

日志配置示例：

    http {
        #设定日志格式
        log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                '$status $body_bytes_sent "$http_referer" '
                '"$http_user_agent" "$http_x_forwarded_for"';
        access_log  logs/access.log  main;
        # error_log /var/log/nginx-error.log info;
        error_log  /dir/error.log  main;
    }

查error_log 位置...?

    lsof -p pid|grep error.log

---
## nginx调试: 探测变量
如果nginx 默认没有带echo 等模块，怎么探测变量值呢? 

可以通过rewrite 跳转控测

    rewrite ^/  "https://google.com/q=a&query_string=$query_string" last;

也可以通过将变量 拼接为的不存在路径，然后在错误日志中观察

    location /{
        rewrite ^/  "https://google.com/q=a&query_string=$query_string" break;
    }

如果nginx 编译了echo moudle, 则可以直接用echo 控测

    location /{
        echo The current request uri is $request_uri; //http body response. 类似ngx.say
    }

