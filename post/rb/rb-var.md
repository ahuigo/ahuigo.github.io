---
title: Ruby var
date: 2020-03-03
private: 
---
# Ruby var 类型
Ruby支持的数据类型包括基本的Number、String、Ranges、Symbols，以及true、false和nil这几个特殊值，
同时还有两种重要的数据结构——Array和Hash

## 类型转化

    Number('100') error
    String(100)     ok

## 类型检测
通用meta 信息

    "".match(//).class
    Time.new.class
    var.class

`is_a?`与`instance_of?`只能检测特定类型

    def type?(var)
        p var
        if var.is_a? String then
            return String
        elsif var.instance_of? Integer then
            return Integer
        elsif var.instance_of? MatchData then
            return MatchData
        elsif var.is_a? Time then
            return Time
        end
    end

## 变量生命
    一般小写字母、下划线开头：局部变量（Variable）。
    $开头：全局变量（Global variable）。
    @开头：实例变量（Instance variable）。
    @@开头：类变量（Class variable）类变量被共享在整个继承链中
    大写字母开头：常数（Constant）

## Ruby 伪变量

    self: 当前方法的接收器对象: self 可访问静态与动态方法
    true: 代表 true 的值。
    false: 代表 false 的值。
    nil: 代表 undefined 的值。
    __FILE__: 当前源文件的名称。
    __LINE__: 当前行在源文件中的编号。

## env 系统变量
    DLN_LIBRARY_PATH	动态加载模块搜索的路径。
    HOME	当没有参数传递给 Dir::chdir 时，要移动到的目录。也用于 File::expand_path 来扩展 "~"。
    LOGDIR	当没有参数传递给 Dir::chdir 且未设置环境变量 HOME 时，要移动到的目录。

    PATH	
        执行子进程的搜索路径，以及在指定 -S 选项后，Ruby 程序的搜索路径。每个路径用冒号分隔（在 DOS 和 Windows 中用分号分隔）。
    RUBYPATH	
        指定 -S 选项后，Ruby 程序的搜索路径。优先级高于 PATH。在 taint 模式时被忽略（其中，$SAFE 大于 0）。

    RUBYLIB	
        库的搜索路径。每个路径用冒号分隔（在 DOS 和 Windows 中用分号分隔）。
    RUBYLIB_PREFIX	
        用于修改 RUBYLIB 搜索目录，通过使用格式 path1;path2 或 path1path2，把库的前缀 path1 替换为 path2。

    RUBYOPT	传给 Ruby 解释器的命令行选项。在 taint 模式时被忽略（其中，$SAFE 大于 0）。
    RUBYSHELL	指定执行命令时所使用的 shell。如果未设置该环境变量，则使用 SHELL 或 COMSPEC

### read/write env
HOME:

    print "#{ENV['HOME']}"
    print Dir.home

ENV 可以被改变

    system("echo $PATH")
    ENV['PATH'] = '/nothing/here'
    system("echo $PATH")

ngx+lua+redis 架构模式在高并发的情况下完胜 ngx+php-fpm+php

# 变量运算符
    .eql?	相同的类型和相等的值，则返回 true。	
        1 == 1.0 返回 true，但是 1.eql?(1.0) 返回 false。
    equal?	相同的对象 id，则返回 true。	
        如果 aObj 是 bObj 的副本，那么 aObj == bObj 返回 true，a.equal?bObj 返回 false，但是 a.equal?aObj 返回 true

## 初值
如果没有初值就不赋值：

    a ||= '100'
    a ||= '100' if true