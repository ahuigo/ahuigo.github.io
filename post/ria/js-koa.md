# koa
1. Nunjucks: like Python的模板引擎jinja2
既可以用在Node环境下，又可以运行在浏览器端。但是，主要还是运行在Node环境下，因为浏览器端有更好的模板解决方案，例如MVVM框架。(by liaoxuefeng)

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


