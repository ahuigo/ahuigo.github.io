---
title: go汇编示例
date: 2019-01-23
---
# doc
发现一份汇编示例：
1. Go Assembly 示例 https://colobu.com/goasm/
2. 英文版：https://www.davidwong.fr/goasm/

# hello world
## 生成汇编
参考：https://golang.org/doc/asm

    $ go build -o x.exe x.go
    $ go tool objdump -s main.main x.exe
    TEXT main.main(SB) /tmp/x.go
    x.go:3		0x10501c0		65488b0c2530000000	MOVQ GS:0x30, CX
    x.go:3		0x10501c9		483b6110		CMPQ 0x10(CX), SP
    x.go:3		0x10501cd		7634			JBE 0x1050203
    ...
