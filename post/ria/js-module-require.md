# require 补全
require ('../../../controller.js') 特点：
1. 路径补全 进而 代码补全
2. 相对路径

绝对路径，就不能补全喽

## NODE_PATH 绝对路径
    npm root -g 
    export NODE_PATH='dir1:dir2'; # 默认为空

PWD 固定：

    $ export NODE_PATH=$PWD && node main/index.js

PWD不固定:

    // app.js
    process.env.NODE_PATH = require('path').resolve(__dirname, '../') ;
    require('module').Module._initPaths();

    let utils = require('utils/utils'); // app/utils/utils.js

## 绝对路径补全
根目录 `jsconfig.json`(不是.js!)

    {
        "compilerOptions": {
            "target": "es6",
            "module": "commonjs",
            "baseUrl": "./",
        },
        "exclude": [
            "node_modules"
        ]
    }

## Reference
1. https://juejin.im/post/5add67986fb9a07ab83da106 by bestswifter 