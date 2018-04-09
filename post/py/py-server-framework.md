---
layout: page
title:
category: blog
description:
---
# Preface

# WSGI
Python内置了一个WSGI(Web Server Gateway Interface) 服务器，这个模块叫wsgiref, 它是用纯Python编写的WSGI服务器的参考实现

	def application(environ, start_response):
	    start_response('200 OK', [('Content-Type', 'text/html')])
	    return [b'<h1>Hello, web!</h1>']

	from wsgiref.simple_server import make_server
	httpd = make_server('', 8000, application)
	httpd.serve_forever()

## environ
如果你觉得这个Web应用太简单了，可以稍微改造一下，从environ里读取PATH_INFO，这样可以显示更加动态的内容：

	def application(environ, start_response):
		start_response('200 OK', [('Content-Type', 'text/html')])
		body = '<h1>Hello, %s!</h1>' % (environ['PATH_INFO'][1:] or 'web')
		return [body.encode('utf-8')]

你可以在地址栏输入用户名作为URL的一部分: `http://0:8000/xxx`，将返回Hello, xxx!：

1. 无论多么复杂的Web应用程序，入口都是一个WSGI处理函数。
2. HTTP请求的所有输入信息都可以通过environ获得，HTTP响应的输出都可以通过start_response()加上函数返回值作为Body。

# Flask 框架

## 其它框架
除了Flask，常见的Python Web框架还有：

1. Django：全能型Web框架；
1. web.py：一个小巧的Web框架；
1. Bottle：和Flask类似的Web框架；
1. Tornado：Facebook的开源异步Web框架。
