---
layout: page
title:
category: blog
description:
---
# Preface
https://marthall.github.io/blog/how-to-package-a-python-app/
http://flask.pocoo.org/docs/0.12/tutorial/packaging/

setuptools 与 disutils
1. distutils 用于包的创建与分发到Python Package Index（PyPI）,
2. setuptools 是distuils 增强，并解决包间依赖关系。

# Basic Use
我想到打包我写的一个python脚本: fileset

	$ ls your_proj/
	fileset
	$ cd your_proj/

## setup
```python
	$ vim setup.py
	from setuptools import setup, find_packages
	setup(
		name = "fileset",
		version = "0.1",
		packages = find_packages(exclude=["*.tests", "*.tests.*", "tests.*", "tests"]),
		scripts = ['fileset'],
		if sys.version_info >= (3,2):
			''' 如果需要其它包 '''
			install_requires=[
			   'A>=1,<2',
			   'B>=2',
			   'django-pipeline==1.1.22'
			]

		# 如果Pyhton2.7 则需要mock
		extras_require={
		    ':python_version=="2.7"': ["mock"],
		},


		# metadata for upload to PyPI
		author = "ahui132",
		author_email = "a132811@gmail.com",
		description = "This is a filset Package",
		license = "GPL",
		keywords = "fileset",
		url = "http://github.com/ahui132/",   # project home page, if any
		# could also include long_description, download_url, classifiers, etc.
	)
```
1. 如果写的是命令，那么将命令文件直接放到: scripts = ['fileset']
2. 如果存在依赖：install_requires = [],  tests_require=[ 'pytest', ],

Another example:

```python
	setup(
		name='flaskr',
		packages=['flaskr'],
		include_package_data=True,
		install_requires=[
			'flask',
		],
		tests_requires=[
			'pytest',
		],
	)
```

如果要使用setup.py 的test 命令， 所需要的包放在: setup_requires：
	setup_requires=[
        'pytest-runner',
    ],

test 命令使用: setup.cfg （放在setup.py 同级根目录）指定测试命令：

	[aliases]
	test=pytest

然后执行:`python3 setup.py test`

### 包含静态文件
除了python 文件外，如果要打包静态文件, 就建立MNIFEST.in, 写入：
```s
graft flaskr/templates
graft flaskr/static
include flaskr/schema.sql
```

### Optional
*Optional*: 用于打包后, 传输，在其它本地机上解包，非在线安装吧
1. We can now package the script using:
```
	$ python setup.py sdist # This will create a dist folder containing all your distributions. 
```
2. After unpacking the distribution file, you can simply install it using :
```s
python setup.py install 
pip install

pip install --editable .
```

## find_packages
For very large projects, to decrease size of proj:.

	find_packages(exclude=["*.tests", "*.tests.*", "tests.*", "tests"])


# Upload to PyPI
## first register PyPI simply done by typing:
```
$ python3 setup.py register
running register
We need to know who you are, so please choose either:
1. use your existing login,
2. register as a new user,
3. have the server generate a new password for you (and email it to you), or
4. quit
Your selection [default 1]:
```
Once this is done, register will ask you if you want to save your login information in the `~/.pypirc` file. By default, this will store the login name and the password. 

## The next step is to upload your package. 
Just type below, and the package is now available on PyPI! 
```s
python setup.py sdist upload
```

You can save a few keystrokes by doing it all in one command: 
```s
python3 setup.py register sdist upload
```

# Requirements
pip freeze > requirements.txt
pip install -r requirements.txt

