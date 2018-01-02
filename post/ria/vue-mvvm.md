# Preface
https://www.liaoxuefeng.com/wiki/0014316089557264a6b348958f449949df42a6d3a2e542c000/00143233918656129f4ad3ac29e4f728dc72b5d2368215a000

和后端结合的MVC模式已经无法满足复杂页面逻辑的需要了:
1. 像smarty 这种mvc 模式，JavaScript代码与后端代码绑得非常紧密:  其根本原因在于负责显示的HTML DOM模型与负责数据和交互的JavaScript代码没有分割清楚。
2. 所以，新的MVVM：Model View ViewModel模式应运而生。 MVVM最早由微软提出来，它借鉴了桌面应用程序的MVC思想，

在前端页面中，把Model用纯JavaScript对象表示：

    <script>
        var blog = {
            name: 'hello',
            summary: 'this is summary',
            content: 'this is content...'
        };
    </script>

View是纯HTML：

    <form action="/api/blogs" method="post">
        <input name="name">
        <input name="summary">
        <textarea name="content"></textarea>
        <button type="submit">OK</button>
    </form>

由于Model表示数据，View负责显示，也就是js与html 分离, Model和View关联起来的就是ViewModel:
1. ViewModel负责把Model的数据同步到View显示出来，
2. 还负责把View的修改同步回Model。

# ViewModel
可以采用已有许多成熟的MVVM框架的 ViewModel ，例如AngularJS，KnockoutJS, Vue等

## 双向绑定

