---
title: go init
date: 2020-04-21
private: true
---
# go init

## init()

    package main
    import (
        "log"
    )
    func init(){
        log.Println("2. init")
    }
    func f() int {
        log.Println("1. assign")
        return 1
    }
    var c = f()
    func main(){
        log.Println("3. main")
    }

注意不能写if 等 non-declaration statement outside function body