---
title: Buby string
date: 2020-02-29
private: true
---
# ruby string 类型

## define string
单引号字面义（类似php）

    'a\nb'

### 双绰号值插入：

    age=1
    p "age: #{a}"

但是对于全局变量、实例变量和类变量，Ruby 提供了一个简写形式：#$global, #@instance 和 #@@class

### 双绰号转义：

    "a\nb"
    "#{30+90}"
    "\xfe\xff\xfe\xff"

转义列表

    \b	退格键 (0x08)
    \a	报警符 Bell (0x07)
    \e	转义符 (0x1b)
    \s	空格符 (0x20)
    \nnn	八进制表示法 (n 是 0-7)
    \xnn	十六进制表示法 (n 是 0-9、a-f 或 A-F)
    \cx, \C-x	Control-x
    \M-x	Meta-x (c | 0x80)
    \M-\C-x	Meta-Control-x
    \x	字符 x

## heredoc
    print <<EOF
        这是第一种方式创建here document 。
        多行字符串。
        #{var}
    EOF

    print <<"EOF";                # 与上面相同
        这是第二种方式创建here document 。
        多行字符串。
        #{var}
    EOF

    print <<`EOC`                 # 执行命令
        echo hi there
        echo lo there
    EOC

`<<` 与`<<-`不等价的

    << 不过滤tab和首尾空白
    <<- 过滤tab, 但含首尾空白
    <<~ 过滤tab、过滤首尾空白
    <<~MARK.strip 过滤tab, 也过滤首尾空白

heredoc: 过滤tab和首尾空白

    query = <<-SQL
        SELECT * FROM food WHERE healthy = true
    SQL

或者(You'll get an extra newline at the start & end of this string)：

    query = %Q(
        Article about heredocs
    )

### inline string
`#`引入变量(类似js `${name}`)

    x, y, z = 12, 36, 72
    puts "x 的值为 #{ x }"

%q 使用的是单引号引用规则，而 %Q 是双引号引用规则，后面再接一个 `([ {` 等等的开始界定符和与 `} ] )` 等等的末尾界定符。

    desc1 = %Q{Ruby 的字符串可以使用 '' 和 ""。}
    desc2 = %q|Ruby 的字符串可以使用 '' 和 ""。|
    puts desc1
    puts desc2

## 中文
Ruby 使用用 ASCII 编码来读源码，中文会出现乱码，解决方法为

    #!/usr/bin/ruby -w
    # -*- coding: UTF-8 -*-
    
    puts "你好，世界！";

# access string
## slice string
    str[position] # 注意返回的是ASCII码而不是字符
    str[start, length]
    str[start..end] # 包含end
    str[start...end] # 不包end
    str[0...-1]
    str[-3..-1] # 最后3个

first-last:

    2.4.1 :010 > a.chars.last(5).join
    => "fghij"
    2.4.1 :011 > a.chars.last(100).join
    => "abcdefghij"

If you're using Ruby on Rails:

    [2] pry(main)> a.first(3)                                                                                                                   
    => "abc"
    [3] pry(main)> a.last(4)                                                                                                                    
    => "defg"

## padding

    '123'.rjust(5, '.')
    > ..123

## strip
只移除末尾的`"\r\n"`

    str.chomp
    # inplace replace
    str.chomp!

# function
## ord
    "a".ord # 97
## upper,lower

    'aaa'.upcase
    'AAA'.downcase

## hash
    str.hash

## concat

    dir = Dir.home+"/www"
    dir = "#{Dir.home}/www"

## repeat

    'ahui'*3

## index
返回给定子字符串、字符（fixnum）或模式（regexp）在 str 中第一次出现的索引。如果未找到则返回 nil

	str.index(substring [, offset]) [or]
    str.index(fixnum [, offset]) [or]
    str.index(regexp [, offset])

最后一次出现的索引

    str.rindex

### startWith
    if 'abc'.start_with? 'ab' 
    if SomeString.match(/^abc/) 

### include

    if my_string.include? "cde"

## strip
	str.rstrip
    str.rstrip! 从 str 中移除尾随的空格，如果没有变化则返回 nil。

	str.lstrip
	str.lstrip!

	str.strip
	str.strip!

## split
    str.split(pattern=$;, [limit])

基于分隔符，把 str 分成子字符串，并返回这些子字符串的数组。

    如果 pattern 是一个字符串 String，那么在分割 str 时，它将作为分隔符使用。如果 pattern 是一个单一的空格，那么 str 是基于空格进行分割，会忽略前导空格和连续空格字符。
    如果 pattern 是一个正则表达式 Regexp，则 str 在 pattern 匹配的地方被分割。当 pattern 匹配一个零长度的字符串时，str 被分割成单个字符。
    如果省略了 pattern 参数，则使用 $; 的值。如果 $; 为 nil（默认的），str 基于空格进行分割，就像是指定了 ` ` 作为分隔符一样。

如果省略了 limit 参数，会抑制尾随的 null 字段。如果 limit 是一个正数，则最多返回该数量的字段（如果 limit 为 1，则返回整个字符串作为数组中的唯一入口）。如果 limit 是一个负数，则返回的字段数量不限制，且不抑制尾随的 null 字段。

## pad
如果 integer 大于 str 的长度，就对齐

    str.rjust(integer, padstr=' ')
    str.ljust(integer, padstr=' ')

## match
如果 pattern 不是正则表达式，则把 pattern 转换为正则表达式 Regexp，然后在 str 上调用它的匹配方法。

	str.match(pattern)

针对每个匹配，会生成一个结果，结果会添加到结果数组中或传递给 block。

    str.scan(pattern) [or]
    str.scan(pattern) { |match, ...| block }

## replace:sub
把 str 中的内容替换为 other_str 中的相对应的值。

    str.sub(pattern, replacement) [or]
    str.sub(pattern) { |match| block }
    str.sub!(pattern, replacement) [or]
    str.sub!(pattern) { |match| block }

e.g.


    'abc'.gsub('ab','AB')
    'abc'.gsub(/^ab/,'AB')