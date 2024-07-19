---
layout: page
title:	awk 简介
category: blog
description:
---
# Preface
awk  命令行的基本语法为

	awk option 'script' file1 file2 ...
	awk option -f scriptfile file1 file2 ...

awk 编辑命令的格式为:

	/pattern/{actions}
	condition{actions}
	0{actions} //0是false
	1{actions} //1是true

pattern 可以是

	/egrep/
	line_num
	BEGIN
	END

其中BEGIN, END表示

	BEGIN{ 这里面放的是执行前的语句 } #BEGIN不需要读取file文件
	END {这里面放的是处理完所有的行后要执行的语句 }
	{这里面放的是处理每一行时要执行的语句}
	[condition1]{actions1}  [condition2]{actions2}

actions 由awk 语句组成, 可以用`next` 忽略后面的actions

	[condition1]{actions1;next}  [condition2]{actions2} ...

也可以忽略actions

	awk '{if(NR==1) next; print}'
	awk 'NR>1{print}'
	awk 'NR>1 && NR<=5{print}'

可以省略print

	awk 'NR>1'
	awk 'NR>1 && NR<=5'
	echo $'abc\nabcd' | gawk '!arr[$0]++'

## condtion

    start_condition,end_condition {action}

Example

	seq 10|gawk '/start_pattern/,/end_pattern/{print}'

### line
    ls -l | awk 'NR>=122 && NR<=129 { print }'
    ls -l | awk 'NR==1{ print }'

# Variable

## 变量参数

BEGIN　需要的变量，要用-v 设置

    awk -v var=10 'BEGIN {print var}'

    # 内置变量可以
    awk -v OFS=: 'BEGIN {print 1,2}'

非BEGIN　需要的变量, 可以在后面设置，并且可以省略-v

    $ awk 'NR==1 {print NR,$1,$2,$3,var}' OFS=":" var=10  <(echo a b c)
    1:a:b:c:10

## Inner Variables
说到了内建变量，我们可以来看看awk的一些内建变量：

- $0	当前记录（这个变量中存放着整个行的内容）
- $1~$n	当前记录的第n个字段，字段间由FS分隔
- $(NF-1)	当前记录的第n个字段，字段间由FS分隔
- NF	当前记录中的字段个数，就是有多少列(Num of Field)
- NR	已经读出的记录数(Line Recoder)，就是行号，从1开始，如果有多个文件话，这个值也是不断累加中。(Num of Record)
- FNR	当前记录数，与NR不同的是，这个值会是各个文件自己的行号
- FS	输入字段分隔符 默认是空格和Tab (Field Separator)
- RS	输入的记录分隔符， 默认为换行符
- OFS	输出字段分隔符， 默认也是空格
- ORS	输出的记录分隔符，默认为换行符
- FILENAME	当前输入文件的名字
- $5+ENVIRON["y"] 系统环境变量
- $ awk -v val=$x '{print $1+val}' a.txt val 是参数

### delimiter, 指定分隔符

	$  awk  'BEGIN{FS=":"} {print $1,$3,$6}' /etc/passwd
	# It same as
	$ awk  -F: '{print $1,$3,$6}' /etc/passwd

multiple delimiter:

	cat file | awk -F'[/=]' '{print $3 "\t" $5 "\t" $8}'

escape delimiter, FS is an Extended Regular Expression where "|" is special:

	-F '\\|\\|'

### 忽略第一列
will print all but very first column:

    awk '{$1=""; print $0}' somefile

will print all but two first columns:

    awk '{$1=$2=""; print $0}' somefile

# array

	#awk 将 myarr["1"] 和 myarr[1] 指向同一元素, 这类似于索引php不区别引号
    # 索引从1开始
	myarray[1]="jim"
	myarray['name']="Ye"

## init

    gawk 'BEGIN{arr[1]="name"; for(k in arr)print arr[k]}'

## push, pop, unshift

    function push(A,B) { A[length(A)+1] = B }

实现unshift 比较复杂: https://github.com/xfix/awk-plus-plus

    function unshift(arr, value, array) {
        clone(array, arr)
        empty(arr)
        push(arr, value)
        for (i = 1; i <= len(array); i++) {
            push(arr, array[i])
        }
    }
    function empty(array) {
        split("", array)
    }
    function clone(ret, array, key) {
        for (key in array) {
            ret[key] = array[key]
        }
    }
## delete

	delete arr[1]


## in_array
In array:

	if('Ye' in myarray){
		print "Yep! It's here!"
	}
	if('Ye' in myarray == 1){
		print "Yep! It's here!"
	}

Not in array

	!('Ye' in myarray){
		print "No in array"
	}
	('Ye' in myarray == 0){
		print "No in array"
	}

取两文件的差集(difference set)(ori.txt - filter.txt):

	awk -F'|' 'NR==FNR{check[$0];next} !($1 in check){print $0}' filter.txt ori.txt
	awk -F'|' 'NR==FNR{check[$0];next} $1 in check{print $0}' filter.txt ori.txt

	-F'|'
		-- sets the field separator
	'NR==FNR{check[$0];next}
		-- if the total record number matches the file record number (i.e. we're reading the first file provided), then we populate an array and continue.
	$2 in check
		-- If the second field was mentioned in the array we created, print the line (which is the default action if no actions are provided).
	file2 file1
		-- the files. Order is important due to the NR==FNR construct.

## sort
sort and keep association:

	//asort
	gawk 'BEGIN{
		arr["a"]=1;arr["b"]=5;arr["c"]=4;
		n=asort(arr);
		for(i in arr){
			print i,arr[i];
		}
	}'


sort via index

	n=asorti(arr, sorted)
	for (i=1; i<=n; i++) {
			print sorted[i] " : " arr[sorted[i]]
	}

sort via shell:

	for(i in arr) print arr[i] | "sort";

## for-in

	for ( x in myarray ) { # ok
	for (x in myarray) { # wrong!(无空白)
		print myarray[x]
		//continue; break;
	}


# printf && print

	printf("%s got a %03d on the last test\n","Jim",83)
	myout=("%s-%d",b,x)
	print myout

	#print 打印字符串
	print "a" "b";#ab
	print "a""b";#ab
	print "a","b";#a b

	print "Hi" "," "how are you";# Hi how are you

## space pad

	awk '{printf "%04x", strtonum("0x"$1)}'
	awk '{printf "%04d", 9}'
		$1=9; output: 0009

# control

	exit
	break
	continue

## while

  while (n in a) n++
  if (n in a) n++

# Math
() 用于数学计算:

	awk 'BEGIN{print (1.5^2)}'

	x ^ y
	x ** y

Exponentiation; x raised to the y power. ‘2 ^ 3’ has the value eight; the character sequence ‘**’ is equivalent to ‘^’. (c.e.)

	- x
	Negation.

	+ x
	Unary plus; the expression is converted to a number.

	x * y
	x / y
	int(x/y); floor

Division; because all numbers in awk are floating-point numbers, the result is not rounded to an integer—‘3 / 4’ has the value 0.75. (It is a common mistake, especially for C programmers, to forget that all numbers in awk are floating point, and that division of integer-looking constants produces a real number, not an integer.)

	x % y

Remainder; further discussion is provided in the text, just after this list.

	x + y

Addition.

	x - y

Subtraction.

## ceil floor

    int(1.5)
    ceil(3/8)
    function ceiling(x) {
        return (x == int(x)) ? x : int(x)+1
    }

you could also write a `round(2.5)` function.

# time

	systime(); unix timestamp

# String

## quotation marks 引号
awk 的字符串是以双引号括起来的 不可用单引号

	print "aa\\ a \t b";

在shell 中使用引号真是令人难受（你需要考虑错综复杂的shell转义）

## regex

### replace
gsub - replace

	echo 'abc,123 ,' | awk -F\, '{gsub(/[ \t]+$/, "", $2); print $2 ":"}'
		123:

### capture group(match as capture)
The GAWK regular expression engine capture its groups.

    gawk 'match($0, pattern, ary) {print ary[1]}'
    echo "abcdef" | gawk 'match($0, /b(.*)e/, a) {print a[1]}'
    gawk 'match($0, /<td>(.*)<\/td>/, arr){n++;}'

Use perl instead:

    perl -n -e'/test(\d+)/ && print $1'

The `-n` flag causes perl to loop over every line like awk does.

### match as index
awk 中的位置都是从1开始的

	match(str, needle);//return the position of needle
	match(mystring,/you/); # 如果没有找到, 返回0
	index("mainstr", 'str'); #5 从1开始

## String Func

	tolower(str)
	toupper(str)
	split(s,arr,fs)：在fs上将s分成序列arr
	split("name,age,gender",arr,",")：在fs上将s分成序列arr

### strpad
start from 1

	function strpad(string) {return substr("0000" string, length(string) + 1)}
	awk 'function pad(string) {return substr("0000" string, length(string) + 1)} {print pad($1), pad($2)}'

### replace
self replace self:

	sub(regexp,replstring[,mystring=$0])
	gsub(regexp,replstring[,mystring=$0]); #全局替换

Example

	echo '2014-1-1 hilojack hilojack' | awk 'gsub("hilojack","ahui")'
	echo '2014-1-1 hilojack hilojack' | awk 'gsub("hilojack","ahui"){print $0}'
		2014-1-1 ahui ahui
	echo '2014-1-1 hilojack hilojack' | awk 'gsub("hilojack","ahui", $3)'
		2014-1-1 hilojack ahui
	echo '2014-1-1 hilojack hilojack' | awk '$1=gsub("-","ahui", $1)';#返回替换次数
		2 hilojack hilojack
	echo '2014-1-1 hilojack hilojack' | awk 'length()'
        2014-1-1 hilojack hilojack

### substr

	substr(mystring,startpos,maxlen=infinite); pos 从1 开始

## length

	{print length(str=$0)}
	echo '2014-1-1 hilojack hilojack' | awk '$0=length()';$0 被改写了
	26

### Concat

	var=var $2
	varA="string" varB		$2

以空格分隔输出

    print varA,varB

### Split

	n=split("Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec",mymonths,",")
	调用 split() 时，第一个自变量包含要切开文字字符串或字符串变量。在第二个自变量中，应该指定 split() 将填入片段部分的数组名称。在第三个元素中，指定用于切开字符串的分隔符。split() 返回时，它将返回分割的字符串元素的数量。split() 将每一个片段赋值给下标从 1 开始的数组，因此以下代码：
	print mymonths[1],mymonths[n]

example:

    $ gawk 'END{ var=FILENAME; n=split(var,a,/\//); print a[n]}' ./migrate.sh
    migrate.sh

    awk ' function basename(file, a, n) {
        n = split(file, a, "/")
        return a[n]
    }
    {print FILENAME, basename(FILENAME)}' /path/to/file


### 简短注释
调用 `length($0)、sub($0) 或 gsub($0)` 时，可以去掉最后一个自变量`$0`。要打印文件中每一行的长度，使用以下 awk 脚本：

	{ print length() }

## 字符串匹配

	$ awk '$6 ~ /FIN/ || NR==1 {print NR,$4,$5,$6}' OFS="\t" netstat.txt #~ 模式匹配开始

	$ awk '/LISTEN/' netstat.txt
	# Same as Below
	$ grep -F 'LISTEN' netstat.txt
	$ awk '/FIN|TIME/' netstat.txt

	awk '/[0-9]+\.[0-9]*/ { print }'
		$1 == "fred" { print $3 }
		$5 ~ /root/ { print $3 }

Ignore Case:

	x = "aB"
	if (tolower(x) ~ /ab/) ...   # this test will succeed

	IGNORECASE = 1
	if (x ~ /ab/) ...   # now it will succeed

### NOT
可参考`Comparision Operators`

	$ awk '$6 !~ /WAIT/ || NR==1 {print NR,$4,$5,$6}' OFS="\t" netstat.txt # ~ 模式匹配开始
	$ awk '$6 !~ /WAIT/' netstat.txt
	$ awk '!/WAIT/' netstat.txt
    
# func

## strpad
start from 1

	function strpad(string) {return substr("0000" string, length(string) + 1)}
	awk 'function pad(string) {return substr("0000" string, length(string) + 1)} {print pad($1), pad($2)}'

# Number
支持+、-、*、/、%、++、–、+=、-=等诸多操作；

	gawk 'BEGIN{i=9;j=1; i+=j;print i}'
	gawk 'BEGIN{i=9;j=1; i+=j;print i>j}'

支持==、!=、>、=>、~（匹配于）等诸多判断操作；

## math

	print sin(1)
	print int(rand()*100);
	print sqrt(4)

## float
默认显示float 时，awk 会对float 4舍5入：

	awk 'BEGIN{printf("%f\n", 111199989/100)'

# Expresion

## Comparision Operators
Comparision Operators:

	== >= <= !=
	Expression	Result
	x < y	True if x is less than y
	x <= y	True if x is less than or equal to y
	x > y	True if x is greater than y
	x >= y	True if x is greater than or equal to y
	x == y	True if x is equal to y
	x != y	True if x is not equal to y
	x ~ y	True if the string x matches the regexp denoted by y
	x !~ y	True if the string x does not match the regexp denoted by y
	subscript in array	True if the array array has an element with the subscript subscript

	$ awk '$3==0 && $6=="LISTEN" ' netstat.txt
	$ awk ' $3>0 {print $0}' netstat.txt
	# 如果需要第一行(NR表示行数)
	$ awk '$3==0 && $6=="LISTEN" || NR==1 ' netstat.txt

## Logical Operators

	( $1 == "foo" ) && ( $2 == "bar" ) { print } #cmd line
	$1 == "foo"  ||  $2 == "bar"  { print } #cmd line
	&& || !

## if
去重

	echo $'abc\nabc' | gawk '!arr[$0]++'

## Condition Expresion
1. 命令行

	$ awk 'NR!=1{if($6 ~ /TIME|ESTABLISHED/) print > "1.txt";
		else if($6 ~ /LISTEN/) {print > "2.txt";}
		else print > "3.txt" }' netstat.txt

2. Script脚本

	cat condition.awk
		{
			 if ( $1 == "foo" ) {
				if ( $2 == "foo" ) {
				   print "uno"
				} else {
				   print "one"
				}
			 } else if ($1 == "bar" ) {
				print "two"
			 } else {
				print "three"
			 }
		}

多个条件(if 是可以省略的):

	( $1 == "foo" ) && ( $2 == "bar" ) { print } #cmd line
	$1 == "foo"  &&  $2 == "bar"  { print } #cmd line

## sub expression

	echo 'ab,1203: , ' | gawk -F\, '{
		gsub(/[ \t]+$/, "", $2);
		if(match($2, /1(.*)/, ary)){
			print(ary[1])
		}
	}'

## do-while

	{
		 count=1
		 do {
				print "I get printed at least once no matter what"
			if( x == 10 ){
				break
				continue
			}
		 } while ( count != 1 )
	}

## for

	for ( x = 1; x <= 4; x++ ) {
		 print "iteration",x
	}

### statistic, 统计

	$ ls -l  *.cpp *.c *.h | awk '{sum+=$5} END {print sum}'
	$ awk 'NR!=1{a[$6]++;} END {for (i in a) print i ", " a[i];}' netstat.txt

# Split File
> shell 原生命令`split -l<line_count> -a <suffix_num> -d prefix`

按第6列拆分文件:

	$ awk 'NR!=1{print > $6}' netstat.txt #$6 是文件名

指定列

	$ awk 'NR!=1{print $4,$5 > $6}' netstat.txt; # > 其实是append

# Script

	 awk -f my.awk file
	 cat my.awk

	 	BEGIN {
			 FS=":"
		 }
		 { print $1 }

## comments

	# comments

## 语句
多条语句可以使用换行，或者分号。这类似于js

	awk 'BEGIN{str="abc";print length(str)}'

## shell
awk 中使用shell 命令

	"shell_cmd1"|"shell_cmd2"; //return output of cmd2
	"shell_cmd1"|awk_cmd;

Example:

	awk 'BEGIN{print "abc"|"grep c"}'

	"shell_cmd" | getline;//no output
	("shell_cmd" | getline);//1: succ 0:failed(getline will not run)
	system(shell_cmd);//0:succ, not 0:failed

或者使用system 开启shell 子进程

	awk 'BEGIN{system("echo abc | grep c")}'

system, 成功返回0，失败返回非0(如127)

## read file
使用getline 命令 读重定向

	awk 'BEGIN{while(getline<"date.txt"){print $0}}' #$0 可省略

使用getline 命令 读取管道定向的流, 成功返回1, 失败返回0
读取第一行

	awk 'BEGIN{"cat a.txt"|getline line; print line}'
	awk 'BEGIN{"cat date.txt"|getline; print $0}'

## pipe
get output from shell command

	cmd = "strip "$1
	while ( ( cmd | getline result ) > 0 ) {
	  print  result
	}
	close(cmd); # close pipe or file

Closing Input and Output Redirections(Pipe) via `close(cmd)`