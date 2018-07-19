# build
    $ npm install --production

# deploy
框架也提供了 egg-scripts 来支持线上环境的运行和停止

    $ npm i egg-scripts --save
    { "scripts": {
            "start": "egg-scripts start --daemon",
            "stop": "egg-scripts stop"
    } }

## start

    $ egg-scripts start --port=7001 --daemon --title=egg-server-showcase

    --env=prod 
        框架运行环境，默认会读取环境变量 process.env.EGG_SERVER_ENV
    --framework=yadan 
        如果应用使用了自定义框架，可以配置 package.json 的 egg.framework 或指定该参数。

## start config

    //config/config.default.js
    exports.cluster = {
        listen: {
            port: 7001,
            hostname: '127.0.0.1',
            // path: '/var/run/egg.sock',
        }
    }

# 监控
1. alinode
2. NSolid

## alinode
    $ npm i nodeinstall -g
    $ nodeinstall --install-alinode ^3
    $ npm i egg-alinode --save

    // config/plugin.js
    exports.alinode = {
        enable: true,
        package: 'egg-alinode',
    };

    // config/config.default.js
    exports.alinode = {
        // 从 `Node.js 性能平台` 获取对应的接入参数
        appid: '<YOUR_APPID>',
        secret: '<YOUR_SECRET>',
    };

### 启动

    $ egg-scripts start
    [master] alinode version v3.8.4

    访问控制台 控制台地址：https://node.console.aliyun.com


