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


    goparser.ParseFile
        paser.parseGenDecl
            paser.parseImportSpec
                paser.next
                    paser.next0
                        p.scanner.Scan (scanner) // nextToken: comment/string/()/{}/struct/,/
                            s.scanString
                                s.next() //next unicode char
                        parse token.COMMENT

scanner:

    scan后:
        s.offset = s.rdOffset 当前字符开始
        s.ch = r 当前字符
        s.rdOffset += w 下一个字符起始
