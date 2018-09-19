# Rollup 该支持HMR 吗?
Rollup 已经开始支持codesplit(要手动开启)，不过Rollup 本身至今还没有打算支持HMR(Hot Module Reload)。
我想主要原因在于：
1. Rollup 目前主要用于工具打包。将Rollup 用于Web App 的目前很少。
2. 利用Rollup 的插件: rollup-plugin-serve(提供开发期间的web server), rollup-plugin-livereload(提供hot reload)
也能很好很高效的开发。只是不支持hot module reload 罢了。

这导致大家对HMR 的需求不是那么大。 其实关于rollup 支持HMR 的讨论已经三年了，https://github.com/rollup/rollup/issues/50 看看这个issue, 三年来参与讨论的人也才几个。

但是HMR 是未来啊，如果能支持HMR 的话，那么开发大型web 项目的module 时，将把开发效率提升到一个新的层次。
也不用再忍受webpack 编译出来的臃肿的代码

We may do some thing like this.

    // client side(browser)
    import {x} from './mod.js'
    ObserveModule('./mod.js').then(new_module=>{
        reload(new_module).then((module)=>{
            x = module.x
        }); 
    }

    // server side (e.g. rollup-plugin-serve)
    server.listenModule = mod =>{
        OnFileChanged(mod).then(new_module=>{
            server.broadcoast_to_client(new_module); // e.g. 'mod.js?version=2'
        })
    }

Maybe we should extend the `livereload` and `rollup-plugin-serve` to support HMR.