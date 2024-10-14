---
title: awk expr
date: 2024-09-30
private: true
---
# 语句语法
## comments

	# comments

## 条件语句块
### BEGIN语句块
多条语句可以使用换行，或者分号。这类似于js

	awk 'BEGIN{str="abc";print length(str)}'

### 模式匹配语句快
过滤GRANT 开始的所有行

    gawk '/^GRANT /{exit} {print}' minicell.sql 
    gsed -n '/^GRANT /q;p' minicell.sql 

# Expresion 表达式语法

## 三元运算符
	SUPOUT = " > /dev/null "
	SUPERR = " 2> /dev/null "
	Pager = ! system("less -V" SUPOUT SUPERR) ? "less" : (! system("more -V" SUPOUT SUPERR) ? "more" : "")

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


### not if
判空

    function parameterize(string, quotationMark) {
        if (! quotationMark) {
            quotationMark = "'"
        }
        if (quotationMark == "'") {
            gsub(/'/, "'\\''", string)
            return ("'" string "'")
        } else {
            return ("\"" escape(string) "\"")
        }
    }

去重

	echo $'abc\nabc' | gawk '!arr[$0]++'

解释

    1. 如果当前行的内容在 arr 数组中不存在，那么 arr[$0] 的值就是 0，!arr[$0]++ 的值就是 1，所以 AWK 会打印这一行。
    2. 如果当前行的内容在 arr 数组中已经存在，那么 arr[$0] 的值就大于 0，!arr[$0]++ 的值就是 0，所以 AWK 不会打印这一行

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

# 循环语句
## loop control

	exit
	break
	continue

## while

  while (n in a) n++
  if (n in a) n++

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
