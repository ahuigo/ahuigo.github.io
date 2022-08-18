---
title: swagger begin
date: 2018-10-04
private: true
---
# swagger begin
This article will introduce swagger's source code.

本文语法：

    new Parser() // parser.go  --- this caller is defined in parser.go

# swag init
    go run cmd/swag/main.go init

## initAction
    initAction(ctx *cli.Context)
        return gen.New().Build(&gen.Config{ SearchDir ...  })
            1. p := swag.New(...)
            2. p.ParseAPIMultiSearchDir(searchDir) // parser.go

## ParseAPIMultiSearchDir

    (parser *Parser)ParseAPIMultiSearchDir()    //parser.go
        parser.getAllGoFileInfo
            parser.parseFile 
                astFile = goparser.ParseFile(filename, mode=ParseComments)
                parser.packages.CollectAstFile(astFile)
                    //(pkgDefs *PackagesDefinitions)CollectAstFile(astFile)
                    pkgDefs.packages[packageDir].Files[path] = astFile
                    pkgDefs.files[astFile] = &AstFileInfo{
                        File:        astFile,
                        Path:        path,
                        PackagePath: packageDir,
                    }
        if parser.ParseDependency :
            parser.getAllGoFileInfoFromDeps(&tree.Root.Deps[i])
                parser.parseFile(pkg.Name, path) 
        parser.ParseGeneralAPIInfo(absMainAPIFilePath="main.go")
            astFile = goparser.ParseFile("main.go", mode=ParseComments)
            parseGeneralAPIInfo(parser, astFile.comments)
                //comment like: @contact.name,@license.url,@host

        parser.parsedSchemas = parser.packages.ParseTypes()
            //pkgDefs.ParseTypes()
            for astFile, info := range pkgDefs.files:
                parsedSchemas += pkgDefs.parseTypesFromFile(astFile, info.PackagePath)
                    for astDeclaration := range astFile.Decls: 
                        //if generalDeclaration:= astDeclaration.(*ast.GenDecl);
                        for astSpec := range generalDeclaration.Specs:
                            // if typeSpec:= astSpec.(*ast.TypeSpec);
                            parsedSchemas[typeSpecDef] = &Schema{
                                PkgPath: typeSpecDef.PkgPath,
                                Name:    astFile.Name.Name,
                                Schema:  PrimitiveSchema(TransToValidSchemeType(idt.Name)),
                            }
                            pkgDefs.uniqueDefinitions[fullName] = typeSpecDef
                            //pkgDefs.uniqueDefinitions['server.User'] = typeSpecDef
                            pkgDefs.packages[typeSpecDef.PkgPath].TypeDefinitions[typeSpecDef.Name()] = typeSpecDef

        rangeFiles(parser.packages.files, parser.ParseRouterAPIInfo)
            for {path,File}=range files:
                parser.ParseRouterAPIInfo(path,File)
        parser.renameRefSchemas()
        return parser.checkOperationIDUniqueness()

## goparser.ParseFile
    // go/1.18/src/ligexec/go/parser
    goparser.ParseFile(filename,mode=ParseComments)
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
