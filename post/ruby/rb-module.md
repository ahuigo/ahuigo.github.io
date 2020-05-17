---
title: Ruby module
date: 2020-03-04
private: 
---
# Ruby module
模块（Module）定义了一个命名空间，相当于一个沙盒. 模块名与类常量命名类似，以大写字母开头

    # 定义在 moral.rb 文件中的模块
    module Moral
        VERY_BAD = 0
        BAD = 1
        def Moral.sin(badness)
            # ...
        end
    end

# 加载
## require 文件
require 语句来加载模块文件：

    require 'filename'
    require 'filename.rb'

use moral 例子: 

    $LOAD_PATH << '.'

    require 'moral'
    wrongdoing = Moral.sin(Moral::VERY_BAD)

### require 加载路径
require 模块搜索的目录是是

    `$LOAD_PATH << '.'` 在当前目录中搜索

还可以使用 `require_relative` 来从一个相对目录引用文件。
 
还有以下两个环境变量，有文档说会用到，实际的发现是空的`p ENV['RUBYLIB']`

    RUBYLIB	
        库的搜索路径。每个路径用冒号分隔（在 DOS 和 Windows 中用分号分隔）。
    RUBYLIB_PREFIX	
        用于修改 RUBYLIB 搜索目录，通过使用格式 path1;path2 或 path1path2，把库的前缀 path1 替换为 path2。
    DLN_LIBRARY_PATH	
        动态加载模块搜索的路径。

## include
> 先require 模块文件(含一个或多个模块)，再include 内嵌指定模块
include 用于为了在类中内嵌入模块

    # support.rb
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

    # main.rb
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
