---
title: Ruby var
date: 2020-03-03
private: 
---
# Ruby var
## Ruby 伪变量

    self: 当前方法的接收器对象。
    true: 代表 true 的值。
    false: 代表 false 的值。
    nil: 代表 undefined 的值。
    __FILE__: 当前源文件的名称。
    __LINE__: 当前行在源文件中的编号。

## env
### 系统变量
    DLN_LIBRARY_PATH	动态加载模块搜索的路径。
    HOME	当没有参数传递给 Dir::chdir 时，要移动到的目录。也用于 File::expand_path 来扩展 "~"。
    LOGDIR	当没有参数传递给 Dir::chdir 且未设置环境变量 HOME 时，要移动到的目录。
    PATH	执行子进程的搜索路径，以及在指定 -S 选项后，Ruby 程序的搜索路径。每个路径用冒号分隔（在 DOS 和 Windows 中用分号分隔）。
    RUBYLIB	库的搜索路径。每个路径用冒号分隔（在 DOS 和 Windows 中用分号分隔）。
    RUBYLIB_PREFIX	用于修改 RUBYLIB 搜索路径，通过使用格式 path1;path2 或 path1path2，把库的前缀 path1 替换为 path2。
    RUBYOPT	传给 Ruby 解释器的命令行选项。在 taint 模式时被忽略（其中，$SAFE 大于 0）。
    RUBYPATH	指定 -S 选项后，Ruby 程序的搜索路径。优先级高于 PATH。在 taint 模式时被忽略（其中，$SAFE 大于 0）。
    RUBYSHELL	指定执行命令时所使用的 shell。如果未设置该环境变量，则使用 SHELL 或 COMSPEC

### read/write env
HOME:

    print "#{ENV['HOME']}"
    print Dir.home

ENV 可以被改变

    system("echo $PATH")
    ENV['PATH'] = '/nothing/here'
    system("echo $PATH")