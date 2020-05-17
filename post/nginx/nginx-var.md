---
title: nginx 的变量
date: 2020-05-17
private: true
---
# nginx 的变量
> 本笔记整理基于章亦春的教程: https://github.com/openresty/nginx-tutorials/


# 变量
使用规范是
1. 必须先创建变量(set 指令不仅可赋值，还创建全局变量)
2. 再使用变量

## 变量插值
echo 配置指令支持“变量插值”。不是所有指令都支持

    server {
        listen 8080;
        location /test {
            set $foo hello;
            echo "foo: $foo"; #变量插值
            echo "foo: ${foo}"; #变量插值
        }
    }

如果我们想通过 echo 指令直接输出含有“美元符”（$）的字符串:

    geo $dollar {
        default "$";
    }
    server {
        location /test {
            echo "This is a dollar sign: $dollar";
        }
    }

## 变量作用域
Nginx 变量一旦创建，其变量名的可见范围就是整个 Nginx 配置，跨越 server 配置块。

    server {
        listen 8080;

        location /foo {
            echo "foo = [$foo]";
        }

        location /bar {
            set $foo 32;
            echo "foo = [$foo]";
        }
    }

下面是在命令行上用 curl 工具访问这两个接口的结果：

    $ curl 'http://localhost:8080/foo'
    foo = []

    $ curl 'http://localhost:8080/bar'
    foo = [32]

    $ curl 'http://localhost:8080/foo'
    foo = []

从这个例子我们可以窥见:
1. set 副作用是创建了一个全局的变量`$foo`
1. 变量名的可见范围虽然是整个配置，但每个请求都有所有变量的独立副本

## 变量生命周期
变量副本的生命周期是请求独立的（主请求和子请求合起来算一个生命周期）

下列是变量生命周期的例子
1. echo_exec 配置指令，发起到 `location /bar` 的“内部跳转”(不同于301/302 “外部跳转”)
2. 内部跳转，当前正在处理的请求就还是原来那个，只是当前的 location 发生了变化，所以还是原来的那一套 Nginx 变量的容器副本`$a`。

e.g.

    server {
        listen 8080;

        location /foo {
            set $a hello;
            echo_exec /bar;
        }

        location /bar {
            echo "a = [$a]";
        }
    }

结果

    $ curl localhost:8080/foo
    a = [hello]

内部跳转有很多指令:

    echo_exec /bar;
    rewrite ^ /bar;

## 内建变量
### 内建变量 与自定义变量
1. builtin variables: 比如`$uri`
2. user variables

内建变量如

    $http_*     headers
    $cookie
        $cookie_<name>
    $args == $query_string  get args
        $arg_<name>
    $request_uri == $uri?$query_string;

### arg_var
$arg_name 不仅可以匹配 name 参数，也可以匹配 NAME 参数，抑或是 Name，等等：

    $ curl 'http://localhost:8080/test?NAME=Marry'
    name: Marry

 ngx_set_misc 模块的 set_unescape_uri 配置指令可解码：

    set_unescape_uri $name $arg_name;

### 变量只读
许多内建变量都是只读的，比如:

    $arg_XXX
    `$uri 和 $request_uri` 

这个配置是错误的：

    location /bad {
        set $uri /blah;
        echo $uri;
    }
    // 启动时
    [emerg] the duplicate "uri" variable in ...

### 变量可写
也有一些内建变量是支持改写的, 如

    $args

    location /test {
        set $args "a=3&b=4";
        echo "args: $args";
        echo "arg_a: $arg_a";
    }

改写会影响`$arg_a`

    $ curl 'http://localhost:8080/test?a=0&b=1&c=2'
    args: a=3&b=4
    arg_a: 3

我们再来看一个通过修改 $args 变量影响标准的 HTTP 代理模块 ngx_proxy 的例子：

    server {
        listen 8080;

        location /test {
            set $args "foo=1&bar=2";
            proxy_pass http://127.0.0.1:8081/args;
        }
    }
    server {
        listen 8081;

        location /args {
            echo "args: $args";
        }
    }

## 变量set/get handler 与缓存
按是否存值，变量分变两种
1. 拥有值容器的变量在 Nginx 核心中被称为“被索引的”（indexed）；
2. 反之，则被称为“未索引的”（non-indexed）。

比如`$arg_XXX`并不实际存储值 我们读取 `$arg_XXX`时，是通过`get handler` 读的。


### get handler
在设置了“取处理程序(get handler)”的情况下，Nginx 变量也可以选择将其值容器用作缓存，这样在多次读取变量的时候，就只需要调用“取处理程序”计算一次。

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
            set $args debug1;
            echo "foo: $foo";
        }
    }

上面的map 相当于`$foo = map[$args or default]`, 相当于为foo建立了get handler 

    $ curl 'http://localhost:8080/test' # default 是默认值
    original foo: 0
    foo: 0

    $ curl 'http://localhost:8080/test?debug'
    original foo: 1
    foo: 1

为什么foo会出现0？这个结果的原因是, 这个get hadnler 第一次读取执行并缓存
1. 第一次read `set $orig_foo $foo`时，取值为0
1. 第二次read $foo时，取缓存值0

> 类似 ngx_map 模块，标准的 ngx_geo 等模块也一样使用了变量值的缓存机制。

### 变量缓存
    自定义变量在使用get handler 第二次访问时，是有缓存的(如上例中的foo)
    $arg_name 访问时，并不会使用值容器进行缓存

支持值缓存的内建变量很少, 包括

    $request_uri
    $request_method

# 子请求subrequest间的变量
内部跳转的请求就是subrequest

    echo_exec /bar; # 跳出
    rewrite ^ /bar; # 跳出
    echo_location /bar;# 跳出再跳回

下面就来看一个使用了“子请求”的例子：

    location /main {
        echo_location /foo;
        echo_location /bar;
    }

    location /foo {
        echo foo;
    }

    location /bar {
        echo bar;
    }

output

    $ curl 'http://localhost:8080/main'
    foo
    bar

子请求间的变量副本是独立的

    location /main {
        set $var main;
        echo_location /foo;
        echo "main: $var";
    }

    location /foo {
        set $var foo;
        echo "foo: $var";
    }

    $ curl 'http://localhost:8080/main'
    foo: foo
    main: main

不幸的是，一些 Nginx 模块发起的“子请求”却会自动共享其“父请求”的变量值容器，比如第三方模块 ngx_auth_request. 下面是一个例子：

    location /main {
        set $var main;
        auth_request /sub;
        echo "main: $var";
    }

    location /sub {
        set $var sub;
       echo "sub: $var";
    }
    $ curl 'http://localhost:8080/main'
    main: sub

Note: 为什么‘子请求’ /sub 的输出没有出现在最终的输出里呢？因为auth_request 指令会自动忽略“子请求”的响应体，而只检查“子请求”的响应状态码。
1. 当状态码是 2XX 的时候，auth_request 指令会忽略“子请求”而让 Nginx 继续处理当前的请求，
2. 否则它就会立即中断当前（主）请求的执行，返回相应的出错页。

## 子请求与内置变量
大部分内置变量如`$args/$uri` 会随着子请求变化

    location /main {
        echo "main args: $args";
        echo_location /sub "a=1&b=2";
        echo "main args: $args";
    }

    location /sub {
        echo "sub args: $args";
    }

    $ curl 'http://localhost:8080/main?c=3'
    main args: c=3
    sub args: a=1&b=2
    main args: c=3

少数内建变量只作用于“主请求”:比如`$request_uri,$request_method` 

    location /main {
        echo "main method: $request_method";
        echo_location /sub;
    }

    location /sub {
        echo "sub method: $request_method";
    }

    $ curl --data hello 'http://localhost:8080/main'
    main method: POST
    sub method: POST

我们需要求助于第三方模块 ngx_echo 提供的内建变量 $echo_request_method：

    location /main {
        echo "main method: $echo_request_method";
        echo_location /sub;
    }

    location /sub {
        echo "sub method: $echo_request_method";
    }
    $ curl --data hello 'http://localhost:8080/main'
    main method: POST
    sub method: GET

Nginx 变量漫谈（七）
幸运的是，通过第三方模块 ngx_lua，我们可以轻松地在 Lua 代码中做到这一点。请看下面这个例子：

    location /test {
        content_by_lua '
            if ngx.var.arg_name == nil then
                ngx.say("name: missing")
            else
                ngx.say("name: [", ngx.var.arg_name, "]")
            end
        ';
    }
    $ curl 'http://localhost:8080/test'
    name: missing

要解决这些局限，可以直接在 Lua 代码中使用 ngx_lua 模块提供的 ngx.req.get_uri_args()

# 变量数组
像 ngx_array_var 这样的第三方模块让 Nginx 变量也能存放数组类型的值。

    location /test {
        array_split "," $arg_names to=$array;
        array_map "[$array_it]" $array;
        array_join " " $array to=$res;

        echo $res;
    }

    $ curl 'http://localhost:8080/test?names=Tom,Jim,Bob'
    [Tom] [Jim] [Bob]