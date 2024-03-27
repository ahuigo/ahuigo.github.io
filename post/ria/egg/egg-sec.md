---
title: Eggjs 之 Security
date: 2018-10-04
---
# Security
## XSS
利用 extend 机制扩展了 Helper API, 提供了各种模板过滤函数，防止钓鱼

    # for html escape
    foo = "${this.helper.escape(foo)}"

    # for html script 
    const value = `<a href="http://www.domain.com">google</a><script>evilcode…</script>`;
    {{ helper.shtml(value) }}
        <a href="http://www.domain.com">google</a>&lt;script&gt;evilcode…&lt;/script&gt;

    # for js
    foo = "${this.helper.sjs(foo)}"
        "hello" => \"hello\"

    # for url
    <a href="helper.surl($value)" />
        <a href="http://ww.safe.com&lt;script&gt;" />


## csrf
Cross-site request forgery跨站请求伪造

    exports.security = {
      csrf: {
        // 判断是否需要 ignore 的方法，请求上下文 context 作为第一个参数
        ignore: ctx => isInnerIp(ctx.ip),
      },
    }

防范：
1. Synchronizer Tokens：通过响应页面时将 token 渲染到页面上，在 form 表单提交的时候通过隐藏域提交上来。
3. Referer: Referer 值会泄露用户的访问来源