# Vercel 是什么？
它是一个一站式云托管平台，其实deno 也在做这件事（只是它更激进，目前npm兼容不好）
1. web服务托管, 不仅仅是github pages 那种静态托管，还支持
    - deployment: cicd
    - 动态托管
3. saas
包括Redis和PostgreSQL数据库以及对象存储服务，这些服务都是与Upstash、Neon和Cloudflare等合作伙伴共同打造的。此外，它还推出了新的安全功能，如Vercel保护计算和Vercel防火墙，以及为无头内容管理系统提供全新的可视化编辑体验和Vercel Spaces, 后者旨在让大型Vercel项目的管理更容易
    1. edge function:
        1. https://github.com/vercel-community/deno
    1. vercel postgres: https://neon.tech/ 由Neon驱动的无服务器SQL数据
    2. Vercel Blob: 文件存储, 由Cloudflare的对象存储服务R2驱动
    3. Vercel Runs: 将任何构建工具的构建发送到Vercel进行可视化 (如Turborepo构建）
    4. Vercel Monitoring/Logs: 监控解决方案
2. 支持多种语言和框架
nextjs
    1. SSR 支持env:
        1. 首屏渲染速度(首屏不需要js渲染)
        1. 服务预渲染
        2. SEO
        4. 缺点: 增加服务器负担
    2. CSR 不支持环境变量, hack方法:
        1. 通过mount一段特殊的js
