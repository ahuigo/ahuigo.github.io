---
title: Ruby module
date: 2020-03-04
private: 
---
# Ruby module
模块（Module）定义了一个命名空间，相当于一个沙盒

    # 定义在 moral.rb 文件中的模块
    module Moral
        VERY_BAD = 0
        BAD = 1
        def Moral.sin(badness)
            # ...
        end
    end

# require
require 语句来加载模块文件：

    require 'filename'
    require 'filename.rb'

use moral 例子: 

    $LOAD_PATH << '.'

    require 'moral'
    wrongdoing = Moral.sin(Moral::VERY_BAD)

 `$LOAD_PATH << '.'` 让 Ruby 知道必须在当前目录中搜索被引用的文件

# include
include 用于为了在类中嵌入模块

     module Week
       FIRST_DAY = "Sunday"
       def Week.weeks_in_month
          puts "You have four weeks in a month"
       end
       def Week.weeks_in_year
          puts "You have 52 weeks in a year"
       end
    end

现在，您可以在类中引用该模块，如下所示：

    require "support"
    
    class Decade
    include Week
       no_of_yrs=10
       def no_of_months
          puts Week::FIRST_DAY
          number=10*12
          puts number
       end
    end
    d1=Decade.new
    puts Week::FIRST_DAY
    Week.weeks_in_month
    Week.weeks_in_year
    d1.no_of_months

# Mixins
ruby 不提供Mixins 多重继承, 但是include 替代了多重继承

    module A
       def a1
       end
    end
    module B
       def b1
       end
    end
    
    class Sample
    include A
    include B
       def s1
       end
    end
    
    samp=Sample.new
    samp.a1
    samp.b1
    samp.s1
