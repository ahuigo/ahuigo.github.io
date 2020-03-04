---
title: Buby string
date: 2020-02-29
private: true
---
# ruby string
## define string
单引号字面义（类似php）

    'a\nb'

双绰号转义：

    "a\nb"
    "#{prefix}"

## heredoc
`<<` 与`<<-`好像是等价的？

    <<- 不含tab和首尾空白
    <<~ 不含tab, 但含首尾空白
    <<~MARK.strip 不含tab, 也不含首尾空白

heredoc: 不含tab和首尾空白

    query = <<-SQL
        SELECT * FROM food WHERE healthy = true
    SQL

或者(You'll get an extra newline at the start & end of this string)：

    query = %Q(
        Article about heredocs
    )

## format
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
    str[start..end]
    str[start...end]
    str[0...-1]

## strip
只移除末尾的`"\r\n"`

    str.chomp
    # inplace replace
    str.chomp!


# print
打印text

    puts 1,2,3
    printf `ls *`

打印raw+返回

    p 1,2,3
    array=p 1,2,3

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

