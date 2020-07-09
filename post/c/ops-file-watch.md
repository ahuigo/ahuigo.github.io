---
title: Whtch file
date: 2020-04-19
private: true
---
# Whtch file
除了watchdog 还有命令行工具
- inotify (linux)
- fswatch (osx)

# fswatch(osx)
help: 

    $ fswatch -h
    fswatch [OPTION] ... path ...
    -L, --follow-links    Follow symbolic links.
    -o, --one-per-batch   Print a single message with the number of change events.
    -r, --recursive       Recurse subdirectories.(default)
    -x, --event-flags     Print the event flags.
    -n, --numeric         Print the numeric value of the event flag

watch dir recursive

    brew install fswatch
    fswatch -r ~/path/to/watch | xargs -n1 -I{} nginx -s reload
        -I{} 表示不加参数
    fswatch -r ~/path/to/watch | xargs -n1 sh -c 'nginx -s reload'
        sh -c 会忽略多余参数

watch changed evnent name and files

    $ fswatch  -xr  . 
    a.txt Updated IsFile
    .git/index.lock Created Removed IsFile

杀进程：

    $ fswatch -r -o conf | xargs -n1 -I% sh -c 'echo event number%;kill $(cat ngx.pid);nginx -p `pwd`/ -c conf/lua.conf& echo $!>ngx.pid;'

reload + detect

    $ fswatch -r -o conf | xargs -n1 -I% sh -c 'echo event number%; sh nginx-reload.sh'
    $ cat nginx-reload.sh
    pid=$(cat ngx.pid); 
    if kill -HUP $pid; then 
        if ! { nginx -t -p $PWD -c nginx.conf && nginx -s reload -p $PWD -c nginx.conf; } then
            echo "wrong config!"
            kill $pid;
        fi
    else
        echo "start nginx"
        nginx -p $PWD -c nginx.conf & echo $! > ngx.pid;
    fi 


# inotify
## inotify 说明
inotify是Linux核心子系统之一，做为文件系统的附加功能，它可监控文件系统并将异动通知应用程序。本系统的出现取代了旧有Linux核心里，拥有类似功能之dnotify模块。

inotify的原始开发者为John McCutchan、罗伯特·拉姆与Amy Griffis。于Linux核心2.6.13发布时(2005年六月十八日)，被正式纳入Linux核心[1]。尽管如此，它仍可通过补丁的方式与2.6.12甚至更早期的Linux核心集成。

inotify的主要应用于桌面搜索软件，像：Beagle，得以针对有变动的文件重新索引，而不必没有效率地每隔几分钟就要扫描整个文件系统。相较于主动轮询文件系统，通过操作系统主动告知文件异动的方式，让Beagle等软件甚至可以在文件更动后一秒内更新索引。

此外，诸如：更新目录查看、重新加载设置文件、追踪变更、备份、同步甚至上传...等许多自动化作业流程，都可因而受惠。


## inotifywait
    inotifywait -e MODIFY -r -m /build |
    while read path action file; do
        ext=${file: -3}
        if [[ "$ext" == ".go" ]]; then
        echo File changed: $file
        go build main.go
        ./main
        fi
    done

其中：

    -r          recursive
    -e MODIFY  DELETE 等事件
    -m path     specify the path that we monitor 