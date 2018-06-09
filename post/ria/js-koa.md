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

我们也可以通过一个middleware给ctx添加一个rest()方法，直接输出JSON数据 (rest.js)：

    module.exports = {
        restify: (pathPrefix) => {
            // REST API前缀，默认为/api/:
            pathPrefix = pathPrefix || '/api/';
            return async (ctx, next) => {
                // 是否是REST API前缀?
                if (ctx.request.path.startsWith(pathPrefix)) {
                    // 绑定rest()方法:
                    ctx.rest = (data) => {
                        ctx.response.type = 'application/json';
                        ctx.response.body = data;
                    }
                    await next();
                } else {
                    await next();
                }
            };
        }
    };
    ctx.rest({ data: 123 });



## request
    # post
    app.use(bodyParser());
        ctx.request.body.name

    # path
    ctx.request.path

    # /api/products/:id
    ctx.params.id 

    # query
    ctx.request.query

## response
    ctx.response.redirect('/signin');

# REST
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

    throw new APIError('auth:user_not_found', 'user not found');

middleware:

    module.exports = {
        APIError: function (code, message) {
            this.code = code || 'internal:unknown_error';
            this.message = message || '';
        },
        restify: (pathPrefix) => {
            pathPrefix = pathPrefix || '/api/';
            return async (ctx, next) => {
                if (ctx.request.path.startsWith(pathPrefix)) {
                    // 绑定rest()方法:
                    ctx.rest = (data) => {
                        ctx.response.type = 'application/json';
                        ctx.response.body = data;
                    }
                    try {
                        await next();
                    } catch (e) {
                        // 返回错误:
                        ctx.response.status = 400;
                        ctx.response.type = 'application/json';
                        ctx.response.body = {
                            code: e.code || 'internal:unknown_error',
                            message: e.message || ''
                        };
                    }
                } else {
                    await next();
                }
            };
        }
    };