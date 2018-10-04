---
title: egg http 之获取文件流信息(multipart)
date: 2018-09-10
---
# httpclient
app.curl === app.httpclient === ctx.curl

    const result = await ctx.curl('https://registry.npm.taobao.org/egg/latest', {
        method: 'POST',
        // 通过 contentType 告诉 HttpClient 以 JSON 格式发送
        contentType: 'json',
        data: { hello: 'world', },

        dataType: 'json', // 自动解析 JSON response
        timeout: 3000, // 3 秒超时
    });

    ctx.body = {
      status: result.status,
      headers: result.headers,
      package: result.data,
    };

## request

    this.request.query
    this.request.body   // if multipart or urlencoded or json
                        //相当于koa-better-body 的fields ()
                        // httpbin.org 的form
    this.request.rawBody //相当于koa-better-body 的body(需要enables: text)
                        // httpbin.org 的data (any types)

### raw data

    // config.default.js support raw text
    const bodyParserConfig = {
        enable: true,
        encoding: 'utf8',
        formLimit: '100kb',
        jsonLimit: '100kb',
        strict: true,
        // @see https://github.com/hapijs/qs/blob/master/lib/parse.js#L8 for more options
        queryString: {
            arrayLimit: 100,
            depth: 5,
            parameterLimit: 1000,
        },
        enableTypes: ['json', 'form', 'text'],
        extendTypes: {
            text: ['text/xml', 'application/xml'],
        },
    };
    // 覆盖egg自带的配置
    exports.bodyParser = bodyParserConfig;

## multipart

        const FormStream = require('formstream');
        const form = new FormStream();
        form.field('foo', 'bar');
        form.file('file1', __filename);
        form.file('file2', file2);

        const result = await ctx.curl('https://httpbin.org/post', {
          method: 'POST',
          headers: form.headers(), // 生成符合 multipart/form-data 要求的请求 headers
          stream: form,
          dataType: 'json',
        });
        ctx.set(result.headers);
        ctx.body = result.data

## multipart + Stream file
如果服务端支持流式上传，最友好的方式还是直接发送 Stream.\
Stream 实际会以 Transfer-Encoding: chunked 传输编码格式发送，这个转换是 HTTP 模块自动实现的。

    // httpbin.org 不支持 stream 模式，
    const result = await ctx.curl(`${ctx.protocol}://${ctx.host}/stream`, {
      method: 'POST',
      stream: require('fs').createReadStream(__filename),
    });

## WriteStream
一旦设置此参数，那么返回值 result.data 将会被设置为 null

    ctx.curl(url, {
        writeStream: fs.createWriteStream('/path/to/store'),
    });

# 调试辅助

## install debug curl plugin

    $ npm i egg-development-proxyagent --save
    // config/plugin.js
    exports.proxyagent = {
      enable: true,
      package: 'egg-development-proxyagent',
    }

    $ http_proxy=http://127.0.0.1:8888 npm run dev

用 charles 或 fiddler，此处我们用 anyproxy 来演示下。

    $ npm install anyproxy -g
    $ anyproxy --port 8888
