---
layout: page
title: shell 表达式
category: blog
priority:
---

# shell 表达式

# multiple commands

## command sequence list

    # ; is for a sequential list
    sh -c 'echo foo ; echo car' 

    # & is for a asynchronous lists
    sh -c 'sleep 1 & echo car'

非法的:

    sh -c 'echo foo &; echo car'

## sub commands

    (cmd1;cmd2) 	以子shell执行命令集
    	(var=notest;echo $var) # 无空格限制
    	arr=(1 2 3) 也用于初始化数组

    sh -c "cmd1;cmd2"

## merge commands

    { cmd1;cmd2;}		命令集(在前shell执行, 在bash 中左花括号后必须有一个空格，而cmds中最后一个cmd后必须有分号; zsh 则没有这些限制)

## replace command

    exec cmd

# Loop

    for i in `seq 1 5`;
    for i in {1..5};

## loop break continue

    for i in `seq 1 100`; do
        echo $i | grep 3 && echo yes && break
    done

其它

    continue
    continue n
    break
    break n

## for
`seq 1 5`:

    for a in "$*" ; do echo "$a "; done
    for a in "$@" ; do echo "$a "; done # equal to for a ;do ... done
    for file in Downloads/*.sh ; do echo "$file"; done #遍历文件
    for file  (Downloads/*.sh) ; do echo "$file"; done #遍历文件(只能用于zsh)

    for ((i=0;i<10;i++)); do echo $i; done;
    for i in `seq 1 5`;do

## while

for / while:

    for i in something; do
        [ condition ] && continue
        cmd1
        cmd2
    done

    while expr; do
        [ condition ] && continue
        cmd1
    done;

until

    declare -i i=0; until (($i>=3)); do  echo $i;let i++; done #output: 0 1 2

## break

    break;
    break N;

    for i in `seq 1 5`;do
    	echo $i;
    	if (($i==3)); then
    		break;
    	fi
    done

# case

1. case 不需要加break
1. 条件以右括号结尾,**左括号可省略**;
1. 每个条件判断语句块都以一对分号结尾`;;`

e.g.

    case "$string" in
    	(*$SUBSTRING*) echo "$string matches";;
    	(*)            echo "$string does not match substring";;
    esac

case条件 可以是变量、与或非(不能有引号)、简单的通配符(不能有引号)、元字符

    case "$var" in
    	"$v1" | "$v2") echo some1;;
    	[0-9]) echo 'include 1 digit only';;
    	*[[:digit:]]*) echo 'inclue at least 1 digit';;
    	*) echo some3;;
    esac

> 不支持BRE, EBR. `[[:digit:]]` 理解为扩展的wildcard

不是前缀匹配，而是完全匹配, 除非加`pre*)`：

    case "$2,$3" in
        merge,) print' "$3" ;;
        *) ;;
    esac

# function

    function fun(){
    	#local 变量[=值] #局部变量，shell 没有静态变量
    	local name=ahui
    	echo $1 $2
        echo $name
    	return 3;
    }

    # equal 
    function mcd(){ mkdir -p $@; cd $1;}
    mcd(){ mkdir -p $@; cd $1;}

call function

    fun 2 3
    echo $? ;#函数返回值

    ;如果不加括号，则花括号前必须有空白
    function fun {
    	local 变量[=值]
    	echo $1 $2
    	return 3;
    }

Example:

    function mcd(){mkdir -p $1; cd $1}

## Arguments

    $@ = $* = "$1 $2 $3 ..."
    for a in $* ; do
    	echo $a;
    done

### `$0`
对于zsh 来说

    f(){
        # zsh 显示函数名 f
        # bash　则会显示`脚本名`或者`bash`
        echo $0; 
    }

## function return
return 只能返回error code`$?`, 不会我们可以这样实现返回

    function myfunc() {
        echo -n "$myresult 1"
    }

    result=$(myfunc)   # or result=`myfunc`
    echo $result

## ignore function and alias

Runs COMMAND with ARGS ignoring shell functions. you can type:

    command ls

If the -p option is given, a default value is used for PATH :

    command -p ls

The -V or -v option is given, a string is printed describing COMMAND. The -V
option produces a more verbose description:

    command -v ls

# condition expression

## multiple conditions
注意空格分割

    ! { false || true;}
    ! { [[ -n $a ]] || [[ -n $b ]];}

## if

Selection Statement 也叫分支语句

    if [ -x file ]; then  # 语法规定[]两边必须有空格
    　 ....
    elif test "$a" = "$b" ; then
    	...
    elif [ "$a" = "$b" ] ; then
    　 ....
    elif [ "$a" == "$b" ] ; then #bash shell 中 "==" 与 "=" 是相同的 . 没有全等"==="
    　 ....
    else
    　 ....
    fi

Example:

    if ! cmd_if_false; then
    	: ;
    fi

参考: [shell表达式](http://www.cnblogs.com/chengmo/archive/2010/10/01/1839942.html)

Nop command

    if cmd; then
    	:;
    elif cmd; then
    	:;
    else
    	:;
    fi

### 测试命令执行

    if command; then echo echo succ:$?; else echo failed:$?; fi

    if ls; then echo succ:$?; else echo failed:$?; fi
    if :; then echo succ:"空命令':'始终会执行"; else echo failed:$?; fi

if not command

    if ! { echo a && false; } then
        echo false
    fi

### 测试函数执行

    is_file(){
    	if [ -f "$1" ]; then return 0;
    	else return 1;
    	fi
    }
    if is_file a.txt; then echo 'It is file!'; fi

# test 测试表达式

shell 支持如下测试表达式(logic and compare)

## test expr

Example:

    test 'a' = 'a' && echo yes
    test 'a' && echo yes
    test '' && echo no

## `[ expr ]`

Example:

    [ 'a' = 'a' ] && echo yes
    [ 'a' \< 'b' ] && echo yes #zsh不支持这种转义
    [ 'a' = 'a' && 'b' = 'b' ] && echo yes ;#这里的&& 是非法关键字(不要使用)

## `[[ expr ]]`

    - [[ expr1 && expr2 ]]
    - [[ expr1 || expr2 ]]

较[ expr ] 和 test , `[[ ]]`更通用, 而且不用转义这些特殊符号: < > &&,||

    [[ 'a' < 'b' ]] && echo yes
    [[ 'a' < 'b' && 'a' < 'c' ]] && echo yes

以上表达式中 expr 中:

1. `测试符号` 两边要有空白. 且不支持`<=` , `>=` 这两种测试数字的符号;
2. 中括号两边也需要留空白

> 强烈建议尽量避免使用`[ expr ]` 和 `test expr`, 尽量使用更通用的`[[ expr ]]` 做测试

### 双括号-数字测试

除了以上三种测试之外， 还有一种双括号测试. 双括号与之前介绍的三种测试表达式有两点不同：

- 它仅支持数字测试

  (('3'>'1')) && echo 'bad math expression: illegal character:'

- 它仅支持测试符号: `> >= < <= == !=`

  ((3>1)) && echo yes

### 逻辑测试(logic test)

    && -a # zsh 不支持-a
    || -o # zsh 不支持 -o
    ! #取反
    ! test '' && echo 0
    ! ((1>1)) && echo 0

非空白且非注释(Note: "!" 只作用于最近的比较表达式)：

    [[ ! $str =~ ^[[:space:]]*$ && ! "${str:0:1}" = '#' ]] && echo yes

#### 逻辑测试顺序

logic order

    {true || false } && echo yes; # 左优先
    true || { false && echo yes;} # 右优先
    true || false && echo yes; # 默认左序
    0 and 1 or 2

所有语言都是左优先的

    flag = false
    > (flag && true) || true # 左优先：node/golang/shell/python/php
    true
    > flag &&( true || true) # 右优先
    false

shell 逻辑测试符是从左开始以最短的语句为子语句。python/js/go 都是如此

    hash git || echo 'Err: git is not installed.' && exit 3
    # 等价于
    { hash git || echo 'Err: git is not installed.' } && exit 3

应该写成：

    hash git || { echo 'Err: git is not installed.' ; exit 3; }
    if && do1 || do2

shell 没有三元运算符：不过可以这样

    { cmd && r=true } || r=false
    if $r; then
    	echo true
    fi

### test file 文件测试

    ### 关于档案与目录 测试文件的状态
    -e 路径是否存在(会查检symlink path 有效性)
    -d 是否为目录
    -f 是否为常规文件(会判断symlink 有效性)
    -L 是否为symlink file(**唯一不会检测是否存在**)
    -c file　　　　　文件为字符特殊文件为真
    -b file　　　　　文件为块特殊文件为真
    -s file　　　　　文件大小非0时为真
    -t file　　　　　当文件描述符(默认为1)指定的设备为终端时为真  这个测试选项可以用于检查脚本中是否标准输入 ([ -t 0 ])或标准输出([ -t 1 ])是一个终端.
    -S 是否为socket文件
    -p	侦测是否为程序间传送信息的 name pipe 或是 FIFO

    ### 关于程序的逻辑卷标！
    -G	你所有的组拥有该文件
    -O	你是文件拥有者
    -N	文件最后一次读后被修改

    ### 档案权限
    -r	侦测是否为可读的属性
    -w	侦测是否为可以写入的属性
    -x	侦测是否为可执行的属性
    -s	侦测是否为『非空白档案』
    -u	侦测是否具有『 SUID 』的属性
    -g	侦测是否具有『 SGID 』的属性
    -k	侦测是否具有『 sticky bit 』的属性

    ## 两个档案之间的判断与比较
    -nt	第一个档案比第二个档案新
    -ot	第一个档案比第二个档案旧
    -ef	第一个档案与第二个档案为同一个档案（ hard link or symbolic file）

### logic

    !	反转以上测试

### test string, 字符串测试

    =	相等
        [[ $a = "" ]] && echo yes
    == 与= 相同(-1: Do not use "==". It is only valid in a limited set of shells, zsh do not support it)
    != 不相等
        [[ $a != "" ]] && echo yes

    <	按ascii比较
    	if [[ "$a" < "$b" ]]
    	if [ "$a" \< "$b" ] 注意"<"字符在[ ] 结构里需要转义, 这个是重定向控制符

    >	按ascii比较

    -z	空字符串 或者未定义变量 等价于[[ $aaa = '' ]] && echo 1 (双括号会自动将$aaa 表示为字符串"$aaa")
    -n	非空字符串 (只支持中括号，不支持test -n $var)
    	[[ -n $str ]]
    	等价于 [[ $str != '' ]]
    	等价于: [[ $str ]]

如果想判断变量是否设置，应该使用变量测试：

    [[ -z ${var+x} ]] && echo 'var is unset' || echo 'var is set'

### test digital, 数字比较

    -eq	等于 应用于：整型比较
    -ne	不等于 应用于：整型比较
    -lt	小于 应用于：整型比较
    -gt	大于 应用于：整型比较

    -le	小于或等于 应用于：整型比较
    -ge	大于或等于 应用于：整型比较

    [[ 1 -le 3 ]] && echo yes

# Brackets, 括号

执行cmd

    (cmd1;cmd2) 	以子shell执行命令集
    	(var=notest;echo $var) # 无空格限制
    	arr=(1 2 3) 也用于初始化数组
    { cmd1;cmd2;}		命令集(在前shell执行, 在bash 中左花括号后必须有一个空格，而cmds中最后一个cmd后必须有分号; zsh 则没有这些限制)
    	for i in {0..4};do echo $i;done 产生一个for in序列
    	ls {a,b}.sh		通配符(globbing)
    	echo a{p,c,d,b}e # ape ace ade abe
    	echo {a,b,c}{d,e,f} # ad ae af bd be bf cd ce cf
    	{code block}
    [ expr ] 		测试,  test expr 等价
    	[ 1 ] && echo 1 # true
    	[ 0 ] && echo 1 # true
    	[ '' ] && echo 1 # false
    	[ $(echo $str | grep -E '^[0-9]+$') ] && echo 1 #小心命令替换出现恶意字符 导致syntax error.

下面是结果替换为命令字符

    $(cmd1;cmd2) 	命令结果替换 相当于`cmds`, 会将命令输出作为结果返回(带$都有这个意思)
    $[ expr ] 		以常用数学符号做计算 完全等价$((expr))
    ${var}			变量替换为字符

    ((expr1,expr2, ...))	 	以常用数学符号做计算(+-*/%=), 提供随机数RANDOM, 以最后expr的结果为返回状态码
    	((a=1,a=2,a=1,RANDOM%100)) && echo 'true'
    	for (( a=0,n=a+10 ; a<n ; a++ )); do echo $a; done # for中双括号用的是分号哦
    [[ expr ]] 		比[ expr ] 更严格而规范的测试, 不用转义 >,< ,||, && 这个是重定向控制符, 管道, 命令连接 杜绝了当a为空时 [ $a = '' ] && echo true; 会出错($a在[]必须"$a", 而[[ ]] 不用对$a使用双引号)
    {{ }} 			syntax error

    $((expr))	 	返回((expr1,expr2,...))计算结果
    $[[ expr ]]		syntax error
    ${{ }}			syntax error

## 双括号((expr)) , $((expr)) and $[expr]

    ((expr))	 以常用数学符号做计算, 计算的结果只能用于条件判断
    $((expr))	 用于取值,	以常用数学符号做计算 $((i--)) i值会减小
    $[expr]	 	与$((expr))完全一样

    ((x=1)) && echo b #先执行赋值语句 x=1, 再做逻辑判断
    ((1*0)) && echo b
    ((1>0)) && echo b
    ((a++))
    ((x+=10))

    echo $((3+3))
    x=$(($a+3))
    x=$[$a+3]

e.g.

    for i in {0..99}; do
        echo a$((i*5000))
    done
