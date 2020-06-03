---
title: ruby proc
date: 2020-06-03
private: true
---
# ruby proc
 与function 相比 Both are blocks of code
1. methods are bound to Objects, 
2. and Procs are bound to the local variables in scope

e.g

    proc1 = Proc.new {|x| x**2 } #不检查参数, x默认nil
    proc1 = proc {|x| x**2 }
    proc1 = lambda {|x| x**2 } # 检查参数
    proc1 = ->(x) { x**2 }

run proc:

    proc1.call(3)  #=> 9
    # shorthands:
    proc1.(3)      #=> 9
    proc1[3]       #=> 9