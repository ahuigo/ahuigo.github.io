---
title: Shell 变量的数据类型
date: 2018-09-27
priority:
---
# Shell 变量的数据类型
shell 主要支持字符串 和 数组 两种数据类型。数组功能很弱，如果想做复杂的处理，建议用python 等脚本处理。

## 变量定义与删除

    VAR='hello'
	unset VAR

# String, 字符串

## string color
    RED='\033[0;31m'
    NC='\033[0m' # No Color
    printf "I ${RED}love${NC} Stack Overflow\n"
    echo "I ${RED}love${NC} Stack Overflow\n"

## read string
read 命令用于从标准输入（或其他文件描述符）

    $ read -r -d '' CONTENT <<-'EOF'
    some text
    EOF

    -r 选项告诉 read 命令不要把反斜杠 (\)，　即： \n\r\t等
    -d '' 选项改变了 read 命令的行为，使其不再在读取到换行符时停止，而是在读取到空字符串时停止

## heredoc and nowdoc
Act as stdin

	# heredoc 任何字词都可以当作分界符 (cat < file)
	cat  << MM
	echo $? #支持变量替换
	MM

	#nowdoc 加引号防止变量替换
	cat << 'MM' > out.txt
	echo $?
	MM

	# `<<-` ignore tab(not space)
	if true ; then
		cat <<- MM | sudo tee -a file > /dev/null
		The leading tab is ignored.
    MM
	fi
	# nowdoc + ignore tab(not include space) MM 仍然要顶行写, 且不能用`;` 分号
	cat <<-'MM' | sudo tee -a a.txt > /dev/null
		echo $PATH
    MM

### here string
> Note: here string 结尾会追加'\n'

Act as stdin

    python <<<'import os;os._exit(0)'
	tr a-z A-Z <<< 'one two'
	cat <<< 'one two'

	cat <<< $PATH a.txt
	echo "$PATH" | cat a.txt

Note that here string behavior can also be accomplished (reversing the order) via piping and the echo command, as in:

	echo 'one two' | tr a-z A-Z

## str2hex

    echo -n GET | xxd -p
    echo -n GET | xxd -p | xxd -r -p

## count_chars

	echo 'ahui ahui' | grep -o a | wc -l
	a='ahui ahui'; b=${a//[^a]}; echo ${#b}

## expr
expr 命令支持ERE 正则匹配

	expr "$SHELL" : '.*/\(.*\)'
	expr "/bin/zsh" : '.*/\(.*\)'
		zsh

建议用awk 的match 匹配更方便

	match($2, /1(.*)/, m){}

## Str2Hex & Hex2Str

	echo '12' | xxd -p
	echo '3132' | xxd -r -p

## print
打印原始字符串，请用

   `printf "%s" "$var"`

Note:

- `$(cmd)` , ``` `cmd` ``` 会过滤最后连续的换符符, 且被视为多个参数
- `"$(cmd)"` , ```"`cmd`"``` 会过滤最后连续的换符符,且被视为1个参数

## shell 字符解析

### 单引号
要注意的是shell中的单引号内所有字符都会原样输出.

	str='a  '\'\"'  b';
	echoraw 'It'\''s Jack'; //output: It's Jack

### 双引号
而双引号内: `$`, 字符会被解析, `!` 会被terminal 解析

	echoraw "${HOME}"
	echoraw "$HOME"
     "$(basename "$PWD")"
	echoraw "abc!ls" #会将`!ls` expand 为最近的history 命令

只有`\"` 被转义为`字面字符`, 其他的`\t\n\r`, `\'` 则原样输出，

    echoraw "0\t0\n0\rabc\'\""
        0\t0\n0\rabc\'"

shell 会将`!`(exclamation mark)作为 Expandsion Mark,（限交互模式）
Or turn off history expandsion:

	set +H
	//or
	set +o histexpand

### 无引号
`\t\n\r\'\"` 全部被转义为`字面字符`

    echoraw 0\t0\n0\rabc\'\"
        0t0n0rabc'"

### 无引号`$''`
`\t\n\r` 转义为特殊字符，`\'` `\"` `$` 转义为字面字符

    # Press Ctrl-v + Tab
    cut -f2 -d'   ' infile
    cut -f2 -d$'\t' infile
    printf $"ab\tc\ne\rE"

    echoraw $'0\t0\n0\rabc\'\"'
        0	0
        abc'"

### 无引号`$`

    cmd='arg1 arg2'
    echoraw $cmd
        zsh: 一个参数
        bash: 多个参数

### 无引号`$""` 不要用
shell 不兼容

    # zsh
	$ echoraw $"var"
		$var
    #bash
	$ echoraw $"var"
        var

## echo 命令
对于`echo` 来说，它是将经过shell 解析过的字符，再用自己的规则解析一次。

zsh 中的echo 会解析 \007 \x31 (建议不要这样使用)

	echo '\n' //换行
	echo '\x31' //1
	echo "\x31" //1
	echo  '\0116' //N的ASCII 的8进制是116

在bash 下，echo必须加`-e` 才支持bytes 输入

	echo -e "\x31" //1

-E 表示禁用反斜线转义(原始raw 输出): bash默认的是-E, zsh 默认是-e

    echo -E "\x31" // \x

## str 函数
### concat 拼接

	$PATH:otherStr #拼接.
	${var}otherStr
    s=' a      b'
    echo 'left_'$s'_right' 

or:

	str='hello '
	str+='world'


### length

	echo ${#str}
	echo -n "1" | wc -c #去掉换行符
	echo "1" | awk '{print length($0)}' ;# awk 不会匹配换行，所以其结果是正确的

	echo $((${#str}+2))

### index

	awk -v str="$a" -v substr="$b" 'BEGIN{print index(str,substr)}'; #

### match in
使用 grep

	[ $(echo "$st" | grep -E "^[0-9]{8}$") ] && echo "match"

使用字符串替换(注意等号两边的空白)：

	[[ ${str_a/${str_b}//} == $str_a ]]
	[[ ! ${str_a/${str_b}//} == $str_a ]] && echo yes

### regex
使用ERE or wildcard

	# support zsh/bash
	[[ "$var" =~ ^[[:space:]]*$ ]]

	# only supported by zsh
	[[ "$var" =~ '^[[:space:]]*$' ]]

Example: match ip

	[[ "$var" =~ ^[[:digit:].]*$ ]]
    
substr is beginning:

    if [[ "$string" =~ ^hello ]]; then
     do something here
    fi

### substr 截取 slice

	echo ${str:start:length}
	echo ${str:start} #start 不为负数.否则当作0
	echo ${str: -1}; #负数前面需要有空格
	echo ${str:(-1)}; #或者负数用括号. 否则负数不会生效

	echo ${str:0:-1}; #remove last char(bash>4.2, zsh)

### trim

	"trim any last char
	echo ${str%?}
	"trim last char /
	echo ${str%/}

### replace, 替换与删除
支持通配符`*`

    #...%
	变量配置方式(#df)	说明
    ${path#prefix}  a=pre:pad:world; echo ${a#pre*:}
	${变量#关键词}	若变量内容从头开始的数据符合『关键词』，则将符合的最短数据删除 
	${变量##关键词}	若变量内容从头开始的数据符合『关键词』，则将符合的最长数据删除 

    ${path%end} %dF
	${变量%关键词}	若变量内容从尾向前的数据符合『关键词』，则将符合的最短数据删除
	${变量%%关键词}	若变量内容从尾向前的数据符合『关键词』，则将符合的最长数据删除
    a='ab--bx-end'
    echo ${a%b*end} ;# ab--
    echo ${a%%b*end};# a

    ${path/middle}
	${变量/字符串}	若变量内容符合『字符串』则『第一次出现的字符串会被删除』
	${变量//字符串}	若变量内容符合『字符串』则『全部出现的字符串会被删除』
	${var//[^s|S]} 只保保留s|S
    ${repo//[[:space:]]} 去掉空白符

	${变量/旧字符串/新字符串}	若变量内容符合『旧字符串』则『第一个旧字符串会被新字符串取代』
	${变量//旧字符串/新字符串}	若变量内容符合『旧字符串』则『全部的旧字符串会被新字符串取代』

支持glob wildcard

	${var##??} 删除最前面的两个字符
	${var//[^s|S]} 只保保留s|S
    [ "$answer" != "${answer#[Yy]}" ]

### dirname

    path=$(dirname $path)
    path=$(cd $(dirname $0) && pwd)

### var-test 变量测试

    - 不存在则设置默认值expr, 否则用原值
        :- 不为空值则设置
    + 不存在则清空，否则用替换值expr
        :+ 不为空值则
    = 在- 的基础上 使用默认值
    ? 在- 的基础上 不存在则产生错误errno=1, expr输出至stderr 
    变量配置方式	          str 没有配置	    str 为空字符串	str 已配置为非空字符串
    var=${str-expr}	        var=expr		var=$str		var=$str
    var=${str:-expr}        var=expr		var=expr		var=$str
    var=${str+expr}	        var=			var=expr		var=expr
    var=${str:+expr}        var=			var=			var=expr
    var=${str=expr}		    same as: str=${str-expr}; var=str;
    var=${str:=expr}	    same as: str=${str:-expr}; var=str;
    var=${str?expr}	        expr输出至stderr var=$str		var=$str
    var=${str:?expr}        expr输出至stderr expr输出stderr	var=$str

### contains substr

    if [[ $string == *"My long"* ]]; then .. fi
    [[ $PATH =~ ~/bin ]] || echo 'pls config $PATH'

# Number 数字

	$RANDOM 随机数
	declare -i a=1

## Calculate 运算
下面介绍的inner运算和expr都不支持小数, 虽然不会报错, 但计算结果让人无语. 如果需要小数, 请使用bc(无论如何, shell 计算很鸡肋, 如果需要大量的运算请请使用python/octave等脚本)

	# 不要用inner calc 和 expr 做 float 运算!!
	➜  ~  a=-2+1.1; declare -p a;
	typeset -i a=0
	➜  ~  a=2+1.1; declare -p a;
	typeset -i a=3

### Inner Calc

	let ++a; let a++;//a也可以为字符串
	let a=$a+2;

//let 支持*/%

	let a=$a*2;
	let a=$a/2;

或者 -i 型不用加`let`

	declare -i a=1;
	a+=2; #shell 不允许有空格

### expr 运算

    expr 14 % 9 #需要有空格
    expr 14 \* 3 #*在shell中有特别的含义(它是通配符wildcard)
		expr '14 * 3' #expr 识别为一个参数
	expr \( 1 + 2 \)  \* 3

### bc 运算

	echo '14*3' | bc #bc更精确
	echo '2.1*3' |bc #6.3

## 生成数字序列
这不是数组!而是以空格为间隔的字符串序列!

	for i in {1..5}; do echo $i; done #Brace expansion是在其它所有类型的展开之前处理的包括参数和变量展开
	for i in {a,b}{1,2}; do echo $i; done #Brace expansion是在其它所有类型的展开之前处理的包括参数和变量展开
	END=5;
	$ echo {1..5}
	$ for i in `seq $END`; do echo $i; done #或者用 for i in $(seq $END); do echo $i; done
	$ for i in `eval echo {1..$END}`; do echo $i; done

seq 用法: man seq

	seq [first [incr]] last

## Format Num
padding num

	`printf "%02i\n" $num`
	n=`printf %03d $n`

# Array数组
> terminal: zsh 的数组, 其下标是从1 开始的，而bash 是从0 开始的。
> 在函数参数上看: 二者都是从0开始的，不过zsh 会指向函名，bash 则会指向脚本名. 不过`$@`与`$*` 都不会包含0

定义(zsh下标从1 开始, bash 从0开始, 见上段话):

    # 这两个等价
	var=(1 2 3)
	var=(1, 2, 3)
	var=('1' '2' '3')

    # 5个参数(包含,)
	var=(1 , 2 , 3)

	var=(1
	2
	3)
	var[num]=content

local 与 assignment 需要分开：

	local -a arr
	arr=(1 2 3)

赋值:

	var[num]=value;//num 可以不连续
	var[字符]=value; #相当于var[0]=value; 但这在zsh 中,0 下标是非法的

	var+=(val1 val2 ...)

使用:

	${var[index]}
	$var or ${var[@]} or ${var[*]} #输出整个数组
	${#var} or ${#var[@]} or ${#var[*]} #输出数组长度

截取:

	echo ${a[@]:start:length}
	c=(${a[@]:1:4}) #加上()后生成一个新的数组c

替换:

	a=(1 2 3 13 4 5)
	echo ${a[@]/3/ahui} #得到 1 2 ahui 1ahui 4 5

清除:

	unset var[0] #清除下标, 其它下标的顺序不会变
    

## pass array

	arr=('1 2' 3)
	"${arr[@]}"
		'1 2' 3 //zsh & bash
	${arr[@]}
		1 2 3	//bash 按literal 字面处理

### print array

	printf "%s," "${array[@]}"

### copy array
With Bash4.3, it only creates a reference to the original array, it doesn't copy it:

	declare -n arr2=arr

正确的做法是：

    a=(1 2 3)
	b=("${a[@]}")

错误的是

    arr=('1 2' 3 4)
    b="${arr[@]}"; # 结果: ('1 2 3 4' 3 4)
	b=${arr[@]}" ; # 结果: ('1 2 3 4' 3 4)

## access array
    arr=('1 2'
    3)
    printf "%s -- " '$arr:'
    printf "%s," $arr 
    printf "%s -- " $'\n"$arr":'
    printf "%s," "$arr" 
    printf "%s -- " $'\n$arr[@]:'
    printf "%s," ${arr[@]}
    printf "%s -- " $'\n"$arr[@]":'
    printf "%s," "${arr[@]}"

强烈建议只用`"$arr[@]"`

    # bash test.sh
    $arr: -- 1,2,
    "$arr": -- 1 2,
    $arr[@]: -- 1,2,3,
    "$arr[@]": -- 1 2,3,%


### loop array

	for i in ('1 2', 3); //error
	for i in ${array[@]}; //3 个(不要用这个)
	for i in "${@}"; //2 个
	for i in "${array[@]}";// 2个
	do
		echo $i
	done

参数可以省略为 `for i in "$@"`, 这在使用脚本参数时特别有用

zsh 只能用变量

    lw=(1 2 3)

    for i in $lw;
        do echo $i;
    done

### in_array
shell 参数不支持array传递. 只能变通实现[in_array](http://stackoverflow.com/questions/5788249/shell-script-function-and-for-loop)了

**用shift 实现**
shift: 左移出1 (注意:shell 不支持unshift push pop)
shift 3: 左移出3

	in_array(){
		el="$1"
		shift
		while test $# -gt 0; do
				test "$el" = "$1" && return 0 # for bash and zsh
				#test $el = $1 && return 0;		# for zsh
				shift
		done
		return 1
	}
	arr=( 1 2 'Hello Jack');
	in_array 'Hello Jack' "${arr[@]}" && echo has; # for zsh and bash
	in_array 'Hello Jack' "$@" && echo has; # for zsh and bash
	in_array 'Hello Jack' $arr && echo has;		# for zsh only

**利用eval 访问外围的arr**

	in_array(){
		a="$2"
		eval "for i in \${$a[@]}; do
			echo \$i
			test $1 = \$i && return 1
		done"
		return 0
	}
	arr=( 1 2 'It'\''s Jack');
	in_array 'Hello Jack' arr && echo has;