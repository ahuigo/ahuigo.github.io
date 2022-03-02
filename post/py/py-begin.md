---
layout: page
title:	Learn Python
category: blog
description:
private: true
---
# Preface
1. py-start.md
2. py-shell.md
1. python 语法: py-grammar.md

# python3

## book
0. 峰哥的python3
1. http://www.diveintopython3.net/
1. magic: http://pycoders-weekly-chinese.readthedocs.io/en/latest/issue6/a-guide-to-pythons-magic-methods.html
2. effictive python book

async:
初探 Python 3 的异步 IO 编程:
https://www.keakon.net/2015/09/07/%E5%88%9D%E6%8E%A2Python3%E7%9A%84%E5%BC%82%E6%AD%A5IO%E7%BC%96%E7%A8%8B
https://www.keakon.net/2017/06/28/%E7%94%A8Python3%E7%9A%84async/await%E5%81%9A%E5%BC%82%E6%AD%A5%E7%BC%96%E7%A8%8B

python 魔法 py-object
http://pycoders-weekly-chinese.readthedocs.io/en/latest/issue6/a-guide-to-pythons-magic-methods.html

# interpreter, 解释器
CPython: 官方C语言写的
IPython: 基于CPython interactive 版
PyPy: 目标是执行速度。PyPy采用JIT技术，对Python代码进行动态编译
Jython: 是运行在Java平台上的Python解释器，可以直接把Python代码编译成Java字节码执行。
IronPython:是运行在微软.Net平台上的Python解释器，可以直接把Python代码编译成.Net的字节码。

# install
```
sudo yum -y install https://centos7.iuscommunity.org/ius-release.rpm
sudo yum -y install python36u python36u-pip
# env virtual
sudo yum -y install python36u-devel # 
python3.6 -m venv my_env
source my_env/bin/activate
```
## python -v:
Find python install path: python -v
1. /System/Library/Frameworks/Python.framework/Versions/ # 146M
2. /usr/local/Cellar/python3 # 128M
3. /usr/local/Cellar/python 101M

Find Python Package path: python -c 'import sys;print(sys.path)'
1. /Library/Python/ # 6M
1. /usr/local/lib/python3.6/{site-packages} 121M
1. /usr/local/lib/python2.7 #30M

注意：\
/usr/local/opt/python -> /usr/local/Cellar/python/2.7.13
/usr/local/Cellar/python/3.6.1 <- /usr/local/opt/python3

### clear

Replace python with python3:
```
do='yes'; # switch python to python3.6
mkdir -p ~/wk/py-backup
if [ $do == "yes" ]; then 
    mv /usr/local/Cellar/python/2.7.13/Frameworks/Python.framework/Versions/2.7/bin/python2.7 \
        ~/wk/py-backup
    ln -s /usr/local/Cellar/python3/3.6.1/Frameworks/Python.framework/Versions/3.6/bin/python3.6 \
        /usr/local/Cellar/python/2.7.13/Frameworks/Python.framework/Versions/2.7/bin/python2.7
    ln -s /usr/local/Cellar/python3/3.6.1/bin/python3 \
        /usr/local/Cellar/python3/3.6.1/bin/python
else
    # revert to python2.7
    ln -s ~/wk/py-backup/python2.7 \
        /usr/local/Cellar/python/2.7.13/Frameworks/Python.framework/Versions/2.7/bin/python2.7
fi
```

# Help

	$ pydoc <name>
	$ pydoc pydoc
	$ pydoc open
	$ pydoc file

## in python

	> help(file)
	var=1
	> help(var)
	> help(Requests.get)

# install

## pip3

	easy_install requests //2.7
	pip3 install requests
	import requests


