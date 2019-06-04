---
layout: page
title: vim-change
category: blog
description: 
date: 2018-10-04
---
# Preface

# search

## search plugin
- lookupfile 查找tag, word
http://blog.xeonxu.info/blog/2013/05/14/gao-liao-ge-ban-zi-dong-hua-de-vim/

# replace

## 基础的替换命令

	cw 替换一个单词
	C=c$
	cc 改变整行

	s=cl
	S=cc

	r 仅替换一个字符
	R

	~ 切换字符的大小写，并把光标移动到下一字符

## substitute s替换
>更多替换请参照:help sub-replace-special

基本格式如下：

	:[range]s/pattern/replace/[flags]
	:[range]s+pattern+replace+[flags]
	:[range]s?pattern?replace?[flags]

	:%s/\([^-]*\)-\(.*\)/\2 \1/gc   "vim中的替换也可以用到正则反引用\2\1

> 一般情况下\r\n分别代表回车与换行，但是在`:%s/pattern/replace` 中的replace，replace 只能用'\r'表示换行，'\n'表示回车
> 更多见[vim-pattern](/p/vim-pattern)

Example: 删除注释，先用V 选中，然后

    :s#^//##g 删除注释//

## 外部程序替换

	!{motion}{program} "program处理完了后，替换 motion
	:[range]!{program} "program处理完了后，替换 range

eg:

	!{motion}{program}
	{motion}作为program的输入，其输出会替换{motion}处的内容

	#比如我想让一到５行的内容经过sort,这个命令会从normal进入到命令行
	!5Gsort<enter>
	:.,5!sort<enter>

	!!{program} #此时motion为!代表当前行
	#统计当前行
	!!wc
	:.!wc

# Delete 删除

	:g/^\s*$/d

	:g!/^\s*$/d
	:v/^\s*$/d

# insert
## insert quotes

    ciw'Ctrl+r"'

Unquote a word that's enclosed in single quotes:

    di'hPl2x

Change single quotes to double quotes:

    va':s/\%V'/"/g

map:

    vnoremap " di"<esc>pa"<esc>
    vnoremap ' di'<esc>pa'<esc>
    vnoremap ( di(<esc>pa)<esc>
    vnoremap [ di[<esc>pa]<esc>
    vnoremap { di{<esc>pa}<esc>

vscode vim:

    vwS"

## plugin
- easy-grep 全局查找并替换
http://zuyunfei.com/2013/08/25/vim-plugin-easy-grep/#comments