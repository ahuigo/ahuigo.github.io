
# Nunjucks(=Jinjia2) 
还有一个xtemplate

    {% include "item-template.html" %} {% endeach %}

## literal, raw

    {% raw %}
        {{name|escape}}
    {% endraw %}

    {% filter escape %}
        <span>try</span>
    {% endfilter %}

# koa2
koa2 既可以用在Node环境下，又可以运行在浏览器端。但是，主要还是运行在Node环境下，因为浏览器端有更好的模板解决方案，例如MVVM框架。(by liaoxuefeng)
1. Nunjucks: like Python的模板引擎jinja2
2. egg-init: extends koa2
3. AdonisJs: koa2 是脚手架，adonjs 则是laravel(ORM/crud/vue/...)

## global var(ctx.state)
ctx.state 一般保存全局, e.g. 某个middleware负责检查用户权限，它可以把当前用户放入ctx.state中：

    app.use(async (ctx, next) => {
        var user = parseUser(ctx.cookies.get('name') || '');
        if (user) {
            ctx.state.user = user;
            await next();
        } else {
            ctx.response.status = 403;
        }
    }); 

## router
子controller rest-api/render:

    module.exports = {
        //api
        'GET /api/products': async (ctx, next) => {
            // 设置Content-Type:
            ctx.response.type = 'application/json';
            // 设置Response Body:
            ctx.response.body = {
                products: products
            };
        }
        // render
        'GET /signin': async (ctx, next) => {
            let name = 'ahui'
            ctx.render('signin.html', {
                name: `${name}`
            });
        },
    }

## request
http://javascript.ruanyifeng.com/nodejs/koa.html#toc8

    # path
    ctx.request.path

    # /api/products/:id
    ctx.params.id 

    # query
    ctx.request.querystring
    ctx.request.query

form:

    var body = require('koa-better-body')
    var app = koa()

    app
    .use(body())
    .use(function * () {
        console.log(this.request.body)    // if buffer or text
        console.log(this.request.files)   // if multipart or urlencoded
        console.log(this.request.fields)  // if json or _POST
    }).listen(8080, function () {
        console.log('koa server start listening on port 8080')
    })

header

    ctx.request.header.accept

    // Content-Type为 application/json, this.request.is(types…)
    this.request.is('json', 'urlencoded'); // 'json'
    this.request.is('application/json'); // 'application/json'

    // Accept: text/*, application/json
    ctx.request.accepts('html');
    // "html"
    ctx.request.accepts('text/html');
    // "text/html"
    ctx.request.accepts('json', 'text');
    // => "json"


## response

    ctx.response.redirect('/signin');

    module.exports = {
        'GET /api/products': async (ctx, next) => {
            ctx.response.type = 'application/json';
            ctx.response.body = {
                products: []
            };
        }
    }

### REST
http status:
1. 200 
2. 400 ajax请求无效 (Bad request):
    1.  使用错误代码命名规范为: `大类:子类`

错误代码命名规范:

    ctx.response.status = 400;
    ctx.rest({
        code: 'auth:user_not_found',
        message: 'user not found'
    });

e.g.

    mysql
    mysql:net
    mysql:data_err

    user:no_login

## throw error

    ctx.rest({ data: 123 });
    ctx.error('auth:user_not_found', {name:'ah'});

我们也可以通过一个middleware给ctx添加一个rest()方法，直接输出JSON数据 (rest.js)：

    //restful
    app.use(async (ctx, next) => {
        if (ctx.request.path.startsWith('/api/') || ctx.request.accepts('json')) {
            ctx.rest = (data) => {
                ctx.response.type = 'application/json';
                ctx.response.body = data;
            }
            ctx.error = function (msg, extra) {
                throw { message, extra, }
            }
            try {
                await next();
            } catch (e) {
                ctx.response.status = 400;
                ctx.response.type = 'application/json';
                ctx.response.body = {
                    msg: e.message || 'internal:unknown_error',
                    extra: e.extra || null,
                };
            }
        } else {
            await next();
        }
    });

## koa middleware

    1. koa-bodyparser
    支持x-www-form-urlencoded, application/json等格式的请求体，但不支持form-data的请求体，需要借助 formidable 这个库，也可以直接使用 koa-body 或 koa-better-body

    2. koa-views
    对需要进行视图模板渲染的应用是个不可缺少的中间件，支持ejs, nunjucks等众多模板引擎。

    4 koa-static
    可结合 koa-compress 和 koa-mount 使用。

    5. koa-session

    6 koa-jwt
    随着网站前后端分离方案的流行，越来越多的网站从Session Base转为使用Token Base，JWT(Json Web Tokens)作为一个开放的标准被很多网站采用，koa-jwt这个中间件使用JWT认证HTTP请求。

    7 koa-helmet
    helmet 通过增加如Strict-Transport-Security, X-Frame-Options, X-Frame-Options等HTTP头提高Express应用程序的安全性，koa-helmet为koa程序提供了类似的功能，参考Node.js安全清单。

    8 koa-compress
    当响应体比较大时，我们一般会启用类似Gzip的压缩技术减少传输内容

    9 koa-logger
    koa-logger提供了输出请求日志的功能，koa-bunyan-logger 提供了更丰富的功能。

    10 koa-convert
    对于比较老的使用Generate函数的koa中间件(< koa2)，可以将他们转为基于Promise的中间件供Koa2使用

    作者：fineen
    链接：https://www.jianshu.com/p/c1e0ca3f9764
    來源：简书
