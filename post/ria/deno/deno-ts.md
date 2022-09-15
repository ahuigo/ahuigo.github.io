---
title: deno ts 支持
date: 2022-09-13
private: true
---
# deno ts 支持
deno run 自动将ts 通过swc(不是tsc) 编译成js

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
you could skip type checking

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

# config ts
默认deno不需要配置ts, 不建议配置ts不兼容)，deno使用deno.json 中的compilerOptions 配置取代`tsconfig.json`

    deno run --config ./deno.json main.ts

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

## Targeting Deno and the Browser
code works in both Deno and the browse:

    "compilerOptions": {
        "target": "esnext",
        "lib": ["dom", "dom.iterable", "dom.asynciterable", "deno.ns"]
    }

# Type resolution
> refer: https://deno.land/manual@v1.25.2/typescript/types#using-ambient-or-global-types

tsc 在import 'm.ts' 时会尝试同目录的`m.d.ts`, deno 则需要显式import `.d.ts`

deno import ts有增强方案

    As the importer of a JavaScript module, I know what types should be applied to the module.
    As the supplier of the JavaScript module, I know what types should be applied to the module.

## Providing types when importing
via `@deno-types`:

    // @deno-types="./coolLib.d.ts"
    import * as coolLib from "./coolLib.js";

## Providing types when hosting
If you are in control of the source code of the module. there are two ways to inform deno of types

### Using the triple-slash reference directive

    /// <reference types="./coolLib.d.ts" />

    // ... the rest of the JavaScript ...

也可以是url

    /// <reference types="https://deno.land/x/pkg@1.0.0/types.d.ts" />

如果是ts 源码：

    export { ErrorInfo, PreactContext, Ref as PreactRef } from '../../src/index.d.ts';

### Using X-TypeScript-Types header
Similar to the triple-slash directive, Deno supports a header for remote modules that instructs Deno to locate the types.

    HTTP/1.1 200 OK
    Content-Type: application/javascript; charset=UTF-8
    Content-Length: 648
    X-TypeScript-Types: ./coolLib.d.ts

## Using global types
define global types: https://deno.land/manual@v1.25.2/typescript/types#using-ambient-or-global-types 

    declare global {
        var AGlobalString: string;
    }


方法一，在UMD module ts 插入d.ts, By adding the following triple-slash directives near the top of the entry point file

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

## bundle types(cdn)
For a lot of the .d.ts files available on the web, they may not be compatible with Deno.

Some solution providers, like the Skypack CDN, will automatically **bundle type declarations** just like they provide bundles of JavaScript as ESM.

### cdn with types
Skypack.dev is a CDN which provides type declarations (via the `X-TypeScript-Types header`) when you append `?dts`:

    import React from "https://cdn.skypack.dev/react?dts";

## Behavior of JavaScript when type checking
If you import JavaScript into TypeScript, deno will check types even if set `checkJs:false`

# migrate to/from js
## type check js
Let Deno to infer type information about the JavaScript code by adding the check JavaScript pragma to the file

    // @ts-check

or config with

    "compilerOptions": {
        "checkJs": true
    }

## specify js type manually

    /** @type {string[]} */
    const a = [];
    /** @type{Array.<number>} */
    /** @type{Array<number>} */
    var y = [];

## specify js type via import

    /** @type {import("$fresh/plugins/twind.ts").Options} */  

## skip type checking for ts/js
skip type checking for sigle file(ts/js)

    // @ts-nocheck

skip all type checking via `deno run --no-check`


# 参考
https://deno.land/manual@v1.25.2/typescript/overview
