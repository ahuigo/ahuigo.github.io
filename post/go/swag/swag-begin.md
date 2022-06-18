---
title: swagger begin
date: 2018-10-04
private: true
---
# swagger begin
This article will introduce swagger's source code.

# swag init
    go run cmd/swag/main.go init

## initAction
    func initAction(ctx *cli.Context) error {
        return gen.New().Build(&gen.Config{
            SearchDir:           ctx.String(searchDirFlag),
            ...
        })
    }

## ParseAPIMultiSearchDir

    ParseAPIMultiSearchDir
        getAllGoFileInfo->parseFile parse.go
            goparser.ParseFile
            parser.packages.CollectAstFile