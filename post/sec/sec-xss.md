# xss
属性值请escape

	\<script\>alert(\"感觉不错的样子！\")\</script\>
	<script>alert(/xss/)</script>

## todo
Refer: http://www.cnblogs.com/TankXiao/archive/2012/03/21/2337194.html

## iframe

	<iframe/onload=alert(10)>

## onerror onchange onload

	t = '<img src=1 onerror=alert(2)>'
	t = '<img src=1 onload=alert(2)>'
	t = '<img src=1 onchange=alert(2)>'

## style(for ie6)
expression

	<div style="width: expression(alert('xss'));">

Or javascript

	<div style="background-image: url(javascript:alert('xss'))">

And this??

	<div style="this-is-js-property: alert 'xss';">

# CSP, Content Security Policy
> http://www.ruanyifeng.com/blog/2016/09/csp.html
CSP 的实质就是白名单制度，开发者明确告诉客户端，哪些外部资源可以加载和执行

## 加载方法
两种

1. http 响应头: Content-Security-Policy

    Content-Security-Policy: script-src 'self'; object-src 'none';
    style-src cdn.example.org third-party.org; child-src https:

2. meta 标签

    <meta http-equiv="Content-Security-Policy" content="script-src 'self'; object-src 'none'; style-src cdn.example.org third-party.org; child-src https:">

上面代码中，CSP 做了如下配置。

    脚本：只信任当前域名
    <object>标签：不信任任何URL，即不加载任何资源
    样式表：只信任cdn.example.org和third-party.org
    框架（frame）：必须使用HTTPS协议加载
    其他资源：没有限制

## 二、限制选项
CSP 提供了很多限制选项，涉及安全的各个方面。

### 2.1 资源加载限制
以下选项限制各类资源的加载。

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

### 2.2 default-src
default-src用来设置上面各个选项的默认值。

    Content-Security-Policy: default-src 'self'

上面代码限制所有的外部资源，都只能从当前域名加载。

### 2.3 URL 限制
有时，网页会跟其他 URL 发生联系，这时也可以加以限制。

    frame-ancestors：限制嵌入框架的网页
    base-uri：限制<base#href>
    form-action：限制<form#action>

### 2.4 其他限制
其他一些安全相关的功能，也放在了 CSP 里面。

    block-all-mixed-content：HTTPS 网页不得加载 HTTP 资源（浏览器已经默认开启）
    upgrade-insecure-requests：自动将网页上所有加载外部资源的 HTTP 链接换成 HTTPS 协议
    plugin-types：限制可以使用的插件格式
    sandbox：浏览器行为的限制，比如不能有弹出窗口等。

### 2.5 report-uri
有时，我们不仅希望防止 XSS，还希望记录此类行为。report-uri就用来告诉浏览器，应该把注入行为报告给哪个网址。

    Content-Security-Policy: default-src 'self'; ...; report-uri /my_amazing_csp_report_parser;

上面代码指定，将注入行为报告给/my_amazing_csp_report_parser这个 URL。

浏览器会使用POST方法，发送一个JSON对象，下面是一个例子。

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

它必须与report-uri选项配合使用。

    Content-Security-Policy-Report-Only: default-src 'self'; ...; report-uri /my_amazing_csp_report_parser;

## 四、选项值
每个限制选项可以设置以下几种值，这些值就构成了白名单。

    主机名：example.org，https://example.com:443
    路径名：example.org/resources/js/
    通配符：*.example.org，*://*.example.com:*（表示任意协议、任意子域名、任意端口）
    协议名：https:、data:
    关键字'self'：当前域名，需要加引号
    关键字'none'：禁止加载任何外部资源，需要加引号

多个值也可以并列，用空格分隔。

    Content-Security-Policy: script-src 'self' https://apis.google.com

如果同一个限制选项使用多次，只有第一次会生效。

    # 错误的写法
    script-src https://host1.com; script-src https://host2.com

    # 正确的写法
    script-src https://host1.com https://host2.com

如果不设置某个限制选项，就是默认允许任何值。

## 五、script-src 的特殊值
除了常规值，script-src还可以设置一些特殊值。注意，下面这些值都必须放在单引号里面。

    'unsafe-inline'：允许执行页面内嵌的&lt;script>标签和事件监听函数
    unsafe-eval：允许将字符串当作代码执行，比如使用eval、setTimeout、setInterval和Function等函数。
    nonce值：每次HTTP回应给出一个授权token，页面内嵌脚本必须有这个token，才会执行
    hash值：列出允许执行的脚本代码的Hash值，页面内嵌脚本的哈希值只有吻合的情况下，才能执行。

nonce值的例子如下，服务器发送网页的时候，告诉浏览器一个随机生成的token。

    Content-Security-Policy: script-src 'nonce-EDNnf03nceIOfn39fn3e9h3sdfa'

页面内嵌脚本，必须有这个token才能执行。

    <script nonce=EDNnf03nceIOfn39fn3e9h3sdfa>
      // some code
    </script>

hash值的例子如下，服务器给出一个允许执行的代码的hash值。

    Content-Security-Policy: script-src 'sha256-qznLcsROx4GACP2dm0UCKCzCG-HiZ1guq6ZZDob_Tng='

下面的代码就会允许执行，因为hash值相符。

    <script>alert('Hello, world.');</script>

注意，计算hash值的时候，<script>标签不算在内。
除了script-src选项，nonce值和hash值还可以用在style-src选项，控制页面内嵌的样式表。

## 六、注意点
- (1）script-src和object-src是必设的，除非设置了default-src。
因为攻击者只要能注入脚本，其他限制都可以规避。而object-src必设是因为 Flash 里面可以执行外部脚本。
- （2）script-src不能使用unsafe-inline关键字（除非伴随一个nonce值），也不能允许设置data:URL。

下面是两个恶意攻击的例子。

    <img src="x" onerror="evil()">
    <script src="data:text/javascript,evil()"></script>

-（3）必须特别注意 JSONP 的回调函数。

    <script
        src="/path/jsonp?callback=alert(document.domain)//">
    </script>

上面的代码中，虽然加载的脚本来自当前域名，但是通过改写回调函数，攻击者依然可以执行恶意代码。
