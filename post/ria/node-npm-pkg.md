# 写npm 包
1. 生成包信息package.json
    npm init
2. https://www.npmjs.com/ 注册账号
3. `npm adduser` 添加账号
3. `npm whoami` 验证
5. `npm publish` 发布

## bin
如果要编写bin cli, 配置package.json

    "bin": {
        "egg-bin": "bin/egg-bin.js",
        "mocha": "bin/mocha.js"
    },

npm install 的bin 位于`/usr/local/bin/{mocha, egg-bin}`

## link
在插件还没发布前，可以通过 npm link 的方式进行本地测试，具体参见 npm-link

    $ cd example-app
    $ npm link ../egg-ua
    $ npm i
    $ npm test
