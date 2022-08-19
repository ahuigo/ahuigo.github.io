---
title: git refs
date: 2022-08-19
private: true
---
# git refs

## ref 到 sha 的映射
refs 目录
    
    ls .git/refs/
        heads/dev       // local
        remotes/dev     //remote snapshot
        stash

ref 中存放的sha:

    $ cat .git/refs/heads/dev
    c5e017a57b4a88639418

##  sha到ref 的映射(只含remotes)
remote/sha 相当于指针，sha1 到ref-name 的映射是打包到

    $ head .git/packed-refs
    d15e054039bcb65 refs/remotes/origin/dev
    0c5fd1fcd67f1b0 refs/remotes/origin/master

# sha对应object的不存在
    error: cannot lock ref 'refs/remotes/origin/mj/dev': 
        'refs/remotes/origin/mj' exists; 
        cannot create 'refs/remotes/origin/mj/dev'

两种原因：
1. 分支名冲突, 删除分支就行：git branch -D mj
2. 还有一种情况是，ref(refs/remotes/mj)引用的object 不存在：需要执行 git remote prune origin 清理没有被引用的objects