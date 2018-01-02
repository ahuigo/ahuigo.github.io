---
layout: page
title:	pandoc with markdown
category: blog
description: 
---
# Preface
http://www.yangzhiping.com/tech/pandoc.html
http://github.com/ahui132/php-lib/app/pandoc

# Install

## pandoc

	brew install pandoc

## Standalone ConTeXt
> REfer: http://wiki.contextgarden.net/Mac_Installation#Using_the_Commandline

The "ConTeXt Suite" distribution is the recommended way to use ConTeXt on any OS. If you wish to use "ConTeXt Suite" from the command line you can use the Mac tutorial in the Mac section under ConTeXt Suite or

Using the Commandline

	mkdir $HOME/context
	rsync -av rsync://contextgarden.net/minimals/setup/first-setup.sh .
	sh ./first-setup.sh --modules=all --engine=luatex

# demo
1. 用context tex2pdf http://mszep.github.io/pandoc_resume/ 不支持中文
2. pandoc md2pdf http://www.phodal.com/blog/mac-os-install-pandoc-markdown-convert-pdf-doc/ 需要安装xeTex(可以支持utf-8)
3. 在线tex2pdf https://www.sharelatex.com 不支持中文

# html2pdf
slow but clean
http://document.online-convert.com/convert-to-pdf

fast:
http://pdfcrowd.com/
