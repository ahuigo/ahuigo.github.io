---
title: go pkg cli
date: 2020-04-20
private: true
---
# go pkg cli
1. 只需要在module 目录下写: package main + main() 
2. 在go install/get  时, bin名字：
   1. 根目录下，生成go.mod中module 同名的bin 并放到公共的path
   2. cmd/bin1/main.go 则生成的名字是 bin1 (文件夹名)

# go install
go install 时需要指定完成的package path

    # 0级
    go install github.com/ahuigo/arun@latest
    # 二级:cmd/swag/main.go
    go install github.com/swaggo/swag/cmd/swag@v1.8.1
