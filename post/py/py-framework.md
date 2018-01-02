# framework list
0. Flask(果壳网) 很轻, 类似 bottle但对大项目组织支持更好, Flask 框架学会以后，可以考虑学习插件的使用。例如:
用 WTForm + Flask-WTForm 来验证表单数据，
用 SQLAlchemy + Flask-SQLAlchemy 来对你的数据库进行控制。
1. Django。一个全能型框架。
2. Tornado(知乎)。非阻塞IO的高性能的框架(其实非阻塞IO还有更优雅的实现方式: gevent(python2) 或 asyncio), 其他框架不支持。更注重 RESTful URL。
但 Tornado 提供了网站基本需要使用的模块外，剩下的则需要开发者自己进行扩展。例如数据库操作 torndb，
3. Bottle。Bottle 只有一个文件和 Flask 都属于轻量级的
4. Falcon: REST, a high-performance Python framework for building cloud APIs. 比Flask(1x)/Bottle(4x) 快多了Falcon(7x)
4. web.py, 轻量级的
5. web2py。Google 在 web.py 基础上二次开发而来的，兼容 GAE。性能据说很高，曾经用他来做自己的主页，感觉也还不错。缺点同样是对扩展支持不太好，需要自己进行扩展。
6. Quixote(豆瓣), 路由会有些特别。另外 Quixote 的性能据说也好。
7. liaoxuefeng 的 https://github.com/michaelliao/awesome-python-webapp/blob/release/www/transwarp/web.py
