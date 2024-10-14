---
title: awk string
date: 2024-10-01
private: true
---
# String
## quotation marks 引号
awk 的字符串是以双引号括起来的 不可用单引号

	gawk 'BEGIN{print "aa\\ a \t b";}'

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


RSTART 是 AWK 的内置变量，存储了最近一次 match 函数匹配的子字符串的位置(>1), 未匹配就是0

    match(ARGV[pos], /^--?(V|vers(i(on?)?)?)$/)
    if (RSTART) {
        InfoOnly = "version"
        continue
    }

将match匹配...

	match("'abc'", /^'(.*)'$/, temp)
	if (temp[0]) { 
        print "temp[0]: " temp[0]
        print "temp[1]: " temp[1]
    }

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

### concat string

	var=var $2
	varA="string" varB		$2

以空格分隔输出参数

    print varA,varB
    print(varA,varB)

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

# printf && print

	printf("%s got a %03d on the last test\n","Jim",83)
	myout=("%s-%d",b,x)
	print myout

	#print 打印字符串
	print "a" "b";#ab
	print "a""b";#ab
	print "a","b";print("a","b"); #a b

	print "Hi" "," "how are you";# Hi how are you

## space pad

	awk '{printf "%04x", strtonum("0x"$1)}'
	awk '{printf "%04d", 9}'
		$1=9; output: 0009
