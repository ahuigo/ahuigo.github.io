---
layout: page
title: python virtualenv
category: blog
description: 
date: 2018-10-04
---
# python env
python 版本切换:
- pyenv

python pip虚拟环境:
- virtualenv 提供了 Python 虚拟环境的隔离，但是命令复杂，目录的管理也比较混乱，
    - VirtualEnvWrapper(>=python3.8) 基于 virtualenv 的一组扩展, 它提供了更简易的命令和操作。
    - 支持python3+python2
- venv, python>=3.3 自带，类似于virtualenv, 但是只支持python>=3.3
    - pyvenv 实际上是 Python 3.x 的一个模块 venv，等价于 python -m venv。
    - pyvenv-virtualenv 是一个插件：
      - >=python3.3 时它会使用python -m venv if it is available,
      - 否则使用virtualenv
    - pyvent-virtualenvwrapper(年久失修)

# pyenv(python版本切换)
用于管理python

    # mac
    brew install pyenv 

    # linux
    curl https://pyenv.run | bash
    export PYENV_ROOT="$HOME/.pyenv"
    [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)" # 自动补全

    ＃如果你用virtualenv
    eval "$(pyenv virtualenv-init -)" # 启用 pyenv-virtualenv 的自动激活和取消激活虚拟环境的功
    ＃如果你用 virtualenvwrapper 
    pyenv-virtualenvwrapper 
## 显示当前版本

    > pyenv versions
        * system (set by /home/user/.pyenv/version)
        3.6.4
        3.7.9
        3.8.19

显示安装的版本

    pyenv install --list
    pyenv global
        > system
### get python path

    pyenv which python
## 切换
pyenv 会修改环境变量, 通过在 PATH 环境变量的最前面添加一个 shims 目录来实现版本切换, shims 会自动读取当前目录的.python-version

    > 安装到 ~/.pyenv/versions/ 目录下
    pyenv install 3.6.4
    pyenv install 3.7.9
    > shim 通过./.python-version 指向3.7.9
    pyenv local 3.7.9 # 会写./.python-version
    pyenv shell 3.6 # 针对会话切换（不会存储）

恢复到没有 pyenv 时的原始环境变量，你可以删除这个 .python-version 文件：

    # 将回到 pyenv global 设置的版本，或者如果没有设置 pyenv global，则回到系统默认的 Python 版本
    rm .python-version
    pyenv global
    > system

## vscode pyenv
Open the command palette  by typing `Ctrl + Shift + P`. Then type **python: select interpreter** 

Or You can find the same option by simply clicking and selecting the interpreter from the bottom right corner of the VSCode as shown in the image below.

# venv
venv 是python自带的依赖隔离管理

    # 新隔离环境的配置./blog_dir
    python3 -m venv blog_dir
    #或者(如果没带pip)
    pyvenv --without-pip blog_dir

使用：

    $ . blog_dir/bin/activate
    (blog_pyenv) ➜ umi3$ git:(dev) ✗ 
    $ deactivate   

# virtualenv
## install

首先，我们用pip安装virtualenv：

	$ pip3 install virtualenv

然后，假定我们要开发一个新的项目，需要一套独立的Python运行环境，可以这么做：

第一步，创建目录：

	Mac:~ michael$ mkdir myproject
	Mac:~ michael$ cd myproject/
	Mac:myproject michael$

第二步，创建一个独立的Python运行环境，命名为venv：

	Mac:myproject michael$ virtualenv --no-site-packages venv
	Using base prefix '/usr/local/.../Python.framework/Versions/3.4'
	New python executable in venv/bin/python3.4
	Also creating executable in venv/bin/python
	Installing setuptools, pip, wheel...done.

命令virtualenv就可以创建一个独立的Python运行环境，我们还加上了参数--no-site-packages，这样，已经安装到系统Python环境中的所有第三方包都不会复制过来，这样，我们就得到了一个不带任何第三方包的“干净”的Python运行环境。

## start
新建的Python环境被放到当前目录下的venv目录。有了venv这个Python环境，可以用source进入该环境：

	Mac:myproject michael$ source env/bin/activate
	(venv)Mac:myproject michael$

注意到命令提示符变了，有个(venv)前缀，表示当前环境是一个名为venv的Python环境。

## packages
下面正常安装各种第三方包，并运行python命令：

	(venv)Mac:myproject michael$ pip install jinja2
	...
	Successfully installed jinja2-2.7.3 markupsafe-0.23
	(venv)Mac:myproject michael$ python myapp.py
	...

在venv环境下，用pip安装的包都被安装到venv这个环境下，系统Python环境不受任何影响。也就是说，venv环境是专门针对myproject这个应用创建的。

## *exit*
退出当前的venv环境，使用deactivate命令：

	(venv)Mac:myproject michael$ deactivate
	Mac:myproject michael$

此时就回到了正常的环境，现在pip或python均是在系统Python环境下执行。

## 原理
virtualenv是如何创建“独立”的Python运行环境的呢？原理很简单，就是把系统Python复制一份到virtualenv的环境，用命令source venv/bin/activate进入一个virtualenv环境时，virtualenv会修改相关环境变量，让命令python和pip均指向当前的virtualenv环境。

## 参考
http://www.liaoxuefeng.com/wiki/0014316089557264a6b348958f449949df42a6d3a2e542c000/001432712108300322c61f256c74803b43bfd65c6f8d0d0000

# pyenv-virtualenv
## install

    # linux
    git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv

    # mac
    brew install pyenv-virtualenv  

可选

    echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc

## 创建环境
### create virtualenv env
create a virtualenv based on Python 3.8.20 under `$(pyenv root)/versions` in a folder called my-venv38.

    pyenv virtualenv 3.8.20 my-venv38

### Create virtualenv from current version
If there is **only one** argument given to pyenv virtualenv, the virtualenv will be created with the given name based on the current pyenv Python version.

    $ pyenv version
    3.8.20
    $ pyenv virtualenv venv38

### List existing virtualenvs

    $ pyenv shell venv38
    $ pyenv virtualenvs # 跟pyenv versions 不同，它只展示`.pyenv/versions/x.x.x/envs/*`

## del环境
    pyenv uninstall venv38
    pyenv uninstall my-venv38

或者删除：

    l .pyenv/versions/3.8.20/envs/my-venv38 .pyenv/versions/3.8.20/envs/venv38
    rm -rf .pyenv/versions/3.8.20/envs/my-venv38
    rm -rf .pyenv/versions/3.8.20/envs/venv38

## 切换环境
    pyenv activate venv38
    pyenv deactivate

`Perhaps pyenv-virtualenv has not been loaded into your shell properly` 修复方法：

    # ~/.profile
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
