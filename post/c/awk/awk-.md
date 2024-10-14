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
gawk 的变量全局作用域，都可访问的
## 变量参数

BEGIN　需要的变量，要用-v 设置

    awk -v var=10 'BEGIN {print var}'

    # 内置变量可以
    awk -v OFS=: 'BEGIN {print 1,2}'

非BEGIN　需要的变量, 可以在后面设置，并且可以省略-v

    $ awk 'NR==1 {print NR,$1,$2,$3,var}' OFS=":" var=10  <(echo a b c)
    1:a:b:c:10

## 定义变量
定义声明必须在语句快中，函数定义则在语句块外

    BEGIN {
        name1 = "Alex"
        print name1
    }
    END {
        name2 = "Alex2"
        print name1,name2
    }

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


# time

	systime(); unix timestamp
