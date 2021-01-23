---
title: shell tool file
date: 2021-01-12
private: true
---
# file 相关工具
格式转换相关：

- 如果你必须处理 XML，xmlstarlet 虽然有点老旧，但是很好用。
- 对于 JSON，使用jq。
- 对于 Excel 或 CSV 文件，csvkit 提供了 in2csv，csvcut，csvjoin，csvgrep 等工具。
- 对于亚马逊 S3 ，s3cmd 会很方便，而 s4cmd 则更快速。亚马逊的 aws 则是其它 AWS 相关任务的必备。

## zip

	zip -e test [file ...]
		-e encrypt prompt to input password
	zip -e -P <password> test [file ...]
	unzip -x test.zip -d dir

## bzip2
    bunzip2 a.txt
    bunzip2 -d a.txt.bz2

tar.bzip2

    tar -xf archive.tar.bz2

## unrar
    rar x archive.rar path/to/extract/to 
## tar
    tar xzvf a.tar -C dir

## stat
stat：文件信息

## diff 工具

### diff
对源代码打补丁的标准工具是 diff 和 patch。
用 diffstat 来统计 diff 情况。

> 注意 diff -r 可以用于整个目录，所以可以用 diff -r tree1 tree2 | diffstat 来统计（两个目录的）差异。

## icdiff 对比文件改动
icdiff支持非交互式、左右对比、高亮。 Ps: git 内置了icdiff

	$ git icdiff

## od
od -- octal, decimal, hex, ASCII dump

	od -t xCc a.txt #16进制显示
	od -t oCc a.txt #8进制显示
		x hex
			x4 4bytes long
			x1 1bytes long
			xC  1bytes long
		o octal

		c list character iterate

## strings
用于过滤二进制文件中的不可见字符，strings（加上 grep 等）可以让你找出一点文本。

## zless
使用 zless，zmore，zcat 和 zgrep 来操作压缩文件

## hd
对于二进制文件，使用 hd 进行简单十六进制转储，以及 bvi 用于二进制编辑。