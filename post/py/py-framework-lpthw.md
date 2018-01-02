---
layout: page
title:
category: blog
description:
---
# Preface

# lpthw
> http://learnpythonthehardway.org/book/ex50.html

## Install lpthw

	easy_install lpthw.web

	mcd projects/gothonweb
	mkdir bin gothonweb tests docs templates
	touch gothonweb/__init__.py
	touch tests/__init__.py

## Edit `bin/app.py`:

	import web

	urls = (
	  '/hello', 'Index',
	  '/count', 'count',
	  '/go', 'go',
	)

	app = web.application(urls, globals())

	//render = web.template.render('templates/')
	render = web.template.render('templates/', base="layout")

	class Index(object):
		def GET(self):
			return render.hello_form()

		def POST(self):
			form = web.input(name="Nobody", greet=None)
			greeting = "%s, %s" % (form.greet, form.name)
			return render.index(greeting)

	class go(object):
		def GET(self):
			web.seeother('/count')

	if __name__ == "__main__":
		app.run()

## edit `templates/index.html`

	$def with (greeting)
	$if greeting:
		I just wanted to say <em style="color: green; font-size: 2em;">$greeting</em>.
	$else:
		<em>Hello</em>, world!

templates/hello_form.html:

	<h1>Fill Out This Form</h1>
	<form action="/hello" method="POST">
		A Greeting: <input type="text" name="greet">
		<br/>
		Your Name: <input type="text" name="name">
		<br/>
		<input type="submit">
	</form>

templates/layout.html

	$def with (content)
	<html>
	<head>
		<title>Gothons From Planet Percal #25</title>
	</head>
	<body>
		$:content
	</body>
	</html>

## run

	python bin/app.py
	http://127.0.0.1:8080/hello?name=hilojack

## nose
> An example in `http://learnpythonthehardway.org/book/ex47.html`

Unit Test Tool, Write a test in `./tests/<name>_tests.py`, and touch `touch ./tests/__init__.py`


	from nose.tools import *
	from ex47.game import Room

	def test_<item1>():
		assert_equal(obj.name, "GoldRoom")
		assert reg.matches(resp.data), "Response does not match %r" % matches

Then run `nosetests`

> for more: `pydoc nose.tools`

## test
tests/tools.py

	from nose.tools import *
	import re

	def assert_response(resp, contains=None, matches=None, headers=None, status="200"):

		assert status in resp.status, "Expected response %r not in %r" % (status, resp.status)

		if status == "200":
			assert resp.data, "Response data is empty."

		if contains:
			assert contains in resp.data, "Response does not contain %r" % contains

		if matches:
			reg = re.compile(matches)
			assert reg.matches(resp.data), "Response does not match %r" % matches

		if headers:
			assert_equal(resp.headers, headers)

tests/app_tests.py:

	from nose.tools import *
	from bin.app import app
	from tests.tools import assert_response

	def test_index():
		# check that we get a 404 on the / URL
		resp = app.request("/")
		assert_response(resp, status="404")

		# test our first GET request to /hello
		resp = app.request("/hello")
		assert_response(resp)

		# make sure default values work for the form
		resp = app.request("/hello", method="POST")
		assert_response(resp, contains="Nobody")

		# test that we get expected values
		data = {'name': 'Zed', 'greet': 'Hola'}
		resp = app.request("/hello", method="POST", data=data)
		assert_response(resp, contains="Zed")

The lpthw.web framework has a very simple API for processing requests, which looks like this:
(This works without running an actual web server )

	app.request(localpart='/', method='GET', data=None, host='0.0.0.0:8080',
            headers=None, https=False)

## session
`bin/session.py` and create `/sessions/` Directory to store sessions

	import web

	web.config.debug = False

	urls = (
		"/count", "count",
		"/reset", "reset"
	)
	app = web.application(urls, locals())
	store = web.session.DiskStore('sessions')
	session = web.session.Session(app, store, initializer={'count': 0})

	class count:
		def GET(self):
			session.count += 1
			return str(session.count)

	class reset:
		def GET(self):
			session.kill()
			return ""

	if __name__ == "__main__":
		app.run()

session bug for builtin-server, 2 sessions be created:
http://webpy.org/cookbook/session_with_reloader
