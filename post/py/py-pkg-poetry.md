---
title: python 包管理poetry
date: 2018-10-04
private: true
---

# poetry 包管理工具

poetry 是一个Python虚拟环境和依赖管理工具，另外它还提供了包管理功能，比如打包和发布。 使用 poetry 替换 pip+virtualenv 或者
pipenv

## install

    curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python

确认：

    $ poetry --version
    Poetry version 1.1.13

    $ cat  $HOME/.poetry/env
    export PATH="$HOME/.poetry/bin:$PATH"%

### 升级

    # 更新到最新版本
    poetry self update
    # 更新到指定版本
    poetry self update 0.8.0

# Config

Poetry提供了全局配置(config.toml)和特定项目的配置(poetry.toml)。

## Create config

    # 全局
    poetry config virtualenvs.create false
    # 局部
    poetry config virtualenvs.create true --local

## Reset Config

    # 全局
    poetry config virtualenvs.create --unset
    # 局部
    poetry config virtualenvs.create --local --unset

## list config

包括了全局和本地的

    poetry config --list
    poetry config --list --local

# 包管理

## install requirements

    # 类似pip -r requirements.txt
    poetry install

## add package

    # [tool.poetry.dependencies]
    poetry add <dependency_name>

    #[tool.poetry.dev-dependencies] ：配置仅用于开发的依赖包。
    poetry add <dependency_name> -D
    poetry add <dependency_name> --dev

如果想全局安装 package(默认), 但是不生效, 安装的包依赖是local的

    # 注意add pkg 是位于全局的virtual environment
    poetry config virtualenvs.create false
    # 非虚拟环境的全局安装，应该使用pip
    pip install pkg

通过以下命令可以查看到virtual environment 的site-packages 即`sys.path`：

    $ poetry shell  
    > python -m site
    sys.path = [
        ...
        '/Users/ahui/Library/Caches/pypoetry/virtualenvs/xlparser-Lh_J4C-L-py3.10/lib/python3.10/site-packages',
    ]

### 版本管理

    # ^0.1.11，它可能会更新到 0.1.19，但不会更新到 0.2.0
    poetry update pkg
    # >=3.7
    python = "3.7"

## update package

    # 更新所有依赖包
    poetry update
    poetry update --nodev

    # update specify pkg
    poetry update numpy

## remove package

不删除全局的package, 只会删除pyproject.toml

    poetry remove numpy
    poetry remove pytest -D

## 查看依赖

    poetry show
    poetry show --tree

## mirrors

    $ poetry config repositories.yourapp https://artifactory.yourapp.com/artifactory/api/pypi/pypi-dev

# virtual environment

## Create virtual environment

    poetry env use /usr/bin/python
    poetry env use python3

    # 类似pyenv 切换virtual environment
    poetry shell

## activate virtual environment

simple run

    # 如果没有创建过虚拟环境，这个命令会自动创建
    $ poetry shell
    (xlparser-Lh_J4C-L-py3.10) xlparser$ git:(master) ✗

也可以直接执行

    poetry run python app.py

## virtual environment info

    poetry env info

    # 查看virtual environment path
    $ poetry env list --full-path
    /Users/ahui/Library/Caches/pypoetry/virtualenvs/xlparser-Lh_J4C-L-py3.10 (Activated)

# Publish

## init

    poetry init

## publish config(Once)

第一次发布前配置仓库与用户帐号 To publish to PyPI, you can set your credentials for the
repository named pypi. like .pypirc

    # recommended: https://pypi.org/help/#apitoken
    poetry config pypi-token.pypi my-token
    # not recommended
    poetry config http-basic.pypi username password

私有：

    $ poetry config repositories.mypypi https://artifactory.yourapp.com/artifactory/api/pypi/pypi-dev
    $ poetry config http-basic.mypypi <username>
    $ poetry config --list

## build and publish

    # build to dist
    # --format (-f): 限制打包的格式为 wheel(whl) 或 sdist(tar.gz).  但目前只支持纯python的wheel。
    poetry build
    # publish
    poetry publish -r yourapp
