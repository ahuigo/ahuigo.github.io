---
title: Ruby module
date: 2020-03-04
private: 
---
# tool
下面是rb 的包工具

## RVM
用于帮你安装Ruby环境，帮你管理多个Ruby环境，帮你管理你开发的每个Ruby应用使用机器上哪个Ruby环境。
Ruby 环境不仅仅是Ruby本身，还包括依赖的第三方Ruby插件。都由RVM管理。


## Rake
Rake是一门构建语言，和make类型。Rake是用Ruby写的，它支持自己的DSL用来处理和维护Ruby
程序。Rails用rake扩展来完成多种不同任务，如数据库初始化、更新等。

## RubyGems
RubyGems 是一个方便而强大的Ruby程序包管理器（package
manager），类似Redhat的RPM。它讲一个Ruby应用程序打包到一个gem
里，作为一个安装单元。无需安装，最新的Ruby版本已经包含RubyGems了。

### gem命令
在终端使用的gem命令，是指通过RubyGems管理Gem包。

### Bundle
相等于多个RubyGems批处理运行。在配置文件gemfile里说明你的应用依赖哪些第三方包，他自动帮你
下载安装多个包，并且会下载这些包依赖的包。

    bundle install

### Gemfile
定义你的应用依赖哪些第三方包，bundle根据该配置去寻找这些包。

    gem "libxml-ruby"
    gem "libxml-ruby", ">= 2.0.5"
    gem "libxml-ruby", ">= 2.0.5", :require => "libxml" # 依赖


## Rack
以Ruby为语言编写的轻量级的http server服务。 

    # my_rack_app.rb
    require 'rack'

    app = Proc.new do |env|
        ['200', {'Content-Type' => 'text/html'}, ['A barebones rack app.']]
    end

    Rack::Handler::WEBrick.run app

    > ruby my_rack_app.rb
    [2015-12-14 23:27:19] INFO  WEBrick 1.3.1
    [2015-12-14 23:27:19] INFO  ruby 2.2.2 (2015-04-13) [x86_64-darwin14]
    [2015-12-14 23:27:19] INFO  WEBrick::HTTPServer#start: pid=84264 port=8080
    localhost - - [14/Dec/2015:23:27:43 CST] "GET / HTTP/1.1" 200 21


## 本节参考
AQ王浩 链接：https://www.jianshu.com/p/4587f91c7dbe

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
    puts $LOAD_PATH

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
    p $LOAD_PATH #全局变量
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
    $LOAD_PATH << '.'
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

## 命名规范
 gem a，里面有 module A，并且所有内容都在 A 的命名空间下。gem b 应该有 module B，并且把所有内容放在 module B。gem 的名字和命名空间是对应的，但这只是规范约束没有强约束。

 ## 第三方gem
Gemfile.lock

     hashie (3.5.6)

然后可直接bundle exec 会读取gem 后, 直接使用, 不用include

    # require "hashie" # if not gem
    hsh = Hashie::Mash.new("latitude"=>"40.695")
    hsh = Hashie::Mash.new(latitude:40.695)
    hsh.latitude
    => "40.695"

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
