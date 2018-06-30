# Egg 
https://eggjs.org/zh-cn/advanced/loader.html

## loader
加载 plugin，找到应用和框架，加载 config/plugin.js
加载 config，遍历 loadUnit 加载 config/config.{env}.js
加载 extend，遍历 loadUnit 加载 app/extend/xx.js
自定义初始化，遍历 loadUnit 加载 app.js 和 agent.js
加载 service，遍历 loadUnit 加载 app/service 目录
加载 middleware，遍历 loadUnit 加载 app/middleware 目录
加载 controller，加载应用的 app/controller 目录
加载 router，加载应用的 app/router.js


## plugin
plugin 可以支持扩展：
1. Application this.ctx.app
2. context.js 为this.ctx 加属性
3. Request
4. Response
5. Helper

以context 为例子

    // app/extend/context.js
    module.exports = {
        get isIOS() {
            const iosReg = /iphone|ipad|ipod/i;
            return iosReg.test(this.get('user-agent'));
        },
    };

    // config/plugin.js
    exports.any_name = {
        enable: true,
        path: path.join(__dirname, '../lib/plugin/egg-ua'),
    }

一般来说属性的计算只需要进行一次，那么是可以实现缓存

    // app/extend/application.js
    const BAR = Symbol('Application#bar');
    module.exports = {
        get bar() {
            // this 就是 app 对象，在其中可以调用 app 上的其他方法，或访问属性
            if (!this[BAR]) {
            // 实际情况肯定更复杂
            this[BAR] = this.config.xx + this.config.yy;
            }
            return this[BAR];
        },
    };

## middleware
options: 中间件的配置项，框架会将 app.config[${middlewareName}] 传递进来。

    // app/middleware/gzip.js
    const isJSON = require('koa-is-json');
    const zlib = require('zlib');

    async function gzip(ctx, next) {
        await next();

        let body = ctx.body;
        if (!body) return;
        if (isJSON(body)) body = JSON.stringify(body);

        // 设置 gzip body，修正响应头
        const stream = zlib.createGzip();
        stream.end(body);
        ctx.body = stream;
        ctx.set('Content-Encoding', 'gzip');
    }
    module.exports = options => {console.log(options); return gzip}
    module.exports = options => gzip;

这与koa midllerware 兼容，所以可以直接用koa-compress, koa-bodyParser

### 应用中间件
应用中间件 config.default.js: (中间件的配置项通过同名配置 options)

    module.exports = {
        // 配置需要的中间件，数组顺序即为中间件的加载顺序
        middleware: [ 'gzip', '....'],

        // 配置 gzip 中间件的配置:app.config[${middlewareName}]
        gzip: {
            threshold: 1024, // 小于 1k 的响应体不压缩
        },
    };

该配置最终将在启动时合并到 `app.config.appMiddleware`

### 框架和插件 中间件
框架和插件不支持在 config.default.js 中匹配 middleware，需要通过以下方式：

    // app.js
    module.exports = app => {
        // 在中间件最前面统计请求时间
        app.config.coreMiddleware.unshift('report');
    };

    // app/middleware/report.js
    module.exports = () => {
        return async function (ctx, next) {
            const startTime = Date.now();
            await next();
            // 上报请求时间
            reportTime(Date.now() - startTime);
        }
    };

应用层定义的中间件（app.config.appMiddleware）和框架默认中间件（app.config.coreMiddleware）都会被加载器加载，并挂载到 app.middleware 上。

### router 中间件
以上两种方式配置的中间件是全局的，会处理每一次请求。 如果你只想针对单个路由生效，

    //直接在 app/router.js 中实例化和挂载：
    module.exports = app => {
        const gzip = app.middleware.gzip({ threshold: 1024 });
        app.router.get('/needgzip', gzip, app.controller.handler);
    };
