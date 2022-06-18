---
title: golang 下的文件监听
date: 2020-07-09
---

# go file watch

Macosx监听文件变化的方式有几种：

1. 创建每个文件的fd(file descriptor)监听: 缺点fd 数是有限的
   1. 如https://github.com/fsnotify/fsnotify. 看了源码，它要递归所有文件的fd, 放到kequeue
      中监听（arun使用的fsnotify）
      1. fork自howeyc/fsnotify, 基于linux kernel 提供的inotify wrapper(纯golang)
2. 通过FSEvents 监听: less file descriptor usage
   1. rjeczalik/notify:
      https://www.reddit.com/r/golang/comments/6l87m2/watch_filesystem_for_changes/djrwip3/
      1. support FSEvents, but it needs cgo to do that because it needs to
         access the osx core libraries
      2. with less file descriptor usage
   1. https://github.com/naaive/orange/tree/release/src-tauri 此应用使用的就是
3. 通过监听文件属性: Name, ModTime, IsDir,etc. (Without using filesystem events)
   1. radovskyb/watcher:
      https://www.reddit.com/r/golang/comments/54q0c1/watcher_is_a_simple_go_package_for_watching_for/
      1. https://github.com/radovskyb/watcher

## inotify

> refer: https://www.cnblogs.com/sunsky303/p/8117864.html linux实时文件事件监听--inotify
> inotify 是linux kernel 提供的监控API, 可以同时监控目录及目录中的各子目录及文件的。 inotify
> 使用文件描述符作为接口，因而可以使用通常的文件I/O操作select、poll和epoll来监视文件系统的变化。

inotify 可以监视的文件系统常见事件包括：

    IN_ACCESS：文件被访问
    IN_MODIFY：文件被修改
    IN_ATTRIB，文件属性被修改
    IN_CLOSE_WRITE，以可写方式打开的文件被关闭
    IN_CLOSE_NOWRITE，以不可写方式打开的文件被关闭
    IN_OPEN，文件被打开
    IN_MOVED_FROM，文件被移出监控的目录
    IN_MOVED_TO，文件被移入监控着的目录
    IN_CREATE，在监控的目录中新建文件或子目录
    IN_DELETE，文件或目录被删除
    IN_DELETE_SELF，自删除，即一个可执行文件在执行时删除自己
    IN_MOVE_SELF，自移动，即一个可执行文件在执行时移动自己

通过/proc接口中的如下参数设定inotify能够使用的内存大小：

1. /proc/sys/fs/inotify/max_queue_events
   应用程序调用inotify时需要初始化inotify实例，并时会为其设定一个事件队列，此文件中的值则是用于设定此队列长度的上限；超出此上限的事件将会被丢弃；
2. /proc/sys/fs/inotify/max_user_instances
   此文件中的数值用于设定每个用户ID（以ID标识的用户）可以创建的inotify实例数目的上限；
3. /proc/sys/fs/inotify/max_user_watches 此文件中的数值用于设定每个用户ID可以监控的文件或目录数目上限；
