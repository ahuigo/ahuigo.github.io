---
title: go init
date: 2020-04-21
private: true
---
# go init

    package main
    import (
        "log"
    )
    func init(){
        log.Println("init")
    }
    func f() int {
        return 1
    }
    var c = f()
    func main(){
        log.Println(c)
    }
