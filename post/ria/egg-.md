# Egg 
http://mirror.eggjs.org/zh-cn/advanced/loader.html

## ctx
    ctx.app
    // /app/router.js
    { router, controller } = app;

## request
### headers 
ctx.headers，ctx.header，ctx.request.headers，ctx.request.header：这几个方法是等价

  ctx.get('user-agent') || ''; //自动处理大小写
  ctx.get('content-type') ==='application/json'

  ctx.host
  ctx.protocol
  ctx.ip

### query
    //router.get('/user/:id'
    ctx.params.id
    ctx.query.page
        ctx.queries.page array
    ctx.request.body // json, form-urlencode
        ctx.request.rawBody //after bodyParser

config:

    exports.bodyParser = {
        jsonLimit: '5mb',
        formLimit: '6mb',
    };

### raw body(based on koa)

    const rawBody = require('raw-body')
    const rawRequestBody = await rawBody(ctx.req) //Buffer

### cookie & session
http://mirror.eggjs.org/zh-cn/basics/controller.html

    ctx.cookies.get('count');
    ctx.cookies.set('count', null);

    ctx.session.userId
    ctx.session.visited = ctx.session.visited ? ++ctx.session.visited : 1;
    this.ctx.session = null;
    ctx.session.maxAge = require('ms')('30d');// 记住我

    // config/config.default.js
    module.exports = {
        session: {
            renew: true, //仅剩下最大有效期一半的时候，重置 
            key: 'EGG_SESS',
            maxAge: 24 * 3600 * 1000, // 1 天
            httpOnly: true,
            encrypt: true,
        },
    };

### form

    stream = await ctx.getFileStream()
    stream.fields

    const parts = this.ctx.multipart({ autoFields: true });
    while ((part = await parts()) != null) {}
    parts.field[key]


#### file
新增支持的文件扩展名

    // config/config.default.js
    module.exports = {
        multipart: {
            fileExtensions: [ '.apk' ], // 增加对 .apk 扩展名的支持
        },
    };

single file:

    // FileStream != ReadStream
    const stream = await ctx.getFileStream();
    
    try {
      stream.read().toString()
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

    const [files, fields] = await this.multipart()

http://mirror.eggjs.org/zh-cn/basics/controller.html#%E8%8E%B7%E5%8F%96%E4%B8%8A%E4%BC%A0%E7%9A%84%E6%96%87%E4%BB%B6

### router
router.js

    // / -> /home/index
    app.router.redirect('/', '/home/index', 302);

controller:

    ctx.recirect('http://baidu.com')
        exports.security = {
            domainWhiteList:['.domain.com'],  // 安全白名单，以 . 开头
        };
    ctx.unsafeRedirect(url) 一般不建议使用，明确了解可能带来的风险后使用

## response
### set header

    ctx.set('show-response-time', used.toString());
    ctx.set(headers)

### response stream
node 流式特性, 框架也支持直接将 body 设置成一个 Stream，并会同时处理好这个 Stream 上的错误事件。

    class ProxyController extends Controller {
        async proxy() {
            const ctx = this.ctx;
            const result = await ctx.curl(url, { streaming: true, });
            ctx.set(result.header);
            // result.res 是一个 stream
            ctx.body = result.res;
        }
    };

## render

    await ctx.render('home.tpl', { name: 'egg' });
    // ctx.body = await ctx.renderString('hi, {{ name }}', { name: 'egg' });

## controller

    this.ctx
    this.app === this.ctx.app
    this.service
    this.config
    this.logger.warn

### define controller
module.exports 不能少

    //module.exports = 
    module.exports = (app) =>
        class ClipboardController extends app.BaseController {

### ctx.validate
    // config/plugin.js
    exports.validate = {
        enable: true,
        package: 'egg-validate',
    };

    //异常的状态码为 422 
    const createRule = {
        title: { type: 'string' },
        content: { type: 'string' },
    };
    // 如果不传第二个参数会自动校验 `ctx.request.body`
    ctx.validate(createRule); 

定制rule:

    // app.js
    app.validator.addRule('json', (rule, value) => {
        try {
            JSON.parse(value);
        } catch (err) {
            return 'must be json string';
        }
    });

    //使用
    const rule = { test: 'json' };
    ctx.validate(rule, ctx.query);

## schedule 定时任务
egg 多个 worker 不会竞争schedule

    //app/schedule/update_cache.js
    module.exports = {
        schedule: {
            interval: '1m', // 1 分钟间隔
            type: 'all', // 指定所有的 worker 都需要执行
        },
        async task(ctx) {
            const res = await ctx.curl('http://www.api.com/cache', { dataType: 'json', });
            ctx.app.cache = res.data;
        },
    };

### 定时 参数:

    type:
        'worker', //随机一个 worker 执行
    interval: '10s',
         '5000',//5s
         app.config.cacheTick
    // 每三小时准点执行一次
    cron: '0 0 */3 * * *',
        *    *    *    *    *    *
        ┬    ┬    ┬    ┬    ┬    ┬
        │    │    │    │    │    └ day of week (0 - 7) (0 or 7 is Sun)
        │    │    │    │    └───── month (1 - 12)
        │    │    │    └────────── day of month (1 - 31)
        │    │    └─────────────── hour (0 - 23)
        │    └──────────────────── minute (0 - 59)
        └───────────────────────── second (0 - 59, optional)

### 执行日志:
会输出到 `${appInfo.root}/logs/{app_name}/egg-schedule.log`，默认不会输出到控制台，可以通过 config.customLogger.scheduleLogger 来自定义。

    // config/config.default.js
    config.customLogger = {
        scheduleLogger: {
            // consoleLevel: 'NONE',
            // file: path.join(appInfo.root, 'logs', appInfo.name, 'egg-schedule.log'),
        },
    };

### 手动执行 定时任务

    // app.js
    module.exports = app => {
        app.beforeStart(async () => {
            await app.runSchedule('update_cache');
        });
    };

## inner object
http://mirror.eggjs.org/zh-cn/basics/objects.html

1. app 继承自 Koa.Application 的实例。 注意: app!==require('egg'), 尽管他们指向同一个Controller
    1. controller.app === ctx.app
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
      formatMoney(val) {
        const lang = this.ctx.get('Accept-Language');
        if (lang.includes('zh-CN')) {
          return `￥ ${val}`;
        }
        return `$ ${val}`;
      },
    };


# dev
http://mirror.eggjs.org/zh-cn/advanced/loader.html

## loader
    加载 plugin: 以及config/plugin.js
    加载 config， 加载 config/config.{env}.js
    加载 extend，遍历 loadUnit 加载 app/extend/xx.js
    自定义初始化，遍历 loadUnit 加载 app.js 和 agent.js
    加载 service，遍历 loadUnit 加载 app/service 目录
    加载 middleware，遍历 loadUnit 加载 app/middleware 目录
    加载 controller，加载应用的 app/controller 目录
    加载 router，加载应用的 app/router.js

    // app.js
    // 获取所有的 loadUnit
    const servicePaths = app.loader.getLoadUnits().map(unit => path.join(unit.path, 'app/service'));

## 生命周期
Egg提供了应用启动(beforeStart), 启动完成(ready), 关闭(beforeClose)这三个生命周期方法。

    Master: init master process
                    ⬇
    Agent:  init *agent* worker process
                    ⬇
            loader.load | beforeStart
                    ⬇
            await agent worker ready
                    ⬇
            call ready callback
                    ⬇
    APP:    init app worker processes
                    ⬇
            loader.load | beforeStart
                    ⬇
            await app workers ready
                    ⬇
            call ready callback
                    ⬇
    Ready:  send egg-ready to master,
                agent,app workers


## plugin & extend
一个插件其实就是一个『迷你的应用』，和应用（app）几乎一样：

plugin 可以支持扩展：
1. Application this.ctx.app合并 app/extend/application.js 中定义的对象 
2. Helper
3. context.js 为this.ctx 加属性, **请求级别**的
4. Request  **请求级别**的
5. Response **请求级别**的

### context extend
以context 为例子: app.context

    // app/extend/context.js
    module.exports = {
        get isIOS() {
            const iosReg = /iphone|ipad|ipod/i;
            return iosReg.test(this.get('user-agent'));
        },
    };

### config/plugin.js 安装配置
当我们把extend/context.js 移动到 `/lib/plugin/egg-ua/app/extend/context.js` 就需要安装配置

    exports.nunjucks = {
        enable: true,
        package: 'egg-view-nunjucks'
    };

plugin.js 安装:

    {Boolean} enable - 是否开启此插件，默认为 true
        对于内置插件的关闭，只需要: exports.inner_plugin_name = false
    {String} package - npm 模块名称，通过 npm 模块形式引入插件
    {String} path - 插件绝对路径，跟 package 配置互斥
        path: path.join(__dirname, '../lib/plugin/egg-ua'),
    {Array} env - 只有在指定运行环境才能开启，会覆盖插件自身 package.json 中的配置

plugin.{env}.js根据环境配置: 比如只希望在本地环境加载，可以egg-dev 安装到 devDependencies，然后

    // config/plugin.local.js ; // local is for unittest/dev
    exports.dev = {
        enable: true,
        package: 'egg-dev',
    };

这样在生产环境可以 `npm i --production` 不需要下载 egg-dev 的包了

### plugin & middleware 共用配置

    // config/config.default.js
    exports.mysql = {
        client: {
            host: 'mysql.com',
            port: '3306',
            user: 'test_user',
            password: 'test_password',
            database: 'test',
        },
    };

## lib
    // {app_root}/lib/foo.js
    module.exports = class Foo {
      constructor(app) {
        this.app = app;
      }
      sayHi() {}
    }
    
    // {app_root}/app/extend/application.js
    const Foo = require('../../lib/foo');
    const FOO = Symbol('Application#foo');
    module.exports = {
      get foo() {
        if (!this[FOO]) {
          this[FOO] = new Foo(this);
        }
        return this[FOO];
      }
    }
    
    // 使用
    this.app.foo.sayHi()

也可以通过 loader 方式：
    
    // app.js
    app.xx = app.loader.loadFile('path/to/file');

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