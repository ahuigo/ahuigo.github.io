---
title: Shell make
date: 2019-05-06
private:
---
# Shell make
## Specify Makefile
    -f makefile2

## variable
    x := foo
    y := $(x) bar
    y := ${x} bar
    x := later

    main:
        echo $(x)
        echo ${x}

### 定义

    VARIABLE = value
    # 在执行时扩展，允许递归扩展。

    VARIABLE := value
    # 在定义时扩展。

    VARIABLE ?= value
    # 只有在该变量为空时才设置值。

    VARIABLE += value
    # 将值追加到变量的尾端。

### variable in shell
需要一个`$$`转义：

    main:
        echo $$PATH

> 注意：shell 之间是不同的进程

## argv
    $ make test FLAG=debug

然后

    FLAG?=default_value
    test:
        echo $(FLAG)

image example

    version?=0.0.2
    image:
        echoraw $(version)
        docker image build -t slim_nginx:$(version) .
        docker tag slim_nginx:$(version) registry.docker.com/slim_nginx/slim_nginx:$(version)

    push:
        docker push registry.docker.com/slim_nginx/slim_nginx:$(version)

    test:
        echo $(version)

# 执行

    make init
    make install

合并

    make init install
