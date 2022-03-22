---
title: python 包管理poetry
date: 2018-10-04
private: true
---
# poetry 包管理工具
poetry 是一个Python虚拟环境和依赖管理工具，另外它还提供了包管理功能，比如打包和发布。
使用 poetry 替换 pip+virtualenv 或者 pipenv

## install
    brew install poetry
    # 类似pyenv 切换virtual environment
    poetry shell  
    # 类似pip -r requirements.txt
    poetry install 

# Publish
## publish config(Once)
第一次发布前配置仓库与用户帐号

    $ poetry config repositories.yourapp https://artifactory.yourapp.com/artifactory/api/pypi/pypi-dev
    $ poetry config http-basic.yourapp <username>
    $ poetry config --list 

## build and publish

    # build to dist
    poetry build
    # publish
    poetry publish -r yourapp

