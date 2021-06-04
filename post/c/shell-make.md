---
title: Shell make
date: 2019-05-06
private:
---
# Expr
## Func
参考 https://www.gnu.org/software/make/manual/html_node/Text-Functions.html
make 提供了很多func

    ARR:= d/a.go d1/b.go d/c.go d/b.go txt/b.txt
    t:
        echo $(filter %.go,$(ARR))
        echo $(dir $(filter %.go,$(ARR)))
        echo $(sort $(dir $(filter %.go,$(ARR))))

## loop
使用原生的shell 的loop

    TEST_DIRS=$(sort $(dir $(filter %.go,$(ARR))))
	@for dir in $(TEST_DIRS); do \
		go test -timeout 20m -coverprofile="coverage.log" "$$dir" \
	done;

# Shell make
> refer to : http://www.ruanyifeng.com/blog/2015/02/make.html
## Specify Makefile
    -f makefile2

# variable
### argv 变量
传变量的方法为

    $ make test FLAG=debug

然后

    FLAG?=default_value
    test:
        echo $(FLAG)

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

make 变量与shell 变量不同

    LDFLAGS += -X "main.Version=$(shell git rev-parse HEAD)"
    GO := GO111MODULE=on go

### 环境变量, shell 变量
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

### 内置变量（Implicit Variables）
比如 $(CC) 指向当前使用的编译器，$(MAKE) 指向当前使用的Make工具。

make默认了一些[缺省内置常量](http://akaedu.github.io/book/ch22s03.html)

	AR 		静态库打包命令的名字，缺省值是ar。
	ARFLAGS 静态库打包命令的选项，缺省值是rv。
	AS		汇编器的名字，缺省值是as。
	ASFLAGS 汇编器的选项，没有定义。
	CC 		C编译器的名字，缺省值是cc。
	CFLAGS 	C编译器的选项，没有定义。
	LD 		链接器的名字，缺省值是ld。
	TARGET_ARCH 和目标平台相关的命令行选项，没有定义。
	OUTPUT_OPTION 输出的命令行选项，缺省值是-o $@。

	LINK.o 	把.o文件链接在一起的命令行，缺省值是$(CC) $(LDFLAGS) $(TARGET_ARCH)。

	LINK.c 	把.c文件链接在一起的命令行，缺省值是$(CC) $(CFLAGS) $(CPPFLAGS) $(LDFLAGS) $(TARGET_ARCH)。

	COMPILE.c 	编译.c文件的命令行，缺省值是$(CC) $(CFLAGS) $(CPPFLAGS) $(TARGET_ARCH) -c。

$(CC) 指向当前使用的编译器

    output:
        $(CC) -o output input.c

### 自动变量（Automatic Variables）
在makefile 有一些Automatic 的变量

	$@，表示规则中的目标。
	$^，表示规则中的所有前置条件，组成一个列表，以空格分隔。
	$<，表示规则中的第一个条件。
	$?，表示规则中所有比目标新的条件，组成一个列表，以空格分隔。
	$$, 当前进程id
	% 用于匹配target/require 的通配符
	$*, 表示%所匹配的字符串
	$(@D) 和 $(@F) 分别指向 $@ 的目录名和文件名。
		比如，$@是 src/input.c，那么$(@D) 的值为 src ，$(@F) 的值为 input.c。
	$(<D) 和 $(<F) 分别指向 $< 的目录名和文件名。

makefile 中的编译命令可以是这样

	main: main.o stack.o maze.o
		gcc $^ -o $@

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

# 执行指令

    make init
    make install

合并

    make init install

## 闭关回声@
正常情况下，make会打印每条命令，然后再执行，这就叫做回声（echoing）。

我们可以关闭它

    test:
        @echo TODO

## 失败继续
默认命令失败时，会停止。如果在命令前加`-` 就继续下一条command

Example: clean 清除编译文件 这一target 不需要条件。

	clean:
		@echo "cleanning project"
		-rm main *.o
		@echo "clean completed"

## 忽略错误
默认make 执行语句时，如果有错误就结束执行。

如果候忽略错误, 就加`-`

    test:
        -mkdir -p dir1/dir2
        @-mkdir -p dir1/dir2
        echo "ok"

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

## 命令间变量不会共享, ONESHELL
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

## prerequisites 前置条件
前置条件通常是一组文件名，之间用空格分隔。
它指定了"目标"是否重新构建的判断标准：
	只要有一个前置文件不存在，或者有过更新（前置文件的last-modification时间戳比目标的时间戳新），"目标"就需要重新构建。

	result.txt: source.txt
		cp source.txt result.txt


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

# 依赖处理
## 隐含规则和模式规则
默认情况下我们不需要为*.o 编写规则：

	stack.o: stack.c
		gcc -c stack.c

因为，对于任何的*.o 有隐含规则：

	# default
	OUTPUT_OPTION = -o $@

	# default
	CC = cc

	# default
	COMPILE.c = $(CC) $(CFLAGS) $(CPPFLAGS) $(TARGET_ARCH) -c

	%.o: %.c
		$(COMPILE.c) $(OUTPUT_OPTION) $<

## wildcard 通配符

	* ? []

## make Example
将CofferScript脚本转为JavaScript脚本。

	source_files := $(wildcard lib/*.coffee)
	build_files  := $(source_files:lib/%.coffee=build/%.js)

	build/%.js: lib/%.coffee
		coffee -co $(dir $@) $<

	coffee: $(build_files)

执行

	$ make coffee



## 自动处理头文件依赖
有时我们会忘记在makefile 中更新新加的头文件，这些条件可以通过`gcc -M` 自动生成包含头文件的 requirement 。

比如我们在a.c 中新加了`#include "stack.h"`

	> gcc -M a.c -Ilib
	a.o: a.c /usr/include/stdio.h /usr/include/sys/cdefs.h \
		lib/stack.h \
		.....
	> gcc -MM a.c -Ilib
	a.o: a.c lib/stack.h

通常会用`include` 包含并触发更新头文件依赖关系。比如：

	SOURCE = main.c other.c
	include $(SOURCE:.c=.d)
	%.d: %.c
		set -e; rm -f $@; \
		$(CC) -MM $(CPPFLAGS) $< > $@.$$$$; \
		sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ > $@; \
		rm -f $@.$$$$

以上规则中的命令因为有反斜线转义行，所以是一条命令, 只创建一个shell：

- `include $(SOURCE:.c=.d) ` 相当于 `include main.d other.d` 两子规则.
- 当main.d 或者 other.d 规则不存在时，会触发`%d: %c` 规则 并创建 *.d 规则
- `$(CC) -MM $(CPPFLAGS) $< > $@.$$$$;` 用于创建新的头文件依赖关系，这四个`$` 被make 解析为两个，shell 再解析为进程号。
- `sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ > $@; ` 用于将"main.o :" 替换为 "main.o main.d:", 目标文件和头文件依赖的：requirement 是相同的。`$*`代表% 所匹配的字符串。

如果我们不想在requirement 中包含系统的头，此时可以用`gcc -MM`

# make 命令行

	-n
		Print each command, but not excute command.
	-C dir
		Change to directory dir before reading the makefiles or doing anything else.
		所有的工作都以dir 作基根目录

	VAR=value
		Eg. `make CPPFLAGS=-g`, 在make 命令行中定义变量

# global env
 export individual variables with:

    export MY_VAR = foo  # Available for all targets

Or export variables for a specific target (target-specific variables):

    my-target: export MY_VAR_1 = foo
    my-target: export MY_VAR_2 = bar
    my-target: export MY_VAR_3 = baz

    my-target: dependency_1 dependency_2
      echo do something

You can also specify the .EXPORT_ALL_VARIABLES target to—you guessed it!—EXPORT ALL THE THINGS!!!:

    .EXPORT_ALL_VARIABLES:

    MY_VAR_1 = foo
    MY_VAR_2 = bar
    MY_VAR_3 = baz

    test:
      @echo $$MY_VAR_1 $$MY_VAR_2 $$MY_VAR_3

# 参考
Refer to: http://www.ruanyifeng.com/blog/2015/03/build-website-with-make.html
