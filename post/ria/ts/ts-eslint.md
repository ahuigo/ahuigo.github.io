---
title: Ts eslint
date: 2019-11-23
private: 
---
# Ts eslint
TypeScript 的代码检查最佳方案就是 `typescript-eslint`，提供了 TS解析器 `@typescript-eslint/parser` 和相关的配置选项 `@typescript-eslint/eslint-plugin` 等。而之前的两个 lint 解决方案都将弃用：

1. typescript-eslint-parser 已停止维护
2. TSLint 将提供迁移工具，并在 typescript-eslint 的功能足够完整后停止维护

# 什么是代码检查
代码检查主要是用来
1. 发现代码错误
2. 统一代码风格。
    1. 缩进应该是四个空格还是两个空格？
    1. 是否应该禁用 var？
    1. 接口名是否应该以 I 开头？
    1. 是否应该强制使用 === 而不是 ==？
    2. 变量未定义

# 在 TypeScript 中使用 ESLint
## 安装 ESLint
    npm install --save-dev eslint

由于 ESLint 默认使用 Espree 进行语法解析，无法识别 TypeScript 的一些语法，故我们需要安装 @typescript-eslint/parser，替代掉默认的解析器

    npm install --save-dev typescript @typescript-eslint/parser

接下来需要安装对应的插件 @typescript-eslint/eslint-plugin 它作为 eslint 默认规则的补充，提供了一些额外的适用于 ts 语法的规则。

    npm install --save-dev @typescript-eslint/eslint-plugin

或用：

    yarn add -D typescript @typescript-eslint/parser  @typescript-eslint/eslint-plugin

ts+react+vscode 另外一个测试代码见：
https://github.com/ahuigo/vscode-eslint-react-ts/tree/88a1538d3ea40d0918c5974639a6d61e92ec6290


## 创建配置文件
ESLint 需要一个配置文件来决定对哪些规则进行检查，配置文件的名称一般是 `.eslintrc.js 或 .eslintrc.json`。

> 当运行 ESLint 的时候检查一个文件的时候，它会首先尝试读取该文件的目录下的配置文件，然后再一级一级往上查找，将所找到的配置合并起来，作为当前被检查文件的配置。

我们在项目的根目录下创建一个 .eslintrc.js，内容如下：

    module.exports = {
        parser: '@typescript-eslint/parser',
        plugins: ['@typescript-eslint'],
        rules: {
            // 禁止使用 var
            'no-var': "error",
            // 优先使用 interface 而不是 type
            '@typescript-eslint/consistent-type-definitions': [
                "error",
                "interface"
            ]
        }
    }

以上配置中，我们指定了两个规则，其中:
1.  no-var 是 ESLint 原生的规则
2.  @typescript-eslint/consistent-type-definitions 是 @typescript-eslint/eslint-plugin 新增的规则。

### 规则取值
规则的取值一般是一个数组（上例中的 @typescript-eslint/consistent-type-definitions），其中第一项是 off(0)、warn 或 error 中的一个，表示关闭、警告和报错。后面的项都是该规则的其他配置。

如果没有其他配置的话，则可以将规则的取值简写为数组中的第一项（上例中的 no-var）。

### 关闭、警告和报错的含义

    关闭：禁用此规则, "off" 或0
    警告：代码检查时输出错误信息，但是不会影响到 exit code
    报错：发现错误时，不仅会输出错误信息，而且 exit code 将被设为 1（一般 exit code 不为 0 则表示执行出现错误）

### 常用规则
#### es6
es6+jsx的规则：

    {
        "parserOptions": {
            "ecmaVersion": 6,
            "sourceType": "module",
            "ecmaFeatures": {
                "jsx": true
            }
        },
        "rules": {
            "no-console": "off"
            "semi": "error"
            "semi": ["error", "always"],
        }
    }

## 禁用规则
https://eslint.org/docs/user-guide/configuring#configuring-rules

有几种：

1.直接在配置文件`.eslintrc.js` 中禁用

    "rules": {
        "no-var": "off",
        "no-console": "off",
        "no-else-return": "off",
        "semi": "off",
        "no-restricted-syntax": 0,
    }

2.disable ESLint on `a specific line` for `a specific rule` with a Javascript comment

    alert("hello"); // eslint-disable-line

    // eslint-disable-next-line 
    alert("eslint is disabled here");

    // eslint-disable-line no-use-before-define

3.disable ESLint for `a whole file` with a Javascript comment

    /* eslint-disable */
    alert("no linting here");
    /* eslint-enable */

    /* eslint-disable no-underscore-dangle */

## 检查一个 ts 文件
创建了配置文件之后，我们来检查一个新文件 index.ts：

    var myName = 'Tom';
    type Foo = {};

然后执行以下命令：

    ./node_modules/.bin/eslint index.ts

我们可以通过在 package.json 中添加一个 script 来创建一个 npm script 来简化这个步骤：

    {
        "scripts": {
            "eslint": "eslint index.ts"
        }
    }

这时只需执行 npm run eslint 即可。

## 检查整个项目的 ts 文件
我们的项目源文件一般是放在 src 目录下，所以需要将 package.json 中的 eslint 脚本改为对一个目录进行检查。由于 eslint 默认不会检查 .ts 后缀的文件，所以需要加上参数 --ext .ts：

    {
        "scripts": {
            "eslint": "eslint src --ext .ts"
        }
    }

此时执行 npm run eslint 即会检查 src 目录下的所有 .ts 后缀的文件。

# vscode 配置
## 在 VSCode 中集成 ESLint 检查
在编辑器中集成 ESLint 检查，可以在开发过程中就发现错误，甚至可以在保存时自动修复错误，极大的增加了开发效率。

### eslint 插件
在 VSCode 中，我们需要先安装 ESLint 插件

### eslint 插件支持ts
VSCode 中的 ESLint 插件默认是不会检查 .ts 后缀的，需要在`「文件 => 首选项 => 设置 => 工作区」`中（也可以在项目根目录下创建一个配置文件 `.vscode/settings.json`），添加以下配置：

    {
        "eslint.validate": [
            "javascript",
            "javascriptreact",
            "typescript"
        ],
        "typescript.tsdk": "node_modules/typescript/lib"
    }

这时再打开一个 .ts 文件，即可看到这样的报错信息了
![](/img/ts/eslint/vscode-ts-error.png)

我们还可以开启保存时自动修复的功能，通过配置：

    {
        "eslint.autoFixOnSave": true,
        "eslint.validate": [
            "javascript",
            "javascriptreact",
            {
                "language": "typescript",
                "autoFix": true
            },
        ],
        "typescript.tsdk": "node_modules/typescript/lib"
    }

## 使用 Prettier 修复格式错误
ESLint 包含了一些代码格式的检查，比如空格、分号等。但前端社区中有一个更先进的工具可以用来格式化代码，那就是 Prettier。

### 安装prettier
这一步好像可以被vscode 代替？

    npm install --save-dev prettier

### 创建prettier.config.js 或者.prettierrc.js
然后创建一个 prettier.config.js 文件，里面包含 Prettier 的配置项。Pr
这里我推荐大家一个配置规则，作为参考：

    // prettier.config.js or .prettierrc.js
    module.exports = {
        // 一行最多 100 字符
        printWidth: 100,
        // 使用 4 个空格缩进
        tabWidth: 4,
        // 不使用缩进符，而使用空格
        useTabs: false,
        // 行尾需要有分号
        semi: true,
        // 使用单引号
        singleQuote: true,
        // 对象的 key 仅在必要时用引号
        quoteProps: 'as-needed',
        // jsx 不使用单引号，而使用双引号
        jsxSingleQuote: false,
        // 末尾不需要逗号
        trailingComma: 'none',
        // 大括号内的首尾需要空格
        bracketSpacing: true,
        // jsx 标签的反尖括号需要换行
        jsxBracketSameLine: false,
        // 箭头函数，只有一个参数的时候，也需要括号
        arrowParens: 'always',
        // 每个文件格式化的范围是文件的全部内容
        rangeStart: 0,
        rangeEnd: Infinity,
        // 不需要写文件开头的 @prettier
        requirePragma: false,
        // 不需要自动在文件开头插入 @prettier
        insertPragma: false,
        // 使用默认的折行标准
        proseWrap: 'preserve',
        // 根据显示样式决定 html 要不要折行
        htmlWhitespaceSensitivity: 'css',
        // 换行符使用 lf
        endOfLine: 'lf'
    };

### Prettier 插件
接下来安装 VSCode 中的 Prettier 插件，然后修改 .vscode/settings.json. 让它自动进行`eslint检查修复`、`prettier+tab` 格式化：

    {
        "files.eol": "\n",
        "editor.tabSize": 4,
        "editor.formatOnSave": true,
        "editor.defaultFormatter": "esbenp.prettier-vscode",
        "eslint.autoFixOnSave": true,
        "eslint.validate": [
            "javascript",
            "javascriptreact",
            {
                "language": "typescript",
                "autoFix": true
            }
        ],
        "typescript.tsdk": "node_modules/typescript/lib"
    }

需要注意的是，由于 ESLint 也可以检查一些代码格式的问题，所以在和 Prettier 配合使用时，我们一般会把 **ESLint 中的代码格式相关的规则禁用掉，否则就会有冲突了**。

## 使用 AlloyTeam 的 ESLint 配置
ESLint 原生的规则和 `@typescript-eslint/eslint-plugin` 的规则太多了，而且原生的规则有一些在 TypeScript 中支持的不好，需要禁用掉。

这里我推荐使用 `AlloyTeam ESLint` 规则中的 TypeScript 版本，它已经为我们提供了一套完善的配置规则，并且与 Prettier 是完全兼容的（eslint-config-alloy 不包含任何代码格式的规则，代码格式的问题交给更专业的 Prettier 去处理）。

### 安装AlloyTeam

    npm install --save-dev eslint typescript @typescript-eslint/parser @typescript-eslint/eslint-plugin eslint-config-alloy

在你的项目根目录下创建 .eslintrc.js，并将以下内容复制到文件中即可：

    module.exports = {
        extends: [
            'alloy',
            'alloy/typescript',
        ],
        env: {
            // 这里填入你的项目用到的环境
            // 它们预定义了不同环境的全局变量，比如：
            //
            // browser: true,
            // node: true,
            // mocha: true,
            // jest: true,
            // jquery: true
        },
        globals: {
            // 这里填入你的项目需要的全局变量
            // false 表示这个全局变量不允许被重新赋值，比如：
            //
            // myGlobal: false
        },
        rules: {
            // 这里填入你的项目需要的个性化配置
        }
    };

更多的使用方法，请参考 AlloyTeam ESLint 规则

## 使用 ESLint 检查 tsx 文件
如果需要同时支持对 tsx 文件的检查，则需要对以上步骤做一些调整：

安装 eslint-plugin-react

    npm install --save-dev eslint-plugin-react

package.json 中的 scripts.eslint 添加 .tsx 后缀

    {
        "scripts": {
            "eslint": "eslint src --ext .ts,.tsx"
        }
    }

VSCode 的配置中新增 typescriptreact 检查

    {
        "files.eol": "\n",
        "editor.tabSize": 4,
        "editor.formatOnSave": true,
        "editor.defaultFormatter": "esbenp.prettier-vscode",
        "eslint.autoFixOnSave": true,
        "eslint.validate": [
            "javascript",
            "javascriptreact",
            {
                "language": "typescript",
                "autoFix": true
            },
            {
                "language": "typescriptreact",
                "autoFix": true
            }
        ],
        "typescript.tsdk": "node_modules/typescript/lib"
    }

[使用 AlloyTeam ESLint 规则中的 TypeScript React 版本](https://github.com/AlloyTeam/eslint-config-alloy#typescript-react)

# Troubleshootings
## Cannot find module '@typescript-eslint/parser'
你运行的是全局的 eslint，需要改为运行 ./node_modules/.bin/eslint。

## VSCode 没有显示出 ESLint 的报错
1. 检查「文件 => 首选项 => 设置」中有没有配置正确
1. 检查必要的 npm 包有没有安装
1. 检查 .eslintrc.js 有没有配置
1. 检查文件是不是在 .eslintignore 中
1. 如果以上步骤都不奏效，则可以在「文件 => 首选项 => 设置」中配置 "eslint.trace.server": "messages"，按 Ctrl+Shift+U 打开输出面板，然后选择 ESLint 输出，查看具体错误。

![](/img/ts/eslint/vscode-eslint-panel.png)

## 为什么有些定义了的变量（比如使用 enum 定义的变量）未使用，ESLint 却没有报错？
因为无法支持这种变量定义的检查。建议在 tsconfig.json 中添加以下配置，使 tsc 编译过程能够检查出定义了未使用的变量：

    {
        "compilerOptions": {
            "noUnusedLocals": true,
            "noUnusedParameters": true
        }
    }

## 启用了 noUnusedParameters 之后，只使用了第二个参数，但是又必须传入第一个参数，这就会报错了
第一个参数以下划线开头即可，参考 https://github.com/Microsoft/TypeScript/issues/9458

# 参考
1. 代码检查：https://github.com/xcatliu/typescript-tutorial/blob/master/engineering/lint.md