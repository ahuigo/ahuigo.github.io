---
title: nginx directive
date: 2020-05-17
private: true
---
# nginx directive
> 本笔记整理基于章亦春的教程: https://github.com/openresty/nginx-tutorials/
## debug 日志
为了方便观察命令执行，建议打开 Nginx 的“调试日志”（debug log）来一窥 Nginx 的实际执行过程。

    tar xvf nginx-1.0.10.tar.gz
    cd nginx-1.0.10/
    ./configure --with-debug
     # ./configure --prefix=/usr/local/opt/openresty --with-http_iconv_module  --with-http_postgres_module --with-debug
    make
    sudu make install

如果你使用的是春哥维护的 ngx_openresty 软件包，则同样可以向它的 `./configure --with-debug `命令行选项。

然后配置nginx.conf

    error_log logs/error.log debug;

## set vs echo 顺序
    server {
        listen 8080;
        location /{
            set $a 32;
            echo $a;

            set $a 56;
            echo $a;
        }
    }

实际的执行顺序应当是

    set $a 32;
    set $a 56;
    echo $a;
    echo $a;

现在可以检查一下前面配置的 Nginx 错误日志文件中的输出。

    grep -E 'http (output filter|script (set|value))' logs/error.log
    [debug] 5363#0: *1 http script value: "32"
    [debug] 5363#0: *1 http script set $a
    [debug] 5363#0: *1 http script value: "56"
    [debug] 5363#0: *1 http script set $a
    [debug] 5363#0: *1 http output filter "/test?"
    [debug] 5363#0: *1 http output filter "/test?"
    [debug] 5363#0: *1 http output filter "/test?"

这里需要稍微解释一下这些调试信息的具体含义。 set 配置指令在实际运行时会打印出两行以 http script 起始的调试信息，其中第一行信息是 set 语句中被赋予的值，而第二行则是 set 语句中被赋值的 Nginx 变量名。于是上面首先过滤出来的

    [debug] 5363#0: *1 http script value: "32"
    [debug] 5363#0: *1 http script set $a

这两行就对应我们例子中的配置语句

    set $a 32;

此外，凡在 Nginx 中输出响应体数据时，都会调用 Nginx 的所谓“输出过滤器”（output filter），我们一直在使用的 echo 指令自然也不例外。而一旦调用 Nginx 的“输出过滤器”，便会产生类似下面这样的调试信息：

    [debug] 5363#0: *1 http output filter "/test?"

为什么这个例子明明只使用了两条 echo 语句进行输出，但却有三行 http output filter 调试信息呢？其实，前两行 http output filter 信息确实分别对应那两条 echo 语句，而最后那一行信息则是对应 ngx_echo 模块输出指示响应体末尾的结束标记。

## 指令执行要经过 11 个阶段
按照执行顺序依次是 

    post-read、server-rewrite、find-config、rewrite、post-rewrite、preaccess、access、post-access、try-files、content 以及 log.

Nginx 的 rewrite 阶段的配置指令一般用来:
1. 对当前请求进行各种修改（比如对 URI 和 URL 参数进行改写），
2. 或者创建并初始化 Nginx 变量。

在 rewrite 阶段之后，有一个名叫 access 的请求处理阶段。
1. ngx_auth_request 的指令就运行在 access 阶段。
2. 多是执行访问控制性质的任务，比如检查用户的访问权限，检查用户的来源 IP 地址是否合法，

content 阶段
1. 主要是输出内容, 例如 echo 指令的文档： `phase: content` 显示其指令在cotent 中执行

## rewrite 阶段
 ngx_set_misc 模块的指令可与rewrite 放一起顺序执行

    set
    set_unescape_uri 
    rewrite
    set_by_lua

e.g.

    location /test {
        set $a "hello%20world";
        set_unescape_uri $b $a;
        set $c "$b!";

        echo $c;
    }

访问这个接口可以得到：

    $ curl 'http://localhost:8080/test'
    hello world!
    $ grep -E 'http script (value|copy|set)' t/servroot/logs/error.log
    [debug] 11167#0: *1 http script value: "hello%20world"
    [debug] 11167#0: *1 http script set $a
    [debug] 11167#0: *1 http script value (post filter): "hello world"
    [debug] 11167#0: *1 http script set $b
    [debug] 11167#0: *1 http script copy: "!"
    [debug] 11167#0: *1 http script set $c

下面我们就来看一个 set_by_lua 指令与 set 指令混合使用的例子：

    location /test {
        set $a 32;
        set $b 56;
        set_by_lua $c "return ngx.var.a + ngx.var.b";
        set $equation "$a + $b = $c";

        echo $equation;
    }

    # 这个例子的实际运行结果符合我们的期望：
    $ curl 'http://localhost:8080/test'
    32 + 56 = 88

还有不少第三方模块， ngx_array_var 以及后面即将接触到的用于加解密用户会话（session）的 ngx_encrypted_session，也都可以和 ngx_rewrite 模块的指令无缝混合工作。

### rewrite 独立运行的指令
上面提到的这些第三方模块都采用了特殊的技术，将它们自己的配置指令“注入”到了 ngx_rewrite 模块的指令序列中（它们都借助了 Marcus Clyne 编写的第三方模块 ngx_devel_kit）。

大多数Nginx 的 rewrite 阶段注册和运行指令的第三方模块就没那么幸运了：
1. 其配置指令和 ngx_rewrite 模块（以及同一阶段内的其他模块）都是分开独立执行的。
2. 执行顺序是不确定的

比如， 第三方模块 ngx_headers_more 提供了一条名叫 more_set_input_headers 的指令可以在 rewrite 阶段改写指定的请求头

    phase: rewrite tail
    其中的 rewrite tail 的意思就是 rewrite 阶段的末尾。

既然运行在 rewrite 阶段的末尾，那么也就总是会运行在 ngx_rewrite 模块的指令之后:

    location /test {
        set $value dog;
        more_set_input_headers "X-Species: $value";
        set $value cat;
    
        echo "X-Species: $http_x_species";
    }

    $ curl 'http://localhost:8080/test'
    X-Species: cat

上面这个例子证明了即使运行在同一个请求处理阶段，分属不同模块的配置指令也可能会分开独立运行(内部子阶段)（除非像 ngx_set_misc 等模块那样针对 ngx_rewrite 模块提供特殊支持）。

rewrite_by_lua 配置指令也和 more_set_input_headers 一样运行在 rewrite 阶段的末尾。我们来验证一下：

    location /test {
        set $a 1;
        rewrite_by_lua "ngx.var.a = ngx.var.a + 1";
        set $a 56;
    
        echo $a;
    }
    $ curl 'http://localhost:8080/test'
    57

既然 `more_set_input_headers 和 rewrite_by_lua` 指令都运行在 rewrite 阶段的末尾，那么它们之间的先后顺序又是怎样的呢？答案是：不一定。

## access

### allow/deny
下面 /hello 接口:
1. 被配置为只允许从本机（IP 地址为保留的 127.0.0.1）访问
2. ngx_access 模块自己的多条配置指令之间是按顺序执行的，直到遇到第一条满足条件的指令就不再执行后续的 allow 和 deny 指令。
3. 如果deny(相当于ngx.exit(403)), 后续所有指令被终止（返回 403 错误页）。 

config:

    location /hello {
        allow 127.0.0.1;
        deny all;
        echo "hello world";
    }

值得一提的是， ngx_access 模块还支持所谓的“CIDR 记法”来表示一个网段，例如:

     allow 169.200.179.4/24 

### access_by_lua
set_by_lua_file 运行于 access 阶段的末尾(在 allow 和 deny 这样的指令之后运行)

    location /hello {
        access_by_lua '
            if ngx.var.remote_addr == "127.0.0.1" then
                return
            end
            ngx.exit(403)
        ';
        echo "hello world";
    }

这个例子在功能上完全等价于先前在 （三） 中介绍过的那个使用 ngx_access 模块的例子：

    location /hello {
        allow 127.0.0.1;
        deny all;
        echo "hello world";
    }

下面我们不妨来实际测量一下这两个例子的性能差别。

首先，在 Mac OS X 系统中打开一个命令行终端，在某一个文件目录下面创建一个名为 nginx-access-time.d 的文件，并编辑内容如下：

    #!/usr/bin/env dtrace -s

    pid$1::ngx_http_handler:entry
    {
        elapsed = 0;
    }

    pid$1::ngx_http_core_access_phase:entry
    {
        begin = timestamp;
    }

    pid$1::ngx_http_core_access_phase:return
    /begin > 0/
    {
        elapsed += timestamp - begin;
        begin = 0;
    }

    pid$1::ngx_http_finalize_request:return
    /elapsed > 0/
    {
        @elapsed = avg(elapsed);
        elapsed = 0;
    }

保存好此文件后，再赋予它可执行权限：

    $ chmod +x ./nginx-access-time.d

这个脚本接受一个命令行参数用于指定监视的 Nginx worker 进程的进程号（pid）。为了确保所有测试请求都为固定的 worker 进程处理

    worker_processes 1;

重启 Nginx 服务器之后，可以利用 ps 命令得到当前 worker 进程的进程号：

    $ ps ax|grep nginx|grep worker|grep work|grep -v grep
    10975   ??  S      0:34.28 nginx: worker process

运行 nginx-access-time.d 脚本：

    $ sudo ./nginx-access-time.d 10975

然后输出会说，我们的 D 脚本已成功向目标进程动态植入了 4 个 dtrace “探针”（probe）。紧接着这个脚本就挂起了，表明 dtrace 工具正在对进程 10975 进行持续监视。

    dtrace: script './nginx-access-time.d' matched 4 probes

然后我们再打开一个新终端，在那里使用 curl 这样的工具多次请求我们正在监视的接口

    $ curl 'http://localhost:8080/hello'
    hello world

    $ curl 'http://localhost:8080/hello'
    hello world

最后我们回到原先那个一直在运行 D 脚本的终端，按下 Ctrl-C 组合键中止 dtrace 的运行。而该脚本在退出时会向终端打印出最终统计结果。例如我的终端此时是这个样子的：

    $ sudo ./nginx-access-time.d 10975
    dtrace: script './nginx-access-time.d' matched 4 probes
    ^C
           19219

最后一行输出 19219 便是那几次 curl 请求在 access 阶段的平均用时（以纳秒，即 10 的负 9 次方秒为单位）。

ab 这样的批量测试工具来取代 curl 发起连续十万次以上的请求，例如

    $ ab -k -c1 -n100000 'http://127.0.0.1:8080/hello'

在我的苹果系统上，完成3种测试结果如下(春哥的mac测试)：

    ngx_access 组               18146
    access_by_lua 组            35011
    空白对照组                   15887

把前两组的结果分别减去“空白对照组”的结果可以得到

    ngx_access 组               2259
    access_by_lua 组           19124

可以看到， ngx_access 组比 access_by_lua 组快了大约一个数量级

> 上面换用 $binary_remote_addr 内建变量比较更快一点
> 测试时要关闭debug日志

## content 阶段
运行在这个阶段。

    echo
    echo_exec
    echo_location
    content_by_lua
    proxy_pass
    ...

与rewrite/access不同， 由于content 阶段注册配置指令时，本质是向location 注册content hander(只能是一个). 
所以只有一个content 模块生效(哪个生效是不确定的)

    ? location /test {
    ?     echo hello;
    ?     content_by_lua 'ngx.say("world")';
    ? }

    # 实际运行结果表明，写在后面的 content_by_lua运行了, echo 指令则完全没有运行。
    $ curl 'http://localhost:8080/test'
    world

echo指令都支持在同一个 location 中被使用多次, 但content_by_lua 不可以

    ? location /test {
    ?     content_by_lua 'ngx.say("hello")';
    ?     content_by_lua 'ngx.say("world")';
    ? }

    正确的写法应当是：
    location /test {
        content_by_lua 'ngx.say("hello") ngx.say("world")';
    }

proxy_pass 与 echo 之间，只有pass生效

    ? location /test {
    ?     echo "before...";
    ?     proxy_pass http://127.0.0.1:8080/foo;
    ?     echo "after...";
    ? }
    ?
    ? location /foo {
    ?     echo "contents to be proxied";
    ? }

    $ curl 'http://localhost:8080/test'
    contents to be proxied

需要改用 ngx_echo 模块提供的 echo_before_body 和 echo_after_body 这两条配置指令：

    location /test {
        echo_before_body "before...";
        proxy_pass http://127.0.0.1:8080/foo;
        echo_after_body "after...";
    }

配置指令 echo_before_body 和 echo_after_body 之所以可以和其他模块运行在 content 阶段的指令一起工作，是因为
1. 它们运行在 Nginx 的“输出过滤器”中。
2. “输出过滤器”并不属 11 个请求处理阶段, 许多阶段都可以调用“输出过滤器”

echo_before_body 和 echo_after_body 指令在文档中标记下面这一行：

    phase: output filter (运行在“输出过滤器”这个特殊的阶段。)

### content 默认的content handler
Nginx 一般会在 content 阶段安排三个这样的静态资源服务模块。按照它们在 content 阶段的运行顺序，依次是 
1. ngx_index 模块， 
    1. 只会作用于那些 URI 以 / 结尾的请求，例如请求 GET /cats/
2. ngx_autoindex 模块: 目录索引
    1. 只会作用于那些 URI 以 / 结尾的请求，例如请求 GET /cats/
3. 以及 ngx_static 模块。
    1. 直接忽略那些 URI 以 / 结尾的请求。

#### index
ngx_index 模块主要用于在文件系统目录中自动查找指定的首页文件，类似 index.html 和 index.htm 这样的，例如：

    location / {
        root /var/www/;
        index index.htm index.html;
    }

当用户请求 / 地址时，Nginx 就会自动在 root 配置指令指定的文件系统目录下依次寻找 index.htm 和 index.html 这两个文件。
1. 如果 index.htm 文件存在，则直接发起“内部跳转”到 /index.htm 这个新的地址；
2. 否则继续检查 index.html 是否存在。如果存在，同样发起“内部跳转”到 /index.html；
3. index.html 文件仍然不存在，则放弃处理权给 content 阶段的下一个模块。

为了进一步确认 ngx_index 模块在找到文件时的“内部跳转”行为，我们不妨设计下面这个小例子：

    location / {
        root /var/www/;
        index index.html;
    }

    location /index.html {
        set $a 32;
        echo "a = $a";
    }

此时我们在本机的 /var/www/ 目录下创建一个空白的 index.html 文件（有读权限）

    $ curl 'http://localhost:8080/'
    a = 32

#### autoindex
如果此时把 /var/www/index.html 文件删除，再访问 / 又会发生:

    [error] 28789#0: *1 directory index of "/var/www/" is forbidden

所谓 directory index 便是生成“目录索引”的意思

    location / {
        root /var/www/;
        index index.html;
        autoindex on; # 显示目录树
    }

此时仍然保持文件系统中的 /var/www/index.html 文件不存在。我们再访问 / 位置时，就会得到一张漂亮的目录树

#### static 模块
“垫底”的最后一个模块便是极为常用的 ngx_static 模块(`$uri`不能以`/`结尾), 用于显示js/css/pic/html 静态资源

    location / {
        root /var/www/;
    }
    # 将请求 /index.html映射/var/www/index.html 
    $ curl 'http://localhost:8080/index.html'
    this is my home

Nginx “调试日志”，然后再次请求 /index.html 这个接口时显示

    [debug] 3033#0: *1 http static fd: 8

如果没有配置 root 指令，缺省的“文档根目录”是（configure prefix）路径下的 html/ 子目录。

    # 假设“configure prefix”是 /foo/bar/，则缺省的root便是 /foo/bar/html/.
    location / { }

指定configure prefix

    nginx -p /foo/bar

## post-read
标准模块 ngx_realip 就在 post-read 阶段注册了处理程序，它的功能是迫使 Nginx 认为当前请求的来源地址是指定的某一个请求头的值。

    server {
        listen 8080;

        set_real_ip_from 127.0.0.1;
        real_ip_header   X-My-IP;

        location /test {
            set $addr $remote_addr;
            echo "from: $addr";
        }
    }

这里的配置是让 Nginx 把那些`来自 127.0.0.1` 的所有请求的来源地址，都改写`$remote_addr`为请求头 X-My-IP 所指定的值。

    $ curl -H 'X-My-IP: 1.2.3.4' localhost:8080/test
    from: 1.2.3.4

如果没有或者提供的 X-My-IP 请求头的值不是合法的 IP 地址，那么 Nginx 就不会对来源地址进行改写，例如：

    $ curl -H 'X-My-IP: abc' localhost:8080/test
    from: 127.0.0.1

 set_real_ip_from 支持“CIDR 记法”，以及多个

    set_real_ip_from 10.32.10.5;
    set_real_ip_from 127.0.0.0/24;

为什么我们需要去改写请求的来源地址呢？答案是代理转发需要:
1. 当原始的用户请求经过转发之后，Nginx 接收到的请求的来源地址无一例外地变成了该代理服务器的 IP 地址，
2. 一般代理服务器中把请求的原始来源地址编码进某个特殊的 HTTP 请求头中（例如上例中的 X-My-IP 请求头），
3. 然后再在 Nginx 一侧把这个请求头中编码的地址恢复出来。

## server-rewrite
post-read 阶段之后便是 server-rewrite 阶段。

    server {
        listen 8080;

        location /test {
            set $b "$a, world";
            echo $b;
        }

        set $a hello;
    }

location 配置块中的语句晚于server-rewrite:

    $ curl localhost:8080/test
    hello, world

## find-config
紧接在 server-rewrite 阶段后边的是 find-config 阶段。这个阶段并不支持 Nginx 模块注册处理程序，而是由location 配置块之间的配对工作。

> 在此阶段之前，请求并没有与任何 location 相关联。这就是为什么只有写在 server 配置块中指令才会运行在 server-rewrite 阶段，


    location /hello {
        echo "hello world";
    }

当 Nginx 在 find-config 阶段成功匹配了一个 location 配置块后:

    $ grep 'using config' logs/error.log
    [debug] 84579#0: *1 using configuration "/hello"

运行在 find-config 阶段之后的便是我们的老朋友 rewrite 阶段。

## post-rewrite 阶段
rewrite 阶段再往后便是所谓的 post-rewrite 阶段。
该阶段完成 rewrite 指令所要求的“内部跳转”操作

    server {
        listen 8080;
        location /foo {
            set $a hello;
            rewrite ^ /bar; # 指示post-rewrite 要内部跳转
        }
        location /bar {
            echo "a = [$a]";
        }
    }

“内部跳转”本质上其实就是把当前的请求处理阶段强行倒退到 find-config 阶段，以便重新进行请求 URI 与 location 配置块的配对。

为什么不直接在 rewrite 指令执行时立即进行跳转呢？是为了在最初匹配的 location 块中支持多次反复地改写 URI，例如：

    location /foo {
        rewrite ^ /bar;
        rewrite ^ /baz; # 这里的内部跳转才生效, 只有一次

        echo foo;
    }

如果在 server 中使用 rewrite 配置指令，则不会涉及“内部跳转”，因为server-rewrite 阶段，早于 find-config 阶段。

    server {
        listen 8080;
        rewrite ^/foo /bar;
        location /foo { } 
        location /bar { }
    }

## preaccess 阶段
运行在 post-rewrite 阶段之后的是所谓的 preaccess 阶段。该阶段在 access 阶段之前执行

标准模块 ngx_limit_req 和 ngx_limit_zone 就运行在此阶段，前者可以控制请求的访问频度，而后者可以限制访问的并发度。

前面反复提到的标准模块 ngx_realip 其实也在这个阶段注册了处理程序。

    server {
        listen 8080;
        location /test {
            set_real_ip_from 127.0.0.1;
            real_ip_header X-Real-IP;

            echo "from: $remote_addr";
        }
    }

与先看前到的例子相比，此例最重要的区别在于把 ngx_realip 的配置指令放在了 location 配置块中。
1. post-read 阶段执行在location(find-config) 之前
2. 为了方便location 相关联后，再修改realip

不幸的是， ngx_realip 模块的这个解决方案还是存在漏洞的，比如下面这个例子：

    server {
        listen 8080;

        location /test {
            set_real_ip_from 127.0.0.1;
            real_ip_header X-Real-IP;

            set $addr $remote_addr; #rewrite早于post-rewrite/pre-access
            echo "from: $addr";
        }
    }
    $ curl -H 'X-Real-IP: 1.2.3.4' localhost:8080/test
    from: 127.0.0.1

输出的地址确实是未经改写过的。Nginx 的“调试日志”可以进一步确认这一点：

    $ grep -E 'http script (var|set)|realip' logs/error.log
    [debug] 32488#0: *1 http script var: "127.0.0.1"
    [debug] 32488#0: *1 http script set $addr
    [debug] 32488#0: *1 realip: "1.2.3.4"
    [debug] 32488#0: *1 realip: 0100007F FFFFFFFF 0100007F
    [debug] 32488#0: *1 http script var: "127.0.0.1"

运行在 preaccess 阶段之后的则是access 阶段。

## post-access
post-access 阶段主要用于配合 access 阶段实现标准, ngx_http_core 模块提供的配置指令 satisfy 的功能。

satisfy 配置指令可以用于控制它们彼此之间的协作方式。 比如模块 A 和 B 都在 access 阶段注册了与访问控制相关的处理程序，那就有两种协作方式，
1. 一是模块 A 和模块 B 都得通过验证才算通过，(all 方式)
2. 二是模块 A 和模块 B 只要其中任一个通过验证就算通过。

默认情况下，Nginx 使用的是 all 方式。下面是一个例子：

    location /test {
        satisfy all;

        deny all;
        access_by_lua 'ngx.exit(ngx.OK)';

        echo something important;
    }

这里，我们在 /test 接口中同时配置了 ngx_access 模块和 ngx_lua 模块，这样 access 阶段就由这两个模块一起来做检验工作。
1. 语句 deny all 会让 ngx_access 模块的处理程序总是拒绝当前请求，
2. 而语句 access_by_lua 'ngx.exit(ngx.OK)' 则总是允许访问。

当我们通过 satisfy 指令配置了 all 方式时，就需要 access 阶段的所有模块都通过验证，本例未通过

    $ curl localhost:8080/test
    <html>
    <head><title>403 Forbidden</title></head>
    <body bgcolor="white">

当我们通过 satisfy 指令配置了 any 方式时，只需要 access 阶段的任意模块都通过验证

    location /test {
        satisfy any;

        deny all;
        access_by_lua 'ngx.exit(ngx.OK)';

        echo something important;
    }

    $ curl localhost:8080/test
    something important

## try-files 阶段
紧跟在 post-access 阶段之后的是 try-files 阶段。

来看看下面这个例子：

    root /var/www/;

    location /test {
        try_files /foo /bar/ /baz;
        echo "uri: $uri"; 
    }

    location /foo {
        echo foo;
    }

    location /bar/ {
        echo bar;
    }

    location /baz {
        echo baz;
    }

### try 内部跳转
假设现在 /var/www/ 路径下是空的, 则:

1. 第一个参数 /foo 映射成的文件 /var/www/foo 是不存在的；
2. 同样，对于第二个参数 /bar/ 所映射成的目录 /var/www/bar/ 也是不存在的。
3. 于是此时 Nginx 会在 try-files 阶段发起到最后一个参数所指定的 URI（即 /baz）的“内部跳转”。

实际的请求结果证实了这一点：

    $ curl localhost:8080/test
    baz

### try 文件存在
接下来再做一组实验：在 /var/www/ 下创建一个名为 foo 的文件，其内容为 hello world

    $ echo 'hello world' > /var/www/foo
    # 然后再请求 /test 接口：
    $ curl localhost:8080/test
    uri: /foo

类似地，如果匹配到/bar/, 就继续执行就localhost 后续请求

    $ mkdir /var/www/bar
    $ curl localhost:8080/test
    uri: /bar

我们看到， try_files 指令本质上:
1. 只是有条件地改写当前请求的 URI，而这里说的“条件”其实就是文件系统上的对象是否存在。
2. 当“条件”都不满足时，它就会无条件地发起一个指定的“内部跳转”。
   
### try 标准错误
try_files 指令还支持直接返回指定状态码的 HTTP 错误页，例如：

    try_files /foo /bar/ =404;

这行配置是说，当 /foo 和 /bar/ 参数所对应的文件系统对象都不存在时，就直接返回 404 Not Found 错误页