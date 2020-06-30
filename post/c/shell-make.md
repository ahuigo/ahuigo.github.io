---
title: Shell make
date: 2019-05-06
private:
---
# Shell make
> refer to : http://www.ruanyifeng.com/blog/2015/02/make.html
## Specify Makefile
    -f makefile2

# variable
### 定义变量
变量定义时`=`两边可以有空格，这一点不像shell 那样严格

    # 在执行时扩展，允许递归扩展。
    VARIABLE = value

    # 在定义时扩展。
    VARIABLE := value

    # 只有在该变量为空时才设置值。
    VARIABLE ?= value

    # 将值追加到变量的尾端。
    VARIABLE += value

e.g:

    x := foo
    y := $(x) bar
    y := ${x} bar
    x := later

    main:
        echo $(x)
        echo ${x}

读取环境变量时，要用`$$`转义，否则make 会解析`$` 为自己的变量

    echo $$HOME

make 变量有make 的语法，不是由shell 语法，

    LDFLAGS += -X "main.Version=$(shell git rev-parse HEAD)"
    GO := GO111MODULE=on go

### 环境变量 variable in shell
As MadScientist pointed out, you can export individual variables with:

    export MY_VAR = foo  # Available for all targets

Or export variables for a specific target (target-specific variables):

    my-target: export MY_VAR_1 = foo
    my-target: export MY_VAR_2 = bar
    my-target: export MY_VAR_3 = baz

    my-target: dependency_1 dependency_2
        echo do something

You can also specify the `.EXPORT_ALL_VARIABLES` target to EXPORT ALL THE THINGS!!!:(不用加`export`前缀)

    .EXPORT_ALL_VARIABLES:
    MY_VAR_1 = foo
    MY_VAR_2 = bar
    MY_VAR_3 = baz

使用环境变量需要一个`$$`转义：

    main:
        echo $$PATH

> 注意：shell 之间是不同的进程

### 内置变量
$(CC) 指向当前使用的编译器

    output:
        $(CC) -o output input.c

### 自动变量（Automatic Variables）
#### $@ 指代当前目标

    a.txt b.txt: 
        touch $@

等同于下面的写法。

    a.txt:
        touch a.txt
    b.txt:
        touch b.txt

#### `$<`
`$<` 指代第一个前置条件。

    a.txt: b.txt c.txt
        cp $< $@ 

等同于下面的写法。

    a.txt: b.txt c.txt
        cp b.txt a.txt 

#### `$?`
指代比目标更新的所有前置条件，之间以空格分隔。比如，规则为 t: p1 p2，其中 p2 的时间戳比 t 新，$?就指代p2。

#### `$^`
指代所有前置条件，之间以空格分隔。

    比如，规则为 t: p1 p2，那么 $^ 就指代 p1 p2 。

#### `$*`
指代匹配符 % 匹配的部分， 

    比如% 匹配 f1.txt 中的f1 ，$* 就表示 f1。

#### `$(@D) 和 $(@F)`
`$(@D) 和 $(@F)` 分别指向 `$@` 的目录名和文件名。

    比如，$@是 src/input.c，
    那么$(@D) 的值为 src ，$(@F) 的值为 input.c。

#### `$(<D) 和 $(<F)`
`$(<D) 和 $(<F)` 分别指向 `$<` 的目录名和文件名。



    dest/%.txt: src/%.txt
        @[ -d dest ] || mkdir dest
        cp $< $@

## argv
传变量的方法为

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

# 执行指令

    make init
    make install

合并

    make init install

## 指令目标
如果当前目录有文件叫做clean，那么这个命令`make clean`不会执行。因为Make发现clean文件已经存在，就认为没有必要重新构建了

除非指定`.PHONY`：

    .PHONY: clean
    clean:
            rm *.o temp

## 命令前导符
默认每行命令之前必须有一个tab键。如果想用其他键，可以用内置变量`.RECIPEPREFIX声明`。


    .RECIPEPREFIX = >
    all:
    > echo Hello, world

## 命令间变量不会共享
除非把命令写成一行：

    var-kept:
        export foo=bar; \
        echo "foo=[$$foo]"

或者方法是加上`.ONESHELL:`命令。


    .ONESHELL:
    var-kept:
        export foo=bar; 
        echo "foo=[$$foo]"
        
## 模式匹配
    %.o: %.c

匹配：

    f.o: f.c
    g.o: g.c

# 判断和循环
Makefile使用 Bash 语法，完成判断和循环。
上面代码判断当前编译器是否 gcc ，然后指定不同的库文件。

    ifeq ($(CC),gcc)
        libs=$(libs_for_gcc)
    else
        libs=$(normal_libs)
    endif

循环

    LIST = one two three
    all:
        for i in $(LIST); do \
            echo $$i; \
        done

    # 等同于

    all:
        for i in one two three; do \
            echo $i; \
        done

# 函数
Makefile 还可以使用函数，格式如下。

    $(function arguments)
    # 或者
    ${function arguments}

Makefile提供了许多内置函数，可供调用。下面是几个常用的内置函数。

## shell 函数
shell 函数用来执行 shell 命令

    srcfiles := $(shell echo src/{00..99}.txt)

## wildcard 函数
wildcard 函数用来在 Makefile 中，替换 Bash 的通配符。

    srcfiles := $(wildcard src/*.txt)

## subst 函数
subst 函数用来文本替换，格式如下。

    $(subst from,to,text)

e.g.

    $(subst ee,EE,feet on the street)

下面是一个稍微复杂的例子。

    comma:= ,
    empty:=
    # space变量用两个空变量作为标识符，当中是一个空格
    space:= $(empty) $(empty)
    foo:= a b c
    bar:= $(subst $(space),$(comma),$(foo))
    # bar is now `a,b,c'.
## patsubst函数
patsubst 函数用于模式匹配的替换，格式如下。

    $(patsubst pattern,replacement,text)

下面的例子将文件名"x.c.c bar.c"，替换成"x.c.o bar.o"。

    $(patsubst %.c,%.o,x.c.c bar.c)

## 替换后缀名
替换后缀名函数的写法是：变量名 + 冒号 + 后缀名替换规则。它实际上patsubst函数的一种简写形式。


    filename = a.js
    min: 
        echo $(filename:.js=.min.js )