---
title: Vue Cli 使用
date: 2018-10-04
---
# Vue Cli 使用
Vue CLI 是一个基于 Vue.js 进行快速开发的完整系统，提供：

1. 通过 @vue/cli 搭建交互式的项目`脚手架`: `vue create`
2. 通过 @vue/cli + `@vue/cli-service-global` 快速开始`零配置原型`开发: `vue serve`
    1. 全局安装global 这个包之后，你可以直接运行 vue serve 和 vue build 而不需要任何本地依赖：
2. 一个运行时依赖 (@vue/cli-service)，该依赖：
    1. 加载其它 `CLI 插件的核心服务`；
    1. 一个针对绝大部分应用优化过的内部的 webpack 配置；
    1. 项目内部的 vue-cli-service 命令，提供 serve、build 和 inspect 命令
3. CLI插件: 名字以 `@vue/cli-plugin-` (内建插件) 或 `vue-cli-plugin-` (社区插件) 开头
    1. Babel/TypeScript 转译、
    2. ESLint 集成、
    3. 单元测试和 end-to-end 测试等。
    4. vue-cli-service 命令时，它会自动解析并加载 package.json 中列出的所有 CLI 插件。
    5. 插件可以被归成一组可复用的 preset
4. 一套完全`图形化的创建和管理` Vue.js 项目的用户界面: `vue ui`

## 快速原型开发
global 能自动解决依赖，安装后就可以: `vue serve 和 vue build` 命令对单个 `*.vue` 文件进行快速原型开发，

    npm install -g @vue/cli-service-global
    echo '<template><h1>Hello!</h1></template>' > App.vue
    vue serve

vue 命令

    serve [options] [entry]
        serve a .js or .vue file in development mode with zero config
    build [options] [entry]
        build a .js or .vue file in production mode with zero config

    create [options] <app-name>           
        create a new project powered by vue-cli-service
    init [options] <template> <app-name>  
        generate a project from a remote template (legacy API, requires @vue/cli-init)
    add <plugin> [pluginOptions]          
        install a plugin and invoke its generator in an already created project
    invoke <plugin> [pluginOptions]       
        invoke the generator of a plugin in an already created project
    inspect [options] [paths...]
              inspect the webpack config in a project with vue-cli-service
    config [options] [value]              
        inspect and modify the config

## 创建项目
    vue create hello-world
    # 或
    vue ui

## 插件和 Preset
cli 支持的插件：`@vue/cli-plugin-` 开头的。
1. 插件可以修改 webpack 的内部配置，
2. 也可以向 vue-cli-service 注入命令

在现有的项目中安装插件：

    # 解析为完整的包名 @vue/cli-plugin-eslint，然后从 npm 安装它，
    vue add @vue/eslint
    # 等价
    vue add @vue/cli-plugin-eslint

带 @vue 前缀，该命令会换作解析一个 unscoped 的包

    # 安装并调用 vue-cli-plugin-apollo
    vue add apollo
    #  @foo/vue-cli-plugin-bar
    vue add @foo/bar

vue-router 和 vuex 的情况比较特殊——它们并没有自己的插件:

    vue add router
    vue add vuex

如果一个插件已经被安装，你可以使用 `vue invoke` 命令 **跳过** 安装过程，只调用它的生成器(修改webpack、service)
vuePlugins 选项设置在 package.json.

### 本地插件
如果你需要在项目里直接访问插件 API 而不需要创建一个完整的插件. 可是有个vuePlugins.service 指定

    {
        "vuePlugins": {
            "service": ["my-commands.js"]
        }
    }

你也可以通过 vuePlugins.ui 选项添加像 UI 插件一样工作的文件：

    { "vuePlugins": {
            "ui": ["my-ui.js"]
        } }

### Preset
1.默认值： preset 是包含创建新项目所需`预定义选项和插件`的 `JSON 对象`，让用户无需在命令提示中选择它们。

2..vuerc
在 vue create 过程中保存的 preset 会被放在你的 (~/.vuerc)

3.命令提示: 指定 "prompts": true 来允许注入命令提示：

    {
      "plugins": {
        "@vue/cli-plugin-eslint": {
          // 让用户选取他们自己的 ESLint config
          "prompts": true
        }
      }
    }

#### 远程/本地 Preset
可以通过发布 git repo 将一个 preset 分享给其他开发者。这个 repo 应该包含以下

    preset.json: 包含 preset 数据的主要文件（必需）。
    generator.js: 一个可以注入或是修改项目中文件的 Generator。
    prompts.js 一个可以通过命令行对话为 generator 收集选项的 prompts 文件。

发布 repo 后, 使用preset

    # 从 GitHub repo 使用 preset
    vue create --preset username/repo my-project
    vue create --preset gitlab:username/repo --clone my-project

也可加载本地文件系统中的 Preset

    # ./my-preset 应当是一个包含 preset.json 的文件夹
    vue create --preset ./my-preset my-project

    # 或者，直接使用当前工作目录下的 json 文件：
    vue create --preset my-preset.json

## 使用命令
@vue/cli-service 提供 vue-cli-service 命令

    {
      "scripts": {
        "serve": "vue-cli-service serve",
        "build": "vue-cli-service build"
      }
    }

调用方法:

    npm run serve
    npx vue-cli-service serve ; # ./node_modules/.bin/vue-cli-service
    yarn serve

### vue-cli-service serve
entry 默认自动发现入口, main.js

    用法：vue-cli-service serve [options] [entry]

    选项：
    --open    在服务器启动时打开浏览器
    --copy    在服务器启动时将 URL 复制到剪切版
    --mode    指定环境模式 (默认值：development)
    --host    指定 host (默认值：0.0.0.0)
    --port    指定 port (默认值：8080)
    --https   使用 https (默认值：false)

### vue-cli-service build 

    用法：vue-cli-service build [options] [entry|pattern]
    --mode        指定环境模式 (默认值：production)
    --dest        指定输出目录 (默认值：dist)
    --modern      面向现代浏览器不带自动回退地构建应用
    --target      app | lib | wc | wc-async (默认值：app)
    --name        库或 Web Components 模式下的名字 (默认值：package.json 中的 "name" 字段或入口文件名)
    --no-clean    在构建项目之前不清除目标目录
    --report      生成 report.html 以帮助分析包内容
    --report-json 生成 report.json 以帮助分析包内容
    --watch       监听文件变化

### vue-cli-service inspect
你可以使用 vue-cli-service inspect 来审查一个 Vue CLI 项目的 webpack config

    vue-cli-service inspect [options] [...paths]
        --mode    指定环境模式 (默认值：development)

    vue-cli-service inspect > output.js

### help

    npx vue-cli-service help

## 缓存和并行处理
1. `cache-loader` 会默认为 Vue/Babel/TypeScript 编译开启。
文件会缓存在 node_modules/.cache 中——如果你遇到了编译方面的问题，记得先删掉缓存目录之后再试试看。

2. `thread-loader` 会在多核 CPU 的机器上为 Babel/TypeScript 转译开启。

## GitHook
package.json 的 gitHooks 字段中方便地指定 Git hook：

    {
      "gitHooks": {
        "pre-commit": "lint-staged"
      }
    }

## 配置
### 全局.vuerc
有些针对 @vue/cli 的全局配置，例如你惯用的包管理器和你本地保存的 preset，都保存在 home 目录下一个名叫 .vuerc 的 JSON 文件。

vue config 命令用来审查或修改全局的 CLI 配置。

    vue config 

### vue.config.js
除了通过命令行参数，你也可以使用 vue.config.js 里的 devServer 字段配置开发服务器。
> vue.config.js 是一个可选的配置文件(和 package.json 同级的), 它会被 @vue/cli-service 自动加载。
> 你也可以使用 package.json 中的 vue 字段

## 开发
### 浏览器兼容性
https://cli.vuejs.org/zh/guide/browser-compatibility.html#usebuiltins-usage
1. browserslist: vue.config.js 指定浏览器范围
2. polyfill:  
    1. Vue CLI 项目会使用 @vue/babel-preset-app: 它通过 @babel/preset-env 和 browserslist 配置来决定项目需要的 polyfill。
        1. 默认的`useBuiltIns: 'usage'` 传递给 @babel/preset-env，根据源码自动检测需要的  polyfill 
    3. 如果某依赖需要特殊的 polyfill，默认情况下 Babel 无法将其检测出来, 则要手动指定
        1. 如果该依赖基于一个目标环境不支持的 ES 版本撰写: 
            1. 将其添加到 vue.config.js 中的 transpileDependencies 选项。这会为该依赖同时开启语法语法转换
        2. 果该依赖交付了 ES5 代码并显式地列出了需要的 polyfill:
            1. 可以使用 @vue/babel-preset-app 的 polyfills 选项预包含所需要的 polyfill
            ```
            // babel.config.js
            module.exports = {
                presets: [
                    ['@vue/app', {
                    polyfills: [
                        'es6.promise',
                        'es6.symbol'
                    ]
                    }]
                ]
            }
            ```
        3. 如果该依赖交付 ES5 代码，但使用了 ES6+ 特性且没有显式地列出需要的 polyfill (例如 Vuetify)
            1. 使用babel `useBuiltIns: 'entry'` 然后在入口文件添加 `import '@babel/polyfill'`。
            2. 这会根据 browserslist 目标导入所有 polyfill(但是因为包含了一些没有用到的 polyfill)

现代模式：

    vue-cli-service build --modern

### HTML 和静态资源
#### public/index.html
public/index.html 文件是一个会被 html-webpack-plugin 处理的模板。在构建过程中，资源链接会被自动注入
1. Vue CLI 也会自动注入 resource hint (preload/prefetch、manifest 和图标链接 (当用到 PWA 插件时) 
2. 以及构建过程中处理的 JavaScript 和 CSS 文件的资源链接

#### load template
你可以使用 lodash template 语法插入内容：

    <%= VALUE %> 用来做不转义插值；
    <%- VALUE %> 用来做 HTML 转义插值；
    <% expression %> 用来描述 JavaScript 流程控制。

除了被 html-webpack-plugin 暴露的默认值之外，所有客户端环境变量也可以直接使用。例如，BASE_URL 的用法：

    //vue.config.js 中的 baseUrl 选项相符
    <link rel="icon" href="<%= BASE_URL %>favicon.ico">

在模板中，你首先需要向你的组件传入基础 URL：

    data () {
        return {
            baseUrl: process.env.BASE_URL
        }
    }

#### Preload
是一种 resource hint，用来指定页面加载后很快会被用到的资, 览器开始主体渲染之前尽早 preload。

    <link rel="preload"> 

#### Prefetch
`<link rel="prefetch">` 是一种 resource hint，用来告诉浏览器在页面加载完成后，利用空闲时间提前获取用户未来可能会访问的内容。

Vue CLI 应用会为所有作为 async chunk 生成的 JavaScript 文件 (通过动态 import() 按需 code splitting 的产物) 自动生成 prefetch 提示。

这些提示可以通过 chainWebpack 的 config.plugin('prefetch') 进行修改和删除。

    // vue.config.js
    module.exports = {
      chainWebpack: config => {
        config.plugin('prefetch').tap(options => {
          options[0].fileBlacklist = options[0].fileBlacklist || []
          options[0].fileBlacklist.push([/myasyncRoute(.)+?\.js$/])
          return options
        })
      }
    }

当 prefetch 插件被禁用时，你可以通过 webpack 的内联注释手动选定要提前获取的代码区块：

    import(/* webpackPrefetch: true */ './someAsyncComponent.vue')

#### 不生成 index
当基于已有的后端使用 Vue CLI 时，你可能不需要生成 index.html，这样生成的资源可以用于一个服务端渲染的页面。
这时可以向 vue.config.js 加入下列代码：

    // vue.config.js
    module.exports = {
      // 去掉文件名中的 hash
      filenameHashing: false,
      // 删除 HTML 相关的 webpack 插件
      chainWebpack: config => {
        config.plugins.delete('html')
        config.plugins.delete('preload')
        config.plugins.delete('prefetch')
      }
    }

然而这样做并不是很推荐，因为：

    硬编码的文件名不利于实现高效率的缓存控制。
    硬编码的文件名也无法很好的进行 code-splitting (代码分段)，因为无法用变化的文件名生成额外的 JavaScript 文件。
    硬编码的文件名无法在现代模式下工作。

#### 构建一个多页应用
CLI 支持使用 vue.config.js 中的 pages 选项构建

#### 处理静态资源
静态资源可以通过两种方式进行处理：
1. 在 JavaScript 被导入或在 template/CSS 中通过相对路径被引用。这类引用会被 webpack 处理。
2. 放置在 public 目录下或通过绝对路径被引用。这类资源将会直接被拷贝，而不会经过 webpack 的处理。

##### 从相对路径导入
例如，url(./image.png) 会被翻译为 require('./image.png')，而：

    <img src="./image.png">
    #将会被编译到：
    h('img', { attrs: { src: require('./image.png') }})

在其内部，我们通过 file-loader 用版本哈希值和正确的公共基础路径来决定最终的文件路径，再用 url-loader 将小于 10kb 的资源内联，以减少 HTTP 请求的数量。

##### URL 转换规则
1. URL `/images/foo.png` 它将会被保留不变。
1. URL 以 `.` 开头，它会作为一个`相对模块请求被解释`且基于`你的文件系统中的目录结构`进行解析。
1. URL 以 `~` 开头，其后的任何内容都会`作为一个模块请求`被解析。这意味着你甚至可以引用 Node 模块中的资源：
    `<img src="~/some-npm-package/foo.png">`
1. URL 以 `@` 开头，它也会`作为一个模块请求被解析`。
    1. 它的用处在于 Vue CLI 默认会设置一个指向 `<projectRoot>/src` 的别名 @。(仅作用于模版中)

##### public 文件夹
public 中的静态资源会被复制到输出目录中, 而不经过 webpack。你需要通过绝对路径来引用它们。

推荐将资源作为你的模块依赖图的一部分导入，这样它们会通过 webpack 的处理并获得如下好处：

1. 脚本和样式表会被压缩且打包在一起，从而避免额外的网络请求。
1. 文件丢失会直接在编译时报错，而不是到了用户端才产生 404 错误。
1. 最终生成的文件名包含了内容哈希，因此你不必担心浏览器会缓存它们的老版本。

### Es6 module

    //vue.config.js
    module.exports = {
        configureWebpack: {
            devtool: 'source-map',
            externals: {
                'vueRouter':'vueRouter', // import VueRouter from 'vueRouter'
            },
        },
    }


## 构建目标
当你运行 vue-cli-service build 时，你可以通过 --target 选项指定不同的构建目标

### 库
> 注意对 Vue 的依赖, 在库模式中，Vue 是外置的。这意味着包中不会有 Vue，即便你在代码中导入了 Vue。

你可以通过下面的命令将一个单独的入口构建为一个库：

    $ vue-cli-service build --target lib --name myLib [entry]
    File                     Size                     Gzipped
    dist/myLib.umd.min.js    13.28 kb                 8.42 kb
    dist/myLib.umd.js        20.95 kb                 10.22 kb

这个入口可以是一个 .js 或一个 .vue 文件。如果没有指定入口，则会使用 src/App.vue。

#### Vue vs. JS/TS 入口文件
1. 当使用一个 .vue 文件作为入口时，你的库会直接暴露这个 Vue 组件本身，因为组件始终是默认导出的内容。
2. 当你使用一个 .js 或 .ts 文件作为入口时, 默认具名导出。
    1. 如果你没有任何具名导出并希望直接暴露默认导出，你可以在 vue.config.js 中使用以下 webpack 配置`default`：
    2. `configureWebpack: { output: { libraryExport: 'default' } }`

### Web Components 组件(wc)
你可以通过下面的命令将一个单独的入口构建为一个 Web Components 组件：

    # 入口应该是一个 *.vue 文件
    vue-cli-service build --target wc --name my-element [entry]

这个模式允许你的组件的使用者以一个普通 DOM 元素的方式使用这个 Vue 组件：

    <script src="https://unpkg.com/vue"></script>
    <script src="path/to/my-element.js"></script>

    <!-- 可在普通 HTML 中或者其它任何框架中使用 -->
    <my-element></my-element>

#### 多wc 组件
--name 将会用于设置前缀, 比如一个名为 HelloWorld.vue 的组件携带 --name foo 将会生成的自定义元素名为 `<foo-hello-world>`。

    $ vue-cli-service build --target wc --name foo 'src/components/*.vue'
    dist/foo.min.js    12.67 kb                    3.86 kb
    dist/foo.js        36.92 kb                    7.95 kb

#### 异步wc 组件
异步 Web Components 模式会生成一个 code-split 的包，带一个只提供所有组件共享的运行时，并预先注册所有的自定义组件小入口文件。

    $ vue-cli-service build --target wc-async --name foo 'src/components/*.vue'
    dist/foo.0.min.js    12.80 kb                    8.09 kb
    dist/foo.min.js      7.45 kb                     3.17 kb
    dist/foo.1.min.js    2.91 kb                     1.02 kb
    dist/foo.js          22.51 kb                    6.67 kb
    dist/foo.0.js        17.27 kb                    8.83 kb
    dist/foo.1.js        5.24 kb                     1.64 kb

一个组件真正的实现只会在页面中用到自定义元素相应的一个实例时按需获取：

    <script src="https://unpkg.com/vue"></script>
    <script src="path/to/foo.min.js"></script>

    <!-- foo-one 的实现的 chunk 会在用到的时候自动获取 -->
    <foo-one></foo-one>

## 部署
to https://github.com/<USERNAME>/<REPO>, set baseUrl to "/<REPO>/". 

    // vue.config.js
    module.exports = {
      baseUrl: process.env.NODE_ENV === 'production'
        ? '/REPO/'
        : '/'
    }

## Debug with vscode for chrome
vscode https://vuejs.org/v2/cookbook/debugging-in-vscode.html

    // vue.config.js
    module.exports = {
        configureWebpack: {
            devtool: 'source-map'
        }
    }

然后
1. vue-cli 配置并生成source-map
2. vscode下载： debugger for chrome
3. vscode 在lanuch.json 添加: chrome lanuch
4. F5

### HMR
vue-cli 默认支持webpack HMR
https://zhuanlan.zhihu.com/p/30669007