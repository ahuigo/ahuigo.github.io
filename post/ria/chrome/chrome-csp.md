---
title: Chrome CSP
date: 2019-10-06
private: 
---
# CSP(content-security-policy)
> https://www.ruanyifeng.com/blog/2016/09/csp.html
> https://www.uriports.com/blog/creating-a-content-security-policy-csp/

# CSP 启用
1.用header:

    Content-Security-Policy: script-src 'self'; object-src 'none';
    style-src cdn.example.org third-party.org; child-src https:

2.另一种是通过网页的<meta>标签。

    <meta http-equiv="Content-Security-Policy" content="script-src 'self'; object-src 'none'; style-src cdn.example.org third-party.org; child-src https:">

## 新版chrome 的变化
### unsafe-inline 不再有效
新chrome 无效:

    <meta http-equiv="Content-Security-Policy" content="script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'">

### nonce和sha256同样无效

    <meta http-equiv="Content-Security-Policy" content="script-src 'self'  'sha256-m1SkrZVLRPjpQzG15ytmzxX='">

    <meta http-equiv="Content-Security-Policy" content="script-src 'self' 'nonce-EDNnf03nceIOfn39fn3e9h3sdfa'">


# CSP 写法

## CSP 限制类型
    script-src：外部脚本
    style-src：样式表
    img-src：图像
    media-src：媒体文件（音频和视频）
    font-src：字体文件
    object-src：插件（比如 Flash）
    child-src：框架
    frame-ancestors：嵌入的外部资源（比如<frame>、<iframe>、<embed>和<applet>）
    connect-src：HTTP 连接（通过 XHR、WebSockets、EventSource等）
    worker-src：worker脚本
    manifest-src：manifest 文件

### 选项值
每个限制选项可以设置以下几种值，这些值就构成了白名单。

    主机名：example.org，https://example.com:443
    路径名：example.org/resources/js/
    通配符：*.example.org，*://*.example.com:*（表示任意协议、任意子域名、任意端口）
    协议名：https:、data:
    关键字'self'：当前域名，需要加引号
    关键字'none'：禁止加载任何外部资源，需要加引号

多个值也可以并列，用空格分隔。

    Content-Security-Policy: script-src 'self' https://apis.google.com

### script-src 的特殊值
除了常规值，script-src还可以设置一些特殊值。注意，下面这些值都必须放在单引号里面。

    'unsafe-inline'：允许执行页面内嵌的&lt;script>标签和事件监听函数
    unsafe-eval：允许将字符串当作代码执行，比如使用eval、setTimeout、setInterval和Function等函数。
    nonce值：每次HTTP回应给出一个授权token，页面内嵌脚本必须有这个token，才会执行
    hash值：列出允许执行的脚本代码的Hash值，页面内嵌脚本的哈希值只有吻合的情况下，才能执行。

nonce值的例子如下: 服务器发送网页的时候，告诉浏览器一个随机生成的token。

    Content-Security-Policy: script-src 'nonce-EDNnf03nceIOfn39fn3e9h3sdfa'

页面内嵌脚本，必须有这个token才能执行。

    <script nonce=EDNnf03nceIOfn39fn3e9h3sdfa>
    // some code
    </script>

hash值的例子如下，服务器给出一个允许执行的代码的hash值。

    Content-Security-Policy: script-src 'sha256-qznLcsROx4GACP2dm0UCKCzCG-HiZ1guq6ZZDob_Tng='
    Content-Security-Policy: script-src 'sha256-第1个' 'sha256-第2个'

下面的代码就会允许执行，因为hash值相符。

    // 注意，计算hash值的时候，<script>标签不算在内。
    <script>alert('Hello, world.');</script>

### 其他
这些也放在了 CSP 里面。

    block-all-mixed-content：HTTPS 网页不得加载 HTTP 资源（浏览器已经默认开启）
    upgrade-insecure-requests：自动将网页上所有加载外部资源的 HTTP 链接换成 HTTPS 协议
    plugin-types：限制可以使用的插件格式
    sandbox：浏览器行为的限制，比如不能有弹出窗口等。

## default-src(默认值)
设置以上所有选项的默认值.
e.g.，限制所有的外部资源，都只能从当前域名加载

    Content-Security-Policy: default-src 'self'

## report-uri
有时，我们不仅希望防止 XSS，还希望记录此类行为。report-uri就用来告诉浏览器，应该把注入行为报告给哪个网址。

    Content-Security-Policy: default-src 'self'; ...; report-uri /my_amazing_csp_report_parser;

上面代码指定，将注入行为报告给/my_amazing_csp_report_parser这个 URL, 使用POST发送一个JSON对象，下面是一个例子:

    {
        "csp-report": {
            "document-uri": "http://example.org/page.html",
            "referrer": "http://evil.example.com/",
            "blocked-uri": "http://evil.example.com/evil.js",
            "violated-directive": "script-src 'self' https://apis.google.com",
            "original-policy": "script-src 'self' https://apis.google.com; report-uri http://example.org/my_amazing_csp_report_parser"
        }
    }


## Content-Security-Policy-Report-Only
除了Content-Security-Policy，还有一个Content-Security-Policy-Report-Only字段，表示不执行限制选项，只是记录违反限制的行为。

    // 它必须与report-uri选项配合使用。
    Content-Security-Policy-Report-Only: default-src 'self'; ...; report-uri /my_amazing_csp_report_parser;

# 注意
1. script-src和object-src是必设的，除非设置了default-src。

> 因为攻击者只要能注入脚本，其他限制都可以规避。而object-src必设是因为 Flash 里面可以执行外部脚本。

2. script-src不能使用unsafe-inline关键字（除非伴随一个nonce值），也不能允许设置data:URL。

下面是两个恶意攻击的例子。

    <img src="x" onerror="evil()">
    <script src="data:text/javascript,evil()"></script>