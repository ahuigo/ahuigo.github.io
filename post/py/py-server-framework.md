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
如何区分不同的URI, 一个最简单的想法是从environ变量里取出HTTP请求的信息，然后逐个判断：

	def application(environ, start_response):
		method = environ['REQUEST_METHOD']
		path = environ['PATH_INFO']
		if method=='GET' and path=='/':
			return handle_home(environ, start_response)
		if method=='POST' and path='/signin':
			return handle_signin(environ, start_response)
		...

只是这么写下去代码是肯定没法维护了。

至于URL到函数的映射，就交给Web框架来做。 我们选择一个比较流行的Web框架——Flask来使用。

用Flask 编写Web App比WSGI接口简单，我们先用pip安装Flask：

	$ pip install flask

然后写一个app.py，处理3个URL，分别是：

1. GET /：首页，返回Home；
1. GET /signin：登录页，显示登录表单；
1. POST /signin：处理登录表单，显示登录结果。

Flask通过Python的装饰器在内部自动地把URL和函数给关联起来，所以，我们写出来的代码就像这样：

	from flask import Flask
	from flask import request

	app = Flask(__name__)

	@app.route('/', methods=['GET', 'POST'])
	def home():
		return '<h1>Home</h1>'

	@app.route('/signin', methods=['GET'])
	def signin_form():
		return '''<form action="/signin" method="post">
				  <p><input name="username"></p>
				  <p><input name="password" type="password"></p>
				  <p><button type="submit">Sign In</button></p>
				  </form>'''

	@app.route('/signin', methods=['POST'])
	def signin():
		# 需要从request对象读取表单内容：
		if request.form['username']=='admin' and request.form['password']=='password':
			return '<h3>Hello, admin!</h3>'
		return '<h3>Bad username or password.</h3>'

	if __name__ == '__main__':
		app.run()

运行python app.py，Flask自带的Server在端口5000上监听：

	$ python app.py
	 * Running on http://127.0.0.1:5000/

打开浏览器，输入首页地址http://localhost:5000/：

### form

	request.form['name']来获取表单的内容。

## jinja2
使用方法

	from flask import Flask, request, render_template

	app = Flask(__name__)

	@app.route('/', methods=['GET', 'POST'])
	def home():
		return render_template('home.html')

	@app.route('/signin', methods=['GET'])
	def signin_form():
		return render_template('form.html')

	@app.route('/signin', methods=['POST'])
	def signin():
		username = request.form['username']
		password = request.form['password']
		if username=='admin' and password=='password':
			return render_template('signin-ok.html', username=username)
		return render_template('form.html', message='Bad username or password', username=username)

	if __name__ == '__main__':
		app.run()

Flask通过`render_template()`函数来实现模板的渲染。和Web框架类似，Python的模板也有很多种。Flask默认支持的模板是`jinja2`，所以我们先直接安装`jinja2`：

	$ pip install jinja2

form.html 用来显示登录表单的模板：

	<html>
	<head>
	  <title>Please Sign In</title>
	</head>
	<body>
	  {% if message %}
	  <p style="color:red">{{ message }}</p>
	  {% endif %}
	  <form action="/signin" method="post">
		<legend>Please sign in:</legend>
		<p><input name="username" placeholder="Username" value="{{ username }}"></p>
		<p><input name="password" placeholder="Password" type="password"></p>
		<p><button type="submit">Sign In</button></p>
	  </form>
	</body>
	</html>

最后，一定要把模板放到正确的templates目录下，`templates/`和`app.py` 在同级目录下

### foreach

	{% for i in page_list %}
		<a href="/page/{{ i }}">{{ i }}</a>
	{% endfor %}

除了Jinja2，常见的模板还有：

1. Mako：用`<% ... %>和${xxx}`的一个模板；
1. Cheetah：也是用<% ... %>和${xxx}的一个模板；
1. Django：Django是一站式框架，内置一个用{% ... %}和{{ xxx }}的模板。

## 其它框架
除了Flask，常见的Python Web框架还有：

1. Django：全能型Web框架；
1. web.py：一个小巧的Web框架；
1. Bottle：和Flask类似的Web框架；
1. Tornado：Facebook的开源异步Web框架。
