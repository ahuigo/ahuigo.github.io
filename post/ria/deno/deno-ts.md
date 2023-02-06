---
title: deno ts 支持
date: 2022-09-13
private: true
---
# deno ts 支持
deno run 自动将ts 通过swc(不是tsc) 编译成js

## config path
https://deno.land/manual@v1.29.1/getting_started/configuration_file
1. Since v1.18, Deno will automatically detect `deno.json or deno.jsonc` in your current working directory (or parent directories)
2. manually set by `-c path/to/deno.json`

## ts compiled cache
deno run 编译是有cache的， 查看cache

    $ deno info
    DENO_DIR location: /Users/ahui/Library/Caches/deno
    Remote modules cache: /Users/ahui/Library/Caches/deno/deps
    Emitted modules cache: /Users/ahui/Library/Caches/deno/gen
    Language server registries cache: /Users/ahui/Library/Caches/deno/registries
    Origin storage: /Users/ahui/Library/Caches/deno/location_data

Check compiled files

    $ ls ~/Library/Caches/deno/gen/file/Users/ahui/.../fresh/init.ts.*
    init.ts.js
    init.ts.meta (contains a hash used for cache invalidation.)
    init.ts.buildinfo (cache to help speed up swc type checking)
    (also potentially .map files)

## type checking
you could skip type checking by:

    deno run --allow-net --no-check my_server.ts

## Determining the type of file
For local modules, Deno makes this determination
1.  based fully on the extension

For remote modules, to determine the type of the module, 
1. the media type (mime-type) is used 
1. then the path of the module is used to detected file type(when it is ambiguous what type of file it is)

mime-types:

    application/typescript	    TypeScript (with path extension influence)
    text/typescript	            TypeScript (with path extension influence)
    video/vnd.dlna.mpeg-tts	    TypeScript (with path extension influence)
    video/mp2t	                TypeScript (with path extension influence)
    application/x-typescript	TypeScript (with path extension influence)
    application/javascript	    JavaScript (with path extensions influence)
    text/javascript	            JavaScript (with path extensions influence)
    application/ecmascript	    JavaScript (with path extensions influence)
    text/ecmascript	            JavaScript (with path extensions influence)
    application/x-javascript	JavaScript (with path extensions influence)
    application/node	        JavaScript (with path extensions influence)
    text/jsx	                JSX
    text/tsx	                TSX
    text/plain	                Attempt to determine that path extension, otherwise unknown
    application/octet-stream	Attempt to determine that path extension, otherwise unknown

# compilerOptions
默认deno不需要配置ts, 不建议配置ts不兼容)，deno使用deno.json 中的`compilerOptions` 配置取代`tsconfig.json`

    $ deno run --config ./deno.json main.ts
    $ cat deno.json
    "compilerOptions": {
        "jsx": "react-jsxdev",
        "jsxImportSource": "react"

        "allowJs": true,
        "esModuleInterop": true,
        "lib": ["esnext", "dom"],
        "module": "esnext",
        "moduleResolution": "node",
        "noEmit": true,
        "pretty": true,
        "resolveJsonModule": true,
        "target": "esnext"
    },

支持的配置项有 https://deno.land/manual@v1.25.2/typescript/configuration#how-deno-uses-a-configuration-file

## lib 选项
默认是

    "compilerOptions": {
        "lib": ["deno.window"],

Setting the "noLib" option to true

    "nolib": true,

if you use the --unstable flag, Deno will change the "lib" option to 

    "lib":[ "deno.window", "deno.unstable" ]

The built-in libraries that are of interest to users:

    "deno.ns" - This includes all the custom Deno global namespace APIs (+import.meta). 
    "deno.window" - This is the "default" library(includes the "deno.ns"
            This library will conflict with lib like "dom" and "dom.iterable" 
    "deno.unstable" - This includes the addition unstable Deno global namespace APIs.
    "deno.worker" - This is the library used when checking a Deno web worker script
    "dom.asynciterable" - TypeScript currently does not include the DOM async iterables that Deno implements 

These are common libraries that Deno doesn't use by default:

    "dom" - conflict in many ways with "deno.window" 
        and so if "dom" is used, then consider using just "deno.ns" to expose the Deno APIs.
    "dom.iterable" - The iterable extensions to the browser global library.
    "scripthost" - The library for the Microsoft Windows Script Host.
    "webworker" - The main library for web workers in the browser. 
        (Like "dom" this will conflict with "deno.window" or "deno.worker")
    "webworker.importscripts" - The library that exposes the importScripts() API in the web worker.
    "webworker.iterable" - The library that adds iterables to objects within a web worker. Modern browsers support this.

all valid value:

    Argument for '--lib' option must be: 'es5', 'es6', 'es2015', 'es7', 'es2016', 'es2017', 'es2018', 'es2019', 'es2020', 'es2021', 'es2022', 'esnext', 'dom', 'dom.iterable', 'dom.asynciterable', 'dom.extras', 'webworker', 'webworker.importscripts', 'webworker.iterable', 'scripthost', 'es2015.core', 'es2015.collection', 'es2015.generator', 'es2015.iterable', 'es2015.promise', 'es2015.proxy', 'es2015.reflect', 'es2015.symbol', 'es2015.symbol.wellknown', 'es2016.array.include', 'es2017.object', 'es2017.sharedmemory', 'es2017.string', 'es2017.intl', 'es2017.typedarrays', 'es2018.asyncgenerator', 'es2018.asynciterable', 'es2018.intl', 'es2018.promise', 'es2018.regexp', 'es2019.array', 'es2019.object', 'es2019.string', 'es2019.symbol', 'es2019.intl', 'es2020.bigint', 'es2020.date', 'es2020.promise', 'es2020.sharedmemory', 'es2020.string', 'es2020.symbol.wellknown', 'es2020.intl', 'es2020.number', 'es2021.promise', 'es2021.string', 'es2021.weakref', 'es2021.intl', 'es2022.array', 'es2022.error', 'es2022.intl', 'es2022.object', 'es2022.sharedmemory', 'es2022.string', 'esnext.array', 'esnext.symbol', 'esnext.asynciterable', 'esnext.intl', 'esnext.bigint', 'esnext.string', 'esnext.promise', 'esnext.weakref', 'deno.window', 'deno.worker', 'deno.shared_globals', 'deno.ns', 'deno.unstable', 'deno.url', 'deno.cache', 'deno.console', 'deno.net', 'deno.websocket', 'deno.fetch', 'deno.broadcast_channel', 'deno.crypto', 'deno.webstorage', 'deno.web', 'deno.webgpu'.

## Target browser dom
deno默认不含有dom api，使用dom api会报错：
> Cannot find name 'document'. Do you need to change your target library? Try changing the `lib` compiler option to include 'dom'.ts(2584)

Deno could works in both Deno and the browser:

    "compilerOptions": {
        "target": "esnext",
        "lib": ["dom", "dom.iterable", "dom.asynciterable", "deno.ns"]
    }

# Type resolution
> refer: https://deno.land/manual@v1.25.2/typescript/types#using-ambient-or-global-types

tsc 在import 'm.ts' 时会尝试同目录的`m.d.ts`, deno 则需要显式import `.d.ts`

deno import ts分为两种

    As the importer of a JavaScript module,   I know what types should be applied to the module.
    As the supplier of the JavaScript module, I know what types should be applied to the module.

## import npm with specifier
Refer to https://deno.land/manual@v1.29.1/node/npm_specifiers , npm包名格式

    npm:<package-name>[@<version-requirement>][/<sub-path>]

e.g. in source

    // main.ts
    // @deno-types="npm:@types/express@^4.17"
    import express from "npm:express@^4.17";

e.g in cli

    deno run --allow-env --allow-read npm:cowsay@1.5.0 Hello there!

### 下载本地`node_module`

    deno run --node-modules-dir main.ts
    tree node_module

我们也可以只缓存`node_module`，不执行. 然后修改后再执行

    deno cache --node-modules-dir main.ts

## import url with types
Providing types when importing

### Using `@deno-types`:

    // @deno-types="./coolLib.d.ts"
    import * as coolLib from "./coolLib.js";

### Using X-TypeScript-Types header
> https://deno.land/manual@v1.29.1/advanced/typescript/types#using-x-typescript-types-header
Similar to the triple-slash directive, Deno supports a header for remote modules that instructs Deno to locate the types.

    HTTP/1.1 200 OK
    Content-Type: application/javascript; charset=UTF-8
    Content-Length: 648
    X-TypeScript-Types: ./coolLib.d.ts

e.g.

    curl -D- -L https://esm.sh/lodash/unescape
    x-typescript-types: https://esm.sh/v97/@types/lodash@^4/unescape~.d.ts


对于 Skypack.dev 这个CDN来说, 加`?dts`才会返回`X-TypeScript-Types` 

    import React from "https://cdn.skypack.dev/react?dts";

## Host js with types
If you are in control of the source code of the module. there are two ways to inform deno of types

### Using the triple-slash reference directive

    /// <reference types="./coolLib.d.ts" />

    // ... the rest source of host the JavaScript ...

也可以是url

    /// <reference types="https://deno.land/x/pkg@1.0.0/types.d.ts" />

## Using global types
First, define global types: https://deno.land/manual@v1.25.2/typescript/types#using-ambient-or-global-types 

    declare global {
        var AGlobalString: string;
    }


方法一，在UMD module ts 插入d.ts, By adding the following triple-slash directives near the `top of the entry point file` like `index.js`

    /// <reference types="https://deno.land/x/pkg@1.0.0/types.d.ts" />

另一个方法是deno.json 配置d.ts

    "compilerOptions": {
        "types": [
            "./types.d.ts", //相对deno.json 所在的目录
            "https://deno.land/x/pkg@1.0.0/types.d.ts",
            "/Users/me/pkg/types.d.ts"
        ]
    }

## Type Checking Web Workers
When Deno loads ts module in a web worker, it will auto check the module and its dependencies against the Deno web worker library. 

There are a couple of ways to instruct Deno to use the worker libraries instead of the standard Deno libraries

### triple-slash directives
By adding the following triple-slash directives near the top of the entry point file for the worker script

    /// <reference no-default-lib="true" />
    /// <reference lib="deno.worker" />

Deno will treat it as woker lib
1. The first directive ensures that no other default libraries are used(e.g. dom lib).
2. The second instructs Deno to apply the built-in Deno worker type definitions plus dependent libraries (like "esnext")

这在IDE、deno cache、deno bundle 中同样生效

### Using a configuration file
Another option is to use a configuration file 

    "compilerOptions": {
        "target": "esnext",
        "lib": ["deno.worker"]
    }

# multi version
https://stackoverflow.com/questions/60361579/how-to-support-several-versions-of-the-same-module-with-typescript

    // discord.js@11.d.ts
    declare module 'discord.js@11' {
      ...
    }

    // discord.js@12.d.ts
    declare module 'discord.js@12' {
      ...
    }

Then you can import the types like this:

    import { Guild as Guild12, version } from "discord.js";
    import { Guild as Guild11 } from "discord.js@11";

    declare const guild: Guild11 | Guild12 // obviously wouldn't be declared like this in your actual code

    // At the time of writing v12.0.2 has been released
    if (version === "12.0.2") {
        (guild as Guild12).iconURL(); // for v12
    } else {
        (guild as Guild11).iconURL; // for v11
    }

# Migrate to/from js
If you import JavaScript into TypeScript, deno will check types even if set `checkJs:false`
要么按上面的方法提供.d.ts, 要么使用下面的方法提供types或者忽略检查

## Enable type checkJs
Let Deno to infer type information about the JavaScript code by adding the check JavaScript pragma to the file

    // @ts-check

or config with

    "compilerOptions": {
        "checkJs": true
    }

## specify js type manually

    /**
     * @type {React.Context<undefined | Map<string, string>>}
    */
    const AssetContext = createContext(undefined);

    /** @type {string[]} */
    const a = [];

    /** @type{Array.<number>} */
    /** @type{Array<number>} */
    var y = [];

## specify js type via .d.ts

    /** @type {import("$fresh/plugins/twind.ts").Options} */  

## skip/ignore type checking for ts/js
skip type checking for sigle file(ts/js)

    // @ts-nocheck

skip all type checking via `deno run --no-check`

# 参考
https://deno.land/manual@v1.25.2/typescript/overview
