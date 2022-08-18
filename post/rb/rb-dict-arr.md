---
title: ruby shell
date: 2020-03-02
private: true
---
# Array
## define array
    arr = 'js','python','ts'
    arr = ['js','python','ts']
    arr = (1..10).to_a
    arr = %w(Jane, aara, multiko)

空数组：

    Array.new

元素全为nil的空数组：

    names = Array.new(20)
    names = Array.new 20
    puts names.size  # 返回 20
    puts names.length # 返回 20

padding 4 'good' elelement

    names = Array.new(4, 'Lucy')

序列

    #python: range(0,20,2)
    nums = Array.new(10) { |e| e = e * 2 }
    #range(0,10)
    digits = Array(0..9)
 

## 编辑数组
数组字面量通过[]中以逗号分隔定义，且支持range定义。

    （1）数组通过[]索引访问
    （2）通过赋值操作插入、删除、替换元素
    （3）通过+，－号进行合并和删除元素，且集合做为新集合出现
    （4）通过<<号向原数据追加元素: `arr<<"new ele"`
    （5）通过*号重复数组元素

### insert,pop,push

    array.insert(index, obj...)
        在给定的 index 的元素前插入给定的值，index 可以是负值。
    array.pop 
        从 array 中移除最后一个元素，并返回该元素。如果 array 为空则返回 nil。
    array.push(obj, ...)
        把给定的 obj 附加到数组的末尾。该表达式返回数组本身，所以几个附加可以连在一起。
    arr<<ele
        push

### append

    arr << ele  
    arr << ele  if true
    arr << ele  if build.with? "iconv"

### delete

#### delete obj
从 self 中删除等于 obj 的项。如果未找到相等项，则返回 nil。如果未找到相等项且给出了可选的代码 block，则返回 block 的结果。

    array.delete(obj) [or]
    array.delete(obj) { block }

#### delete index
删除指定的 index 处的元素，并返回该元素。如果 index 超出范围，则返回 nil。

    array.delete_at(index)
    arr.delete_at(arr.index(44))

#### delete by block
当 block 为 true 时，删除 self 的每个元素。

    array.delete_if { |item| block }
    [2,4,6,3,8,3].delete_if {|x| x == 3 } 

##### delete range
删除 index（长度是可选的）或 range 指定的元素。返回被删除的对象、子数组，如果 index 超出范围，则返回 nil。

    array.slice!(index) [or] array.slice!(start, length) [or]
    array.slice!(range)

##### replace
完全用arr2代替arr1

    #等价
    arr1.replace(arr2)
    arr1 = arr2

### map
    words = %w(Jane, aara, multiko)
    upcase_words = words.map(&:upcase)

### sort
返回一个排序的数组。

    array.sort [or] array.sort { | a,b | block }

把数组进行排序。

    array.sort! [or] array.sort! { | a,b | block }

#### uniq
    array.uniq
    array.uniq!


## 集合
### 交集并集差集
通过`｜和&`符号做并集和交集操作（注意顺序
    arr | arr2
        并集
    arr & arr2
        交集
    arr - arr2
        差集
    arr + arr2
        并集（不去重合）
        array.concat(other_array)

### 比较
如果数组小于、等于或大于 other_array，则返回一个整数（-1、 0 或 +1）。

    array <=> other_array

如果两个数组包含相同的元素个数，且每个元素与另一个数组中相对应的元素相等（根据 Object.==），那么这两个数组相等。

    array == other_array

空数组判断：

    array.empty?

    array.eql?(other)

类型匹配比较

    .eql?	类型匹配。	
        1 == 1.0 返回 true，但是 1.eql?(1.0) 返回 false。
    equal?	如果接收器和参数具有相同的对象 id，则返回 true。	
        如果 aObj 是 bObj 的副本，那么 aObj == bObj 返回 true，

## 访问数组元素
### 访问元素
    arr[-1]
    arr.slice(index) == arr[index]
    arr.slice(start, length) 

#### 取值器fetch
尝试返回位置 index 处的元素。如果 index 位于数组外部，则第一种形式会抛出 IndexError 异常，第二种形式会返回 default，第三种形式会返回调用 block 传入 index 的值。负值的 index 从数组末尾开始计数

    array.fetch(index) [or] 相比：array[index]不存在则返回nil
    array.fetch(index, default) [or]
    array.fetch(index) { |index| block }

### 长度

    def sample (*test)
        puts "参数个数为 #{test.length}"
        for i in 0...test.length
            puts "参数值为 #{test[i]}"
        end
    end

### loop 遍历
    arr = [ "fred", 10, 3.14, "This is a string", "last element", ]
    for i in arr
        puts i
    end

### for in

    for i in [1,2,3] do
    end

#### each
    arr.each do |i|
        puts i
    end
    arr.each_index do |index|
        puts arr[index]
    end

#### map
为 self 的每个元素调用一次 block。创建一个新的数组，包含 block 返回的值。

    array.map { |item| block } [or]
    array.collect { |item| block }

为 array 的每个元素调用一次 block，把元素替换为 block 返回的值。

    array.map! { |item| block } [or]
    array.collect! { |item| block }

## 查找
如果 self 中包含 obj，则返回 true，否则返回 false。

    array.include?(obj)

返回 self 中第一个等于 obj 的对象的 index。如果未找到匹配则返回 nil。

    array.index(obj)

## 转换
### array vs string
    'a,b,c'.split(',')
    array.join(sep=$,)

### clone
浅复制

    b = a.clone
    b = a.collect{ |x|x }

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

    //or
    (0..9).each {|n| p n; break}

或者：

    for i in 0..5
        puts "局部变量的值为 #{i}"
    end

# hash
## define hash
string key

    grades = { "Jane Doe" => 10, "Jim Doe" => 6 }
    grades = Hash[ "Jane Doe" => 10, "Jim Doe" => 6 ]
    grades['Jane Doe']

symbol key: `:symbol` 是一种symbol类型数据

    options = { font_size: 10, font_family: "Arial" }
    options = { :font_size => 10, :font_family => "Arial" }
    options[:font_size]

symbol value: `:symbol` 是一种symbol类型数据

    options = {:key=>:value}
    options = {key: :value}
    options[:key]==:value

### 传值

    # 等价
    fun({k:1,f:2}, arg2,arg3)
    fun ({k:1,f:2}), arg2,arg3

    # 等价
    fun({k:1,f:2})
    fun(k:1,f:2)
    fun k:1,f:2

## access dict

### length 
    hash.length

### read value
via key

    options['key']
    hash.fetch(key [, default] ) [or]
    # 不可以用options.key

values

    hash.values

检查 hash 是否包含给定的 value。

    hash.value?(value)
### read keys
    hsh.keys

检查给定的 key 是否存在于哈希中，返回 true 或 false。

    hash.has_key?(key) [or] hash.include?(key) [or]
    hash.key?(key) [or] hash.member?(key)

## loop hash
    hsh = colors = { "red" => 0xf00, "green" => 0x0f0, "blue" => 0x00f }
    for key, value in hsh
        print key, " is ", value, "\n"
    end
    hsh.each do |key, value|
        print key, " is ", value, "\n"
    end

## edit hash
### merge hash
    hash.merge(other_hash) [or]
    hash.merge(other_hash) { |key, oldval, newval| block }
    hash.merge!(other_hash) [or]

不支持：

    hsh1+hsh2

# hash obj
    # require "hashie" # if not gem
    hsh = Hashie::Mash.new("latitude"=>"40.695")
    hsh = Hashie::Mash.new(latitude:40.695)
    hsh.latitude
    => "40.695"