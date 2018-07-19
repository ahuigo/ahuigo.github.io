---
layout: page
title:
category: blog
description:
---
# Preface
https://packaging.python.org/tutorials/packaging-projects/

setuptools 与 disutils
1. distutils 用于包的创建与分发到Python Package Index（PyPI）,
2. setuptools 是distuils 增强，并解决包间依赖关系。

# Basic Use
我想到打包我写的一个python脚本: fileset

	$ ls your_proj/
	fileset.py
	$ cd your_proj/

## setup
```python
	$ vim setup.py
	from setuptools import setup, find_packages
	setup(
		name='pytest',
		version = "0.0.1",

        #package_dir={"": "src"},
		packages=["_pytest", "_pytest.assertion"], # dir only(dir is __init__ package)
        py_modules=["pytest"]

		include_package_data=True,
		install_requires=[
			'aiohttp',
		],
	)
```
1. 如果写的是命令，那么将命令文件直接放到: scripts = ['fileset']
2. 如果存在依赖：install_requires = [],  tests_require=[ 'pytest', ],

Another example:

```python
	from setuptools import setup, find_packages
	setup(
		name = "fileset",
		packages = find_packages(exclude=["*.tests", "*.tests.*", "tests.*", "tests"]),
		scripts = ['fileset.sh'],
		if sys.version_info >= (3,2):
			''' 如果需要其它包 '''
			install_requires=[
			   'A>=1,<2',
			   'B>=2',
			   'django-pipeline==1.1.22'
			]

		author = "ahuigo",
		author_email = "nobody@qq.com",
		description = "This is a filset Package",
		license = "GPL",
		url = "http://github.com/ahuigo/fileset",   
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

### Optional
*Optional*: 用于打包后, 传输，在其它本地机上解包，非在线安装吧
1. We can now package the script using:

	$ python setup.py sdist # This will create a dist folder containing all your distributions. 

2. After unpacking the distribution file, you can simply install it using :

	python setup.py install 
	pip install
	pip install --editable . ;# 不拷贝

## clean
    rm /usr/local/Cellar/python3/3.6.1/Frameworks/Python.framework/Versions/3.6/lib/python3.6/site-packages/pyhttp-server.egg-link

## find_packages
For very large projects, to decrease size of proj:.

	find_packages(exclude=["*.tests", "*.tests.*", "tests.*", "tests"])

## MANIFEST.in
除了python 文件外，如果要打包静态文件, 就建立MNIFEST.in, 写入：
- 包含目录用graft, 包含文件用include

    graft flaskr/templates
    graft flaskr/static
    include flaskr/schema.sql

## clean
    import os
    from setuptools import setup, Command

    class CleanCommand(Command):
        """Custom clean command to tidy up the project root."""
        user_options = []
        def initialize_options(self):
            pass
        def finalize_options(self):
            pass
        def run(self):
            os.system('rm -vrf ./build ./dist ./*.pyc ./*.tgz ./*.egg-info')

    setup(
        # ... Other setup options
        cmdclass={
            'clean': CleanCommand,
        }
    )

use:

    $ python setup.py build
    running build
    $ python setup.py clean

# Upload to PyPI

## first register PyPI simply done by typing:

    $ python3 setup.py register
    We need to know who you are, so please choose either:
    1. use your existing login,
    2. register as a new user,
    3. have the server generate a new password for you (and email it to you), or
    4. quit
    Your selection [default 1]:

Once this is done, `~/.pypirc` file will store the login name and the password. 

## The next step is to upload your package. 
create egg-info+sdist

    python3 setup.py sdist bdist_wheel

run Twine to upload all of the archives under dist:

    # twine upload --repository-url https://test.pypi.org/legacy/ dist/*
    # pip install --upgrade twine
    twine upload  dist/*

use:

    pip install --index-url https://test.pypi.org/simple/ example_pkg

# Requirements
pip freeze > requirements.txt
pip install -r requirements.txt


# cli tool
可以在setup.py 为script 加入口.

1. 第一种scripts：

    scripts=['bin/fileset.py'], # general for non python, exec:`$ fileset.py`

2. entry_points['console_scripts']：

	entry_points = {
        'console_scripts': ['fileset=bin.fileset:main', 'bin2=bin.fin2:main'],
    }
	entry_points='''
        [console_scripts]
        flaskr=bin.fileset:main
        flaskr2=bin.fileset2:main
    '''

注意，安装`pip install -e .` 之后的再`uninstall` 不会删除/usr/bin 目录下的fileset