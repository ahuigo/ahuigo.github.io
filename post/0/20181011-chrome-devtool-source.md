# Chrome devTool Source
参考文章:
- https://umaar.com/dev-tips/162-network-overrides/

我们做web 开发时常常想直接在devtools 中实时修改js/css/html 文件

chrome devtool 的source 选项卡(`cmd+6`) 正好提供了这两个功能
2. Filesystem
    - 用于直接修改本地文件 
    - chrome 会智能的将文件与localhost 请求绑定，不会cache 请求，这样(127.0.0.1)网络请求就会实时生效。
1. Overrides
    - 用于覆盖网络请求: 在`source/page`右键`save for override`或直接`edit`，保存的文件都被存储到overrides 指定目录(`按照域名建立文件夹`). 这种改写是`临时的`
    - 只能指定一个目录
    - 断点debug 时，实时修改文件，然后保存后会恢复到第一个断点，不用重新刷新
3. charles/fiddler
    1. 这个不是chrome ，但是可以用来代理、map 请求

## source map
当js 出错，定位的不是`*.min.js`, 而是通过`*.min.map` 找到`*.js`

注意这个功能，需要我们在devtool 中的设置: preference 开启 enable js/css source map

http://www.ruanyifeng.com/blog/2013/01/javascript_source_map.html