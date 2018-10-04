---
title: egg-test
date: 2018-10-04
---
# egg-test

## mock app

    const mock = require('egg-mock');
    const assert = require('assert');

    it('should schedule work fine', async () => {
        const app = mock.app();
        await app.ready();
        await app.runSchedule('update_cache');
        assert(app.cache);
    });

封装下:

    const { app, mock, assert } = require('egg-mock/bootstrap');

## mock ctx

    const ctx = app.mockContext();
    assert(ctx.method === 'GET');
    assert(ctx.url === '/');

ctx with data:

    const ctx = app.mockContext({
        user: { name: 'fengmk2', },
    });
    assert(ctx.user);
    assert(ctx.user.name === 'fengmk2')

### mock ctx headers

    const ctx = app.mockContext({
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
      },
    });
    assert(ctx.get('x-requested-with').include('XML'));

## mock ctx.request

    const ctx = app.mockContext({
      headers: {
        'User-Agent': 'Chrome/56.0.2924.51',
      },
    });
    assert(ctx.request.get('User-Agent').include('Chrome'));

## mock ctx.other

    ctx.response.status===200
    ctx.helper.func()



## mock 顺序
Mocha 刚开始运行的时候会载入所有用例，这时 describe 方法就会被调用：

    describe('bad test', () => {
        doSomethingBefore(); //不适合only 方式

        it('should redirect', () => {
            return app.httpRequest() .get('/') .expect(302);
        });
    });

正确的方式是: before -> beforeEach -> it -> afterEach -> after 的顺序执行，而且可以定义多个。

    describe('egg test', () => {
        before(() => console.log('order 1'));
        before(() => console.log('order 2'));
        after(() => console.log('order 6'));
        beforeEach(() => console.log('order 3'));
        afterEach(() => console.log('order 5'));
        it('should worker', () => console.log('order 4'));
    });

## mock controller
mock 模拟 CSRF token:

    app.mockCsrf();

return:

    // 使用返回 Promise 的方式
    it('should redirect', () => {
      return app.httpRequest()
        .get('/')
        .expect(302);
    });

    // 使用 callback 的方式
    it('should redirect', done => {
      app.httpRequest()
        .get('/')
        .expect(302, done);
    });

    // 使用 async
    it('should redirect', async () => {
      await app.httpRequest()
        .get('/')
        .expect(302);
    });

expect :

    result = await app.httpRequest().get('/')
        .expect(302)
        .expect('content')
        .expect({ foo: 'bar', });
    assert(r.status===302)

## mock session
    app.mockSession({
      foo: 'bar',
      uid: 123,
    });
    return app.httpRequest() .get('/session') .expect(200)
      .expect({ session: { foo: 'bar', uid: 123, }, });

## mock  防止污染
引入 egg-mock/bootstrap 时，会自动在 afterEach 钩子中还原所有的 mock. 类似：

    describe('some test', () => {
      // before hook
      afterEach(mock.restore);

      // it tests
    });

## mock obj 属性
e.g. config:

    mock(app.config, 'baseDir', '/tmp/mockapp');
    assert(app.config.baseDir === '/tmp/mockapp');

## mock service
模拟 app/service/user 中的 get(name) 方法，让它返回一个本来不存在的用户数据。

    it('should mock fengmk1 exists', () => {
      app.mockService('user', 'get', () => {
        return {
          name: 'fengmk1',
        };
      });

模拟 app/service/user 中的 get(name) 方法调用异常：

    it('should mock service error', () => {
      app.mockServiceError('user', 'get', 'mock user service error');
      return app.httpRequest().get('/user?name=fengmk2')
        // service 异常，触发 500 响应
        .expect(500).expect(/mock user service error/);
    });

## mock httpClient
我们可以通过 `app.mockHttpclient(url, method, data)` 来 mock 掉 app.curl 和 ctx.curl 方法

    //app/controller/home.js
    async httpclient () {
        const res = await this.ctx.curl('https://eggjs.org');
        this.ctx.body = res.data.toString();
    }

mock

    app.mockHttpclient('https://eggjs.org', {
      // 模拟的参数，可以是 buffer / string / json，
      // 都会转换成 buffer
      // 按照请求时的 options.dataType 来做对应的转换
      data: 'mock eggjs.org response',
    });
    return app.httpRequest()
      .get('/httpclient')
      .expect('mock eggjs.org response');

## mock console

    //1. 不想在终端 console 输出任何日志，可以通过  来模拟
    mock.consoleLevel('NONE')