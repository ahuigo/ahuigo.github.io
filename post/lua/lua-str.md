---
title: lua str
date: 2020-05-04
private: true
---

# lua str

## Define String

不区分single/double quote

    print("a\nb")
    print('a\nb')

### multiple line

    str= 'begin-' .. 
    'end'

可以用 2 个方括号 `[[]]` 来表示"一块"字符串。

    doc = [[
        string
    ]]
    doc = [[ string ]] --空白也是字符

### check empty string

    if str ~= '' then
        ...

    local function isempty(s)
      return s == nil or s == ''
    end

expr:

    == -- Equal to whatever
    <= -- Less than or equal to
    >= -- Greater than or equal to
    < -- Less than
    > -- Greater Than
    ~= -- Doesnt equal
    # -- Length of something

## str func

### string length

`#`返回字符串或表的长度。

    print(#"str len")
    print(#[[str len]])

### concat

    str1 .. str2
    str1..str2

### reverse

    > string.reverse("Lua")

### pad & repeat

返回字符串string的n个拷贝

    string.rep(string, n)
    > string.rep("abcd",2)
    abcdabcd

### format

    string.upper(str):

    print(string.format("日期格式化 %02d/%02d/%03d", date, month, year))
    print(string.format("%.4f",1/3))

### split/join

ngx only

    local t, err = ngx_re.split(cookie, ";")

# Bytes/char

    string.char(arg) 和 string.byte(arg[,int])

char 将整型数字转成字符并连接， byte 转换字符为整数值(可以指定某个字符，默认第一个字符, 不是从0开始)。

    > string.char(97,98,99,100)
    abcd
    > string.byte("ABCD",4)
    > string.byte("ABCD",-1)
    68
    > string.byte("ABCD")
    65

# regex

## char

在模式匹配中有一些特殊字符，他们有特殊的意义，Lua中的特殊字符如下：

    ( ) . % + - * ? [ ^ $

单个字符(除 `^$()%.[]*+-?` 外): 与该字符自身配对

    .(点): 与任何字符配对
    %a: 与任何字母配对
    %c: 与任何控制符配对(例如\n)
    %d: 与任何数字配对
    %l: 与任何小写字母配对
    %p: 与任何标点(punctuation)配对
    %s: 与空白字符配对
    %u: 与任何大写字母配对
    %w: 与任何字母/数字配对
    %x: 与任何十六进制数配对
    %z: 与任何代表0的字符配对
    %x(此处x是非字母非数字字符): 与字符x配对. 如：%% %$ %^ 
    [数个字符类]: 与任何[]中包含的字符类配对. 例如[%w_]与任何字母/数字, 或下划线符号(_)配对
    [^数个字符类]: 与任何不包含在[]中的字符类配对. 例如[^%s]与任何非空白字符配对

上述的字符类用大写书写时, 表示与非此字符类的任何字符配对. 例如, %S表示与任何非空白字符配对.例如，'%A'非字母的字符:

    > a,b = string.gsub("hello, up-down!", "%A", ".")
    > print(a,b)
    hello..up.down.    4

模式条目可以是：

    单个字符类匹配该类别中任意单个字符；
    单个字符类跟一个 '*'， 将匹配零或多个该类的字符。 这个条目总是匹配尽可能长的串；
    单个字符类跟一个 '+'， 将匹配一或更多个该类的字符。 这个条目总是匹配尽可能长的串；
    单个字符类跟一个 '-'， 将匹配零或更多个该类的字符。 和 '*' 不同， 这个条目总是匹配尽可能短的串；
    单个字符类跟一个 '?'， 将匹配零或一个该类的字符。 只要有可能，它会匹配一个；
    %n， 这里的 n 可以从 1 到 9； 这个条目匹配一个等于 n 号捕获物（后面有描述）的子串。
    %bxy， 这里的 x 和 y 是两个明确的字符； 这个条目匹配以 x 开始 y 结束， 且其中 x 和 y 保持 平衡 的字符串。 意思是，如果从左到右读这个字符串，对每次读到一个 x 就 +1 ，读到一个 y 就 -1， 最终结束处的那个 y 是第一个记数到 0 的 y。 举个例子，条目 %b() 可以匹配到括号平衡的表达式。
    %f[set]， 指 边境模式； 这个条目会匹配到一个位于 set 内某个字符之前的一个空串， 且这个位置的前一个字符不属于 set 。 集合 set 的含义如前面所述。 匹配出的那个空串之开始和结束点的计算就看成该处有个字符 '\0' 一样。

## match/gmatch

### string.match(str, pattern, init)

string.match()只寻找源字串str中的第一个配对. 参数init可选, 指定搜寻过程的起点, 默认为1。

如果没有设置捕获标记, 则返回整个配对字符串. 当没有成功的配对时, 返回nil。

    > a = string.match("I have 2 questions for you.", "%d+ %a+")
    > print(a)
    2 questions
    > a,b= string.match("a",'b+')
    > print(a,b)
    nil nil

group match 会返回多个值

    > = string.format("%d, %q", string.match("I have 2 questions for you.", "(%d+) (%a+)"))
    2, "questions"

### string.gmatch(str, pattern)

回一个迭代器函数，每一次调用这个函数，返回一个在字符串 str 找到的下一个符合 pattern 描述的子串。如果参数 pattern
描述的字符串没有找到，迭代函数返回nil。

    > for word in string.gmatch("Hello Lua user", "%a+") do print(word) end
    Hello
    Lua
    user

## find

    > = string.find("I have 2 questions for you.", "(%d+) (%a+)")
    	string.find (str, substr, [init, [end]])

在一个指定的目标字符串中搜索指定的内容(第三个参数为索引),返回其具体位置。不存在则返回 nil。

    > string.find("Hello Lua user", "Lua", 1) 
    7    9

## gsub 替换

    = string.gsub("---aaaa","a","z",1);
    ---zaaa    1

gsub 支持group capture

    =string.gsub("ab","(a)(b)","%2:%1");
    b:a     1

## sub(slice)

    s = "hello"
    = string.sub(s, 2, string.len(s))
