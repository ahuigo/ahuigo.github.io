---
title: go pkg cli
date: 2020-04-20
private: true
---
# go pkg cli
1. 只需要在module 根目录下写: package main + main() 
2. 在build 时生成file 同名的bin
2. 在go install/get  时生成go.mod中module 同名的bin 并放到公共的path


## my cli demo
https://github.com/ahuigo/go-cli-demo.git

注意： go.mod 需要限制module 名为：

    module github.com/ahuigo/go-cli-demo
