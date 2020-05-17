---
title: ruby except
date: 2020-05-17
private: true
---
# ruby except
Ruby 提供了一个完美的处理异常的机制。我们可以在 begin/end 块中附上可能抛出异常的代码，并使用 rescue 子句告诉 Ruby 完美要处理的异常类型。

## except 语法

    begin #开始
        raise.. #抛出异常
    rescue [ExceptionType = StandardException] #捕获指定类型的异常默认值是 StandardException
        p $! #表示异常信息
        p $@ #表示异常出现的代码位置
    else #其余异常
        ..
    ensure #不管有没有异常，进入该代码块
        finnaly...
    end #结束

实例

    begin
        file = open("/unexistant_file")
        if file
            puts "File opened successfully"
        end
    rescue
        file = STDIN
    end
    print file, "==", STDIN, "\n"

## raise,rescue
4种语法

    raise 
    raise "Error Message" 
    raise ExceptionType, "Error Message"
    raise ExceptionType, "Error Message" condition
 
另一个演示 raise 用法的实例：

    begin  
        raise 'A test exception.'  
    rescue Exception => e  
        puts e.message  
            # 等价e==$!
        puts e.backtrace.inspect  
            # 等价$@
    end

## retry 语句
您可以使用 rescue 块捕获异常，然后使用 retry 语句从开头开始执行 begin 块。

    begin
        file = open("/unexistant_file")
        if file
            puts "File opened successfully"
        end
    rescue
        fname = "existant_file"
        retry
    end

## ensure 语句(finnaly)
    begin
      raise 'A test exception.'
    rescue Exception => e
      puts e.message
      puts e.backtrace.inspect
    ensure
      puts "Ensuring execution"
    end

## goto:Throw/Catch
    def promptAndGet(prompt)
        print prompt
        res = readline.chomp
        throw :quitRequested if res == "!"
        return res
    end
 
    catch :quitRequested do
        name = promptAndGet("Name: ")
        # ...
    end
    promptAndGet("Name:")

## Exception类 
Ruby 的标准类和模块抛出异常。所有的异常类组成一个层次，包括顶部的 Exception 类在内。下一层是七种不同的类型：

    Interrupt
    NoMemoryError
    SignalException
    ScriptError
    StandardError
    SystemExit
    Fatal 是该层中另一种异常，但是 Ruby 解释器只在内部使用它。


### 扩展类
    class FileSaveError < StandardError
        attr_reader :reason
        def initialize(reason)
            @reason = reason
        end
    end

下例中，最重要的一行是 `raise FileSaveError.new($!)`。向外传出异常

    File.open('a.txt', "r") do |file|
        begin
            file.write 1
        rescue
            # 发生错误
            raise FileSaveError.new($!)
        end
    end
