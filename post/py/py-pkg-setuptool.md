---
layout: page
title: py-pkg-setuptool
category: blog
description: 
date: 2018-10-04
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
		name='fileset',
		version = "0.0.1",

        #package_dir={"": "src"},
		packages=["_pytest", "_pytest.assertion"], # dir only(dir is __init__ package)
		packages = find_packages(exclude=["*.tests", "*.tests.*", "tests.*", "tests"]),
        py_modules=["fileset"]
		scripts = ['fileset.sh'],
		include_package_data=True,
		install_requires=[
			'aiohttp',
		],

		if sys.version_info >= (3,2):
			''' 如果需要其它包 '''
			install_requires=[
			   'A>=1,<2',
			   'B>=2',
			   'django-pipeline==1.1.22'
			]
	)
```
1. 如果写的是命令，那么将命令文件直接放到: scripts = ['fileset']
2. 如果存在依赖：install_requires = [],  tests_require=[ 'pytest', ],

### test
如果要使用setup.py 的test 命令, 使用配置依赖： setup_requires=[ 'pytest-runner', ],

test 命令使用: setup.cfg （放在setup.py 同级根目录）指定测试命令：

	[aliases]
	test=pytest

然后执行:`python3 setup.py test`

### Optional
*Optional*: 用于打包后, 传输，在其它本地机上解包，非在线安装吧
1. We can now package the script using:

	$ python setup.py sdist # This will create a dist folder containing all your distributions. 

2. After unpacking the distribution file, you can simply install it using :

	python setup.py install 
	pip install
	pip install --editable . ;# 不拷贝

## clean
    rm /usr/local/Cellar/python3/3.6.1/Frameworks/Python.framework/Versions/3.6/lib/python3.6/site-packages/pyhttp-server.egg-link

## MANIFEST.in
除了python 文件外，如果要打包静态文件, 就建立MNIFEST.in, 写入：
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
    Your selection [default 1]:

Once this is done, `~/.pypirc` file will store the login name and the password. 

    [distutils]
    index-servers =
        pypi
        ahuigo

    [pypi]
    repository: https://upload.pypi.org/legacy/
    username:ahuigo
    password:yourpasssword

    [testpypi]
    repository: https://test.pypi.org/legacy/
    username:ahuigo
    password:yourpasssword

    [ahuigo]
    repository: https://ahuigo.com/api/pypi
    username:yexuehui
    password:password

## The next step is to upload your package. 
create sdist+egg-info

    # egg 格式包
    python3 setup.py sdist 
    # wheel 格式包
    python3 setup.py bdist_wheel

一键上传：

    python setup.py sdist bdist_wheel upload -r http://test.example.com
    python setup.py sdist bdist_wheel upload -r ahuigo
    python setup.py sdist bdist_wheel upload -r pypi

## download
use:

    # 默认源
    pip install --index-url https://test.pypi.org/simple/ example_pkg
    # 额外源
    pip install --extra-index-url https://ahuigo.com/api/pypi/simple example_pkg
    pip install --extra-index-url https://ahuigo.com/api/pypi/simple example_pkg==0.0.2

指定源： ~/.pip/pip.conf:

    [global]
    index-url = http://download.zope.org/simple
    trusted-host = download.zope.org
                pypi.org
                secondary.extra.host
    extra-index-url= http://pypi.org/simple
                    http://secondary.extra.host/simple
    extra-index-url = https://<USERNAME>:<PASSWORD>@artifactory.ahuigo.com/artifactory/api/pypi/pypi/simple


# Config
## subcommand
https://stackoverflow.com/questions/1710839/custom-distutils-commands
有两种`distutils.commmands`,`cmdclass`

    entry_points={
        "distutils.commands": [
            "clean = mypackage.some_module:foo",
        ],
    },

### cmdclass
我们添加一个测试命令为例子吧：

    from setuptools.command.test import test as TestCommand

    class PyTest(TestCommand):
        def finalize_options(self):
            TestCommand.finalize_options(self)
            self.test_args = []
            self.test_suite = True
        def run_tests(self):
            #import here, cause outside the eggs aren't loaded
            import pytest
            errno = pytest.main(self.test_args)
            sys.exit(errno)
    setup(
        tests_require=['pytest'],
        cmdclass = {'test': PyTest},
    )

    # /test_main.py
    from subprocess import getoutput as sh

    class TestClass:
        def test_main(self):
            assert "Lucy" in sh('echo "Lucy,Artist,16" | xcut -f 1 -t index --no-title')

## cli tool
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

# import obj

    # Install the Q() object in sys.modules so that "import q" gives a callable q.
    sys.modules['q'] = Q()

# Requirements
    pip freeze > requirements.txt
    pip install -r requirements.txt

# install dev

    pip install -e dir 
    pip install -e /xxx/xxx
    pip install -e .

