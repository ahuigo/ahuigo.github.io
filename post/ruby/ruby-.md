---
title: Ruby
date: 2019-02-17
private:
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

# hash
string key

    grades = { "Jane Doe" => 10, "Jim Doe" => 6 }

symbol key

    options = { font_size: 10, font_family: "Arial" }
    options = { :font_size => 10, :font_family => "Arial" }
    options[:font_size]

symbol value:

    options = {:key=>:value}
    options[:key]==:value

