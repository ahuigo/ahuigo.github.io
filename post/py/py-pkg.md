---
title: 管理包和依赖的工具。
date: 2018-10-04
---
# 管理包和依赖的工具。

pip：Python 包和依赖关系管理工具。官网
pip-tools：保证 Python 包依赖关系更新的一组工具。官网
conda：跨平台，Python 二进制包管理工具。官网
Curdling：管理 Python 包的命令行工具。官网
wheel：Python 分发的新标准，意在取代 eggs。官网

# pip

    wget https://bootstrap.pypa.io/get-pip.py -O - | python3
    pip install -U pip # upgrade

python安装路径: sys.prefix

## cache

	rm -r ~/Library/Caches/pip

## install pip pkg 

	pip3 install requests
    pip install cryptography>=0.8.2
    pip install -U requests #升级
    pip install wechatpy[cryptography] # extra: cryptography

    $ pip3 uninstall python-highcharts
    Uninstalling python-highcharts-0.2.0:
      /usr/local/lib/python3.5/site-packages/highcharts/__init__.py

### mirrors
http://www.pypi-mirrors.org/ 
- e.pypi.python.org
- pypi.douban.com
- pypi.hustunique.com
- pypi.mirrors.ustc.edu.cn

使用时路径要包含 simple

    pip install -i https://pypi.mirrors.ustc.edu.cn/simple/ pandas 
    pip install -i https://mirrors.ustc.edu.cn/pypi/web/simple -r requirement.txt

    -i, --index-url <url>
    --extra-index-url <url>

在~/.pip/pip.conf配置文件中写入：

    [global]
    index-url = http://e.pypi.python.org/simple

### 另一个程序正在使用此文件，进程无法访问
打开c:\program files\python36\lib\site-packages\pip\compat\__init__.py约75行
编码问题，虽然py3统一用utf-8了。但win下的终端显示用的还是gbk编码。

    return s.decode('utf_8') 改为return s.decode('cp936')

## pip with file

    $ cat requirements-dev.txt
    -r requirements-ci.txt
    ipdb==0.10.1
    pytest-sugar==0.7.1
    ipython==5.1.0
    aiodns==1.1.1
    $ pip3 install -r requirements-dev.txt