# Egg 
http://mirror.eggjs.org/zh-cn/advanced/loader.html

## ctx
    ctx.app
    // /app/router.js
    { router, controller } = app;

## request
### headers 
ctx.headers，ctx.header，ctx.request.headers，ctx.request.header：这几个方法是等价

  ctx.get('user-agent') || '';
  ctx.get('content-type') ==='application/json'

### query
    //router.get('/user/:id'
    ctx.params.id
    ctx.query.page
        ctx.queries.page array
    ctx.request.body // form

### form
stream.fields

#### file
single file:

    const stream = await ctx.getFileStream();
    try {
      let result = await ctx.oss.put('output.bin', stream);
    } catch (err) {
      // 必须将上传的文件流消费掉，要不然浏览器响应会卡死
      const sendToWormhole = require('stream-wormhole');
      await sendToWormhole(stream);
      throw err;
    }
    ctx.body = {
      url: result.url,
      // 所有表单字段都能通过 `stream.fields` 获取到
      fields: stream.fields,
    };

multi file:

    const parts = ctx.multipart();
    let part;
    // parts() return a promise
    while ((part = await parts()) != null) {
      if (part.length) {
        // 如果是数组的话是 filed
        console.log('field: ' + part[0]);
        console.log('value: ' + part[1]);
        console.log('valueTruncated: ' + part[2]);
        console.log('fieldnameTruncated: ' + part[3]);
      } else {
        if (!part.filename) {
          // 这时是用户没有选择文件就点击了上传(part 是 file stream，但是 part.filename 为空)
          return;
        }
        // part 是上传的文件流
        console.log('field: ' + part.fieldname);
        console.log('filename: ' + part.filename);
        console.log('encoding: ' + part.encoding);
        console.log('mime: ' + part.mime);
        // 文件处理，上传到云存储等等
        let result;
        try {
          result = await ctx.oss.put('egg-multipart-test/' + part.filename, part);
        } catch (err) {
          await sendToWormhole(part);
          throw err;
        }
        console.log(result);
      }
    }

### router
router.js

    // / -> /home/index
    app.router.redirect('/', '/home/index', 302);

controller:

    ctx.recirect('http://baidu.com')



## controller
    this.ctx
    this.app === this.ctx.app
    this.service
    this.config
    this.logger.warn

### ctx.validate
    const createRule = {
        title: { type: 'string' },
        content: { type: 'string' },
    };
    // 校验参数
    ctx.validate(createRule);

## inner object
http://mirror.eggjs.org/zh-cn/basics/objects.html

1. app 继承自 Koa.Application 的实例。 注意: app!==require('egg'), 尽管他们指向同一个Controller
    1. this.app === ctx.app
2. ctx 是一个请求级别的对象，继承自 Koa.Contex. 支持热加载
    1. 在有些非用户请求的场景下我们需要访问 service / model 等 
        1. const ctx = app.createAnonymousContext();
        2. await ctx.service.posts.load();
3. controller
4. helper
    1. ctx.helper.formatUser(user);
    2. in html: {{ helper.shtml(value) }}

## helper

    // app/extend/helper.js
    module.exports = {
        formatUser(user) {
            return only(user, [ 'name', 'phone' ]);
        }
    };

## logger

    // app logger 记录启动阶段的一些数据信
    app.logger.warn(msg)

    // 当前请求相关的信息（如 [$userId/$ip/$traceId/${cost}ms $method $url]
    ctx.logger 

    //controller/service logger 本质上就是一个 Context Logger，不过在打印日志的时候还会额外的加上文件路径
    this.logger



# dev
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

### context plugin
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
    exports.nunjucks = {
        enable: true,
        package: 'egg-view-nunjucks'
    };

一般来说属性的计算只需要进行一次，那么是可以实现缓存

    // app/extend/application.js
    const BAR = Symbol('Application#bar');
    module.exports = {
        get bar() {
            // this 就是 app 对象，在其中可以调用 app 上的其他方法，或访问属性
            if (!this[BAR]) {
                this[BAR] = this.config.xx + this.config.yy;
            }
            return this[BAR];
        },
    };

## middleware
与koa midllerware 兼容，所以可以直接用koa-compress, koa-bodyParser


### define middleware:

    // app/middleware/report.js
    module.exports = (options, app) => {
        return async function (ctx, next) {
            const startTime = Date.now();
            await next();
            // 上报请求时间
            reportTime(Date.now() - startTime);
        }
    };


### coreMiddleware
都会被加载器加载，并挂载到 app.middleware 上. app不能覆盖core
1. 应用层中间件（app.config.appMiddleware）
2. 框架默认中间件（app.config.coreMiddleware）

框架和插件不支持在 config.default.js 中匹配 middleware，需要通过以下方式：

    // app.js
    module.exports = app => {
        // 在中间件最前面统计请求时间
        app.config.coreMiddleware.unshift('report');
    };

    // middleware = report(app.config.report,app)

### appMiddleware
该配置最终将在启动时合并到 app.config.appMiddleware。

    //config.default.js
    module.exports = {
        // 配置需要的中间件，数组顺序即为中间件的加载顺序
        middleware: [ 'gzip' ],

        // 配置 gzip 中间件的配置
        gzip: {
            threshold: 1024, // 小于 1k 的响应体不压缩
        },
    };

### router 中间件
以上两种方式配置的中间件是全局的，会处理每一次请求。 如果你只想针对单个路由生效，

    //直接在 app/router.js 中实例化和挂载：
    module.exports = app => {
        const gzip = app.middleware.gzip({ threshold: 1024 });
        app.router.get('/needgzip', gzip, app.controller.handler);
    };

### Koa 的中间件
in koa:

    const compress = require('koa-compress');
    const options = { threshold: 2048 };
    app.use(compress(options));

in egg:

    / app/middleware/compress.js
    // koa-compress 暴露的接口(`(options) => middleware`)和框架对中间件要求一致
    module.exports = require('koa-compress');

    // config/config.default.js
    module.exports = {
        middleware: [ 'compress' ],
        compress: {
            threshold: 2048,
        },
    };

如果使用到的 Koa 中间件不符合入参规范，则可以自行处理下：

    // config/config.default.js
    module.exports = {
        webpack: {
            compiler: {},
            others: {},
        },
    };

    // app/middleware/webpack.js
    const webpackMiddleware = require('some-koa-middleware');

    module.exports = (options, app) => {
        return webpackMiddleware(options.compiler, options.others);
    }

### 通用配置
无论是应用层加载的中间件还是框架自带中间件，都支持几个通用的配置项：

    enable：控制中间件是否开启。
    match：设置只有符合某些规则的请求才会经过这个中间件。
    ignore：设置符合某些规则的请求不经过这个中间件。

#### enable example:

    module.exports={
        bodyParser: {
            enable: false,
        },
    }

##### match/ignore:
1. 字符串：匹配 url 的路径前缀
2. 正则：匹配满足正则验证的 url 的路径。
2. 函数：ctx传递给这个函数

match example:

    gzip: {
        match: '/static',
        match(ctx) {
            // 只有 ios 设备才开启
            const reg = /iphone|ipad|ipod/i;
            return reg.test(ctx.get('user-agent'));
        },
    },