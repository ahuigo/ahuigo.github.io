---
title: Shell make
date: 2019-05-06
private:
---
# Shell make
## Specify Makefile
    -f makefile2

## env
As MadScientist pointed out, you can export individual variables with:

    export MY_VAR = foo  # Available for all targets

Or export variables for a specific target (target-specific variables):

    my-target: export MY_VAR_1 = foo
    my-target: export MY_VAR_2 = bar
    my-target: export MY_VAR_3 = baz

    my-target: dependency_1 dependency_2
        echo do something

You can also specify the `.EXPORT_ALL_VARIABLES` target to—you guessed it!—EXPORT ALL THE THINGS!!!:

    .EXPORT_ALL_VARIABLES:
    MY_VAR_1 = foo
    MY_VAR_2 = bar
    MY_VAR_3 = baz

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
