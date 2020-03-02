---
title: ruby expr
date: 2020-03-02
private: true
---
# Ruby Block
写brew cask 包时遇到奇怪的语法`Cask "package-name" do ... end`，原来这就是ruby 的block 呀！

    def test(j)
        p j
        yield 5
        puts "在 test 方法内"
        yield 100
    end
    test 1 do |i| 
        puts "你在块 #{i} 内"
    end

`test 1`产生迭代器, `do |i|` 相当于python的`for i in test(1)`, output:

    1
    你在块 5 内
    在 test 方法内
    你在块 100 内
