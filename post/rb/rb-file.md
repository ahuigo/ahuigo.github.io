---
title: ruby file
date: 2020-05-17
private: true
---
# 标准io函数
## p 打印raw+返回

    > p "aa","bb"
    ["aa","bb"]
    => ["aa","bb"]

## puts/print 不会返回值
puts print 都是向控制台打印字符，其中puts带回车换行符 

    irb(main):004:0> puts "abc","cd"
    abc
    cd
    => nil

### gets,puts,putc
    puts "Enter a value :"
    val = gets
    puts val
    putc val #只输出第一个

### readline.chomp
不会包含换行符

    val = readline.chomp

# File IO
## file handler
    aFile = File.new("filename", "a+")
    aFile.close

    File.open("filename", "mode") do |aFile|
        # ... process the file
    end

mode: 

    r+ 读写
    w+ 读写(清空文件)
    a 只写(指针放最后)
    a+ 读写(追加)

标准输入

    STDIN do {|aFile|...}

## 读写
### 读全部
    text = d.read
    d.write(text)

### 按行
#### 按行读写

    aFile.gets
    aFile.puts "This is a temporary file"
#### 行迭代
    IO.foreach("input.txt"){|line| puts line}
#### 行数组
    arr = IO.readlines("input.txt")

### 按字符数读写: sysread-syswrite
    aFile = File.new("input.txt", "r+")
    if aFile
        content = aFile.sysread(20) #边界会有异常
        aFile.syswrite("ABCDEF")
    end
### 按字符读写: each_byte

    aFile.each_byte {|ch| putc ch; putc ?. }

## 指针移动pos
读取pos

    d.tell
    d.pos

改写pos

    d.rewind
    d.pos= offset
    d.seek(pos)

# Directory 操作
## rwx 操作
    File.readable?( "test.txt" )   # => true
    File.writable?( "test.txt" )   # => true
    File.executable?( "test.txt" ) # => false

改写:

    file = File.new( "test.txt", "w" )
    file.chmod( 0755 )

## dir 属性
### file exists
    File.open("file.rb") if File::exists?( "file.rb" )
    File.file?( "text.txt" )

### file type
ftype 方法通过返回下列中的某个值来标识了文件的类型：file、 directory、 characterSpecial、 blockSpecial、 fifo、 link、 socket 或 unknown。

    File::directory?( "/usr/local/bin" ) # => true
    File::ftype( "test.txt" )     # => file
 
### filesize查询 
    File.zero?( "test.txt" )      # => true
    File.size?( "text.txt" )     # => 1002

### file time
    File::ctime( "test.txt" ) # => Fri May 09 10:06:37 -0700 2008
    File::mtime( "text.txt" ) # => Fri May 09 10:44:44 -0700 2008
    File::atime( "text.txt" ) # => Fri May 09 10:45:01 -0700 2008

## dir遍历
    Dir.entries('.').each{|filename| p filename}

glob 遍历

    Dir["/usr/bin/*"].each{}

### pwd,chdir
    Dir.chdir("/usr/bin")
    puts Dir.pwd # 返回当前目录，类似 /usr/bin

## 改写dir
### 重命名和删除文件
    File.rename( "test1.txt", "test2.txt" )
    File.delete("text2.txt")

### mkdir/rmdir
    Dir.mkdir("mynewdir")
    Dir.mkdir( "mynewdir", 755 )

删除目录

    Dir.delete("testdir")

### 创建文件 & 临时目录
临时文件是那些在程序执行过程中被简单地创建，但不会永久性存储的信息。

    require 'tmpdir'
    tempfilename = File.join(Dir.tmpdir, "tingtong")
    tempfile = File.new(tempfilename, "w")
    tempfile.puts "This is a temporary file"
    tempfile.close
    File.delete(tempfilename)

这段代码创建了一个临时文件，并向其中写入数据，然后删除文件。

    require 'tempfile'
    f = Tempfile.new('tingtong')
    f.puts "Hello"
    puts f.path
    f.close