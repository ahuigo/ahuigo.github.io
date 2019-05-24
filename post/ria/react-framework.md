---
title: react framework
date: 2019-05-23
---
# 前端框架优化方案
本文是对目前所使用前端框架的梳理、优化。

本文优化目标是：
1. 第一目标：更好的业务开发效率
    1. KISS原则: 保持简洁、统一
       1. 统一编码风格：采用 Airbnb React 规范 
       2. 统一的接口状态返回、数据返回格式
       3. 统一文件结构
       4. 清理Warning
    2. 可复用的代码
       1. 避免写重复的代码
       2. 比如重复的 Component 初始化代码放到 BaseComponent
       2. 统一的库：geo，file, http 等
    3. UI组件化（UI、类库）
2. 第二目标：代码稳定与安全
    1. 选择成熟的工具库
    2. 引入单元测试、集成测试
    3. 代码解耦：正交原则
    4. 安全：主要是xss（暂未调研，目前看来不是主要问题）
3. 第三目标：性能优化
    1. 异步加载的引入
    2. 基于webpack 的代码拆分

## 统一文件结构

    src/
        conf/                   提供各种配置
            config.js           全局配置
        util/   非UI工具库
            file/
                mfile.js    文件库：提供文件下载、上传、格式转换
            geo/            geo 库相关的封装
                geoosm.js   
                ...
            http.js         提供xhr/fetch 封装
                自带error提示: 依赖 error ui 组件
                支持多种数据上传： form-data，array 
                支持多种格式：json, osmxml，geojson 解析
        api/
            momenta-client.js     可能需要按业务拆分
            fault.js
            traces.js
            devices.js
            .....
        components/               UI 工具库
            notice              通知组件: 确认提示、错误提示, 支持悬浮数秒后消失
            popup               悬浮组件
            map/                map ui组件: 骨架级、道路级、边栏 ...
            form                表单组件：增加数据自动填充、双向绑定; 
            table               已支持 
        assets/                 js/css 资源
            js/
            css/                支持scss, module.css

        views/
            hr/             人力资源管理:
                staff       人员CRUD 
                staff-role  角色管理: 作业人员、运营人员、管理人员
                role-auth   权限管理: 每种角色的权限
                staff-okr   人员考核
            devices/        设备管理
                千寻帐号、OTA、设备状态、密钥管理 ....
                device-trace    设备轨迹
                ...
            production/     生产管理: 骨架线、地理围栏、任务、统计
                workorder/  任务CRUD及管理: 创建、执行、领取....
                    new-workorder
                    execute-workorder
                    claim-workorder
                    workflow-def        任务、流程定义
                    package-monitor     单包监控
                    segment-monitor     段监控
                    skeleton            骨架线管理
                    ...
                collection/  采集完整性与可用性检测
                external-task/              外页任务
                    external-manager        外页任务：创建、领取、展示
                    external-monitor        外页数据监控
                    external-statistic      外页数据分析
                ....
            data-statistics/                 数据及统计分析(show 展示页面放在这里)
                upload-monitor              数据上传监控            
                trace-visualization         行驶轨迹可视化
                statistics/                 数据统计图表
                ....
                

觉得show 展示平台，不一定需要单独拆分到data-statistics。因为每一个页面，再包装一下UI，都可以成为show 页面。所以我们更缺乏的是：
1. 可视化展示: 现在做的可视化工作，比较少。单纯通过表格展示，show 的特性并不强
2. 页面UI 的包装: 功能简单，但也可以高大上

## 编码规范
> 使用 Airbnb React 规范 https://github.com/airbnb/javascript/tree/master/react

包括：
1. 命名规范
    1. 类使用 PascalCase
    2. 实例/变量用 camelCase
2. 文件import 禁用使用相对`../..` 相对路径
3. 非全局性的js/css 放在局部的`assets/` 目录

## 去除重复的代码
问题：现有的代码有很多重复代码

优化方案包括：\
1. Views 冗余的初始化代码抽到公共的BaseComponent
1. 冗余的 ErrorHandler 交给http api 低层自动处理
1. http api 基础库自动支持: 
    1. error 悬浮消息
    2. sso登录跳转
1. 配置放conf/ 里面统一管理
1. 其它...

目标是：
1. 代码简洁
2. 写法简洁：做到10行代码，变成1行调用

## 统一状态码、错误信息的结构
Restful 接口使用统一的http code 状态码：

    400    一般的客户端错误，比如参数错误、重复操作
    401    未登录。http 接口可以基于此码自动sso 登录
    500    一般的服务端错误，比如数据库异常、数据异常
    
业务返回异常，推荐：
1. 使用msg 返回错误信息(字符串)
2. 使用data 返回数据信息(数字、字符或对象)

比如

    // http code = 400
    {
        msg: "已经领取，请不要重复领取"
        data: {name:'xxx'}
    }
    // http code = 500
    {
        msg: "接口异常",
        data:{'api':'api data'}
    }

按当http code 大于等于400 时, 
Chrome 会debug 出错的data，自同时动处理popup error 消息:

![](/img/mo/error-popup.png)

## UI 组件
目前UI 组件问题：
1. 功能不完善缺乏
2. 不美观

所以 计划可以支持或改良的组件：

a. 通知组件

通知组件需要支持多行显示、可指定消失时间

![](/img/mo/error-popup.png)

b. Table 组件：支持点击column 排序

![](/img/mo/table-sort.png)

c. Map 组件

![](/img/mo/show-map.png)
![](/img/mo/show-map2.png)

d. 悬浮窗口组件支持

![](/img/mo/popup.png)

e. 其它 Form 组件的交互支持(双向绑定支持)

## 脚手架
当组件支持得比较完善了，就可以考虑利用组件建立脚手脚本 ———— 目标就是根据model **一建生成前端页面、以后后端的api**

## 统一第三方库
现在的第三方库的引用比较乱。比较时间库、geoosm 库。

应该尽量用统一的三方库：

1. 时间库选择 date-fns: 体积适中、功能强大、性能好
![](/img/mo/date-lib-compare.png)
2. geojson库 选择：osmtogeojson
3. 单元测试选择: Jest
4. 其它待讨论的库....

## 更多公用库支持
包括geo、file、http 等支持

### http 库封装
问题：
1. 现在的http 库，对数据解析支持不完善, 需要自己控制错误提示
2. 缺乏很好抽像，没有支持：array/file/formdata/osm/geojson

比如, 现在的写法就比较冗余：

    xhr(url).then(data=>{
        xhr(url2).then(data=>{
            //success
        }).catch(err=>{
            this.errorHandler(err)
        })
    }).catch(err=>{
        this.errorHandler(err)
    })

优化封装http 库:
1. 基于fetch 实现更简洁的代码
2. 自带errorHandler(依赖error ui)
3. chrome debug 记录error
4. 支持：array/file/formdata/osm/geojson

这样做的好处是写业务代码不用再写一堆的catch(但也不禁止自定义catch)

    xhr(url).then(data=>{
        xhr(url2).then(data=>{
            //success
        })
    })

## css 按需加载及文件结构
> 参考： https://blog.bitsrc.io/5-ways-to-style-react-components-in-2019-30f1ccc2b5b

React css 加载有5种, 目前项目的中的代码主要是通过css in js 来完成的。

根据node_modules/react-scripts/config/webpack.config.js 显示， React 内置webpack 提供了对css/module.css/scss 的支持：

    // style files regexes
    const cssRegex = /\.css$/;
    const cssModuleRegex = /\.module\.css$/;
    const sassRegex = /\.(scss|sass)$/;
    const sassModuleRegex = /\.module\.(scss|sass)$/;

如果第三方的提供的是原生的css, 可以采用 css module(.moduel.css) 的方式载(省去手动改写的步骤). 并且遵守一些按需要加载。

## 渐进式重构
一般而言，对老代码进行大改动是不明智的。应该采用渐进式的重构

对于一准备放弃的代码，增加deprecated 提示（比如要淘汰的xhr 库） 

    console.warn('XXXX module is deprecated')

## 测试集成
参考： https://zhuanlan.zhihu.com/p/32702421
由于我们的前端是偏内部使用，使用chrome 居多，所以考虑采用Jest、Puppeteer

采用 Jest， 基于 jasmine，Facebook 出品的painless 测试框架。
![](/img/mo/jest.png)

UI 测试，采用Google 出品的 puppeteer。简洁又强大
![](/img/mo/puppeteer.png)

## 性能优化
主要问题：
1. React 默认是单页面应用: 随着代码量越来越多，加载体积也会越大。
2. 全局性的css/js 代码: 可能导致命名冲突、代码臃肿

改进：
1. 懒加载
   1. 利用webpack 做代码分拆: https://reactjs.org/docs/code-splitting.html#code-splitting
   2. 异步加载： 利用React.lazy 与 es6 提供的 daynamic import
2. 动态路由:
   1. 得用React 提供的 :  `React Router with React.lazy`.
3. 按需加载:
   1. 使用模块化的js/css module, 按需要引用