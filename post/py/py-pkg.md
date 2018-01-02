# 管理包和依赖的工具。

pip：Python 包和依赖关系管理工具。官网
pip-tools：保证 Python 包依赖关系更新的一组工具。官网
conda：跨平台，Python 二进制包管理工具。官网
Curdling：管理 Python 包的命令行工具。官网
wheel：Python 分发的新标准，意在取代 eggs。官网

# pip

## cache

	rm -r ~/Library/Caches/pip

## install pip pkg 

	pip3 install requests

    $ pip3 uninstall python-highcharts
    Uninstalling python-highcharts-0.2.0:
      /usr/local/lib/python3.5/site-packages/highcharts/__init__.py

## pip with file

    $ cat requirements-dev.txt
    -r requirements-ci.txt
    ipdb==0.10.1
    pytest-sugar==0.7.1
    ipython==5.1.0
    aiodns==1.1.1
    $ pip3 install -r requirements-dev.txt
