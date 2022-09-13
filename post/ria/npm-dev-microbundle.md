---
title: npm microbundle
date: 2022-09-12
private: true
---
# npm microbundle
它是打包的利器, “zero-configuration bundler for tiny modules”.
1. 基于rollup， 0配置
2. 支持ts， 不依赖tsc(tsconfig.json)
3. ES modules, CommonJS, UMD, d.ts

## build配置
package.json 只需要

    {
    "main": "dist/index.js",
    "source": "src/index.ts"
    }

## build

    $ npx microbundle
    $ ls dist
    index.d.ts      
    index.js         index.m.js       index.umd.js
    index.js.map     index.m.js.map   index.umd.js.map

    $ cat dist/index.js
    ...
    //# sourceMappingURL=index.js.map

实时build

    $npx microbundle watch

## publish config
    {
      "// other": "fields",
      "source": "src/index.ts",
      "main": "dist/index.umd.js",
      "module": "dist/index.modern.module.js",
      "types": "dist/index.d.ts",
      "// more": "fields"
    }

## publid
    npm publish