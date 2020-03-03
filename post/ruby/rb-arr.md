---
title: ruby shell
date: 2020-03-02
private: true
---
# Array
    arr = 'js','python','ts',

## 操作数组
数组字面量通过[]中以逗号分隔定义，且支持range定义。

    （1）数组通过[]索引访问
    （2）通过赋值操作插入、删除、替换元素
    （3）通过+，－号进行合并和删除元素，且集合做为新集合出现
    （4）通过<<号向原数据追加元素: `arr<<"new ele"`
    （5）通过*号重复数组元素
    （6）通过｜和&符号做并集和交集操作（注意顺序

## loop each
    ary = [ "fred", 10, 3.14, "This is a string", "last element", ]
    ary.each do |i|
        puts i
    end

# range
    (1..5)        #==> 1, 2, 3, 4, 5
    (1...5)       #==> 1, 2, 3, 4
    ('a'..'d')    #==> 'a', 'b', 'c', 'd'

## range to array
    $, =", "   # Array 值分隔符
    range1 = (1..10).to_a
    # [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    # ["bar", "bas", "bat"]
    range2 = ('bar'..'bat').to_a

## range operation
    digits = 0..9
    
    puts digits.include?(5)
    ret = digits.min
    puts "最小值为 #{ret}"
    
    ret = digits.max
    puts "最大值为 #{ret}"
    
    ret = digits.reject {|i| i < 5 }
    puts "不符合条件的有 #{ret}"

## range include
    if (('a'..'j') === 'c')
        puts "c 在 ('a'..'j')"
    end

    if (0...9).include?(5)
        puts 'yes'
    end

## range when
    score = 70

    result = case score
    when 0..40
        "糟糕的分数"
    when 71..100
        "良好分数"
    else
        "其它分数"
    end
 
## range while if
while if 是一体的，下面的代码片段从标准输入打印行，其中每个集合的以单词 start开始，以end结束.

    while gets
        print if /start/../end/
    end

## range loop

    (0..9).each do |n|
        print n, ' '
    end

或者：

    for i in 0..5
        puts "局部变量的值为 #{i}"
    end

# hash
string key

    grades = { "Jane Doe" => 10, "Jim Doe" => 6 }
    grades['Jane Doe']

symbol key

    options = { font_size: 10, font_family: "Arial" }
    options = { :font_size => 10, :font_family => "Arial" }
    options[:font_size]

symbol value:

    options = {:key=>:value}
    options[:key]==:value

## loop
    hsh = colors = { "red" => 0xf00, "green" => 0x0f0, "blue" => 0x00f }
    hsh.each do |key, value|
        print key, " is ", value, "\n"
    end

