---
layout: page
title:	验证码识别工具tesseract
category: blog
description: 
---

# 序

首先说下我要用到的工具：tesseract/ImageMagick/...etc.

## tesseract是什么？ 
tesseract谷歌(原HP)开源的OCR（Optical Character Recognition，光学字符识别）识别引擎，引用google code [tesseract-ocr]的话——可能是开源界最精确的识别引擎:

>Tesseract is probably the most accurate open source OCR engine available. Combined with the Leptonica Image Processing Library it can read a wide variety of image formats and convert them to text in over 60 languages. It was one of the top 3 engines in the 1995 UNLV Accuracy test. Between 1995 and 2006 it had little work done on it, but since then it has been improved extensively by Google. It is released under the Apache License 2.0.

## ImageMagick是什么？

ImageMagick是一个用于查看、编辑位图文件以及进行图像格式转换的开放源代码软件套装
我在这里之所以提到ImageMagick是因为某些图片格式需要用这个工具来转换。

## Leptonica 是什么？

Leptonica 是一图像处理与图像分析工具，tesseract依赖于它。而且不是所有的格式(如jpg)都能处理，所以我们需要借助imagemagick做格式转换。[leptonica]格式受限为：

	Here's a summary of compression support and limitations:
		- All formats except JPEG support 1 bpp binary.
		- All formats support 8 bpp grayscale (GIF must have a colormap).
		- All formats except GIF support 24 bpp rgb color.
		- All formats except PNM support 8 bpp colormap. 
		- PNG and PNM support 2 and 4 bpp images.
		- PNG supports 2 and 4 bpp colormap, and 16 bpp without colormap.
		- PNG, JPEG, TIFF and GIF support image compression; PNM and BMP do not.
		- WEBP supports 24 bpp rgb color.

# 工具安装
如果你老老实实的去google code[tesseract-ocr]下载最新的tar.gz

	$tar xzvf tesseract-ocr-3.02.02.tar.gz  -C ~/Downloads/tesseract
	$cd ~/Downloads/tesseract-ocr
	$less README
	$./autogen.sh
	$./configure
	$make
	$make install
	$sudo ldconfig

可能，你会在autogen.sh卡壳（环境没有配置）。另外，你还有依赖关系要解决。
如果你的发行版有官方或者第三方维护的二进制包，干嘛自己编译呢？直接命令行安装（比如我的archlinux）:
	
	[hilo@hilo ]$ sudo pacman -S tesseract #leptonica、libpng 等依赖会自动解决滴
	[hilo@hilo ]$ sudo pacman -S tesseract-data-eng #英文的语言包还是必须要滴
	[hilo@hilo ]$ sudo pacman -S imagemagick #如果你还没有安装过imagemagick

# 识别验证码
## 一般应用
比如我有一张a.jpg的图片：
<a href="http://hilojack-wordpress.stor.sinaapp.com/uploads/2013/01/a.2.png"><img title="a.2.png" alt="a.2.png" src="http://hilojack-wordpress.stor.sinaapp.com/uploads/2013/01/a.2.png" class="aligncenter" /></a>

	[hilo@hilo ~]$ convert a.jpg  a.tif #先转为可识别的a.tif
	[hilo@hilo ]$ tesseract a.tif out
	[hilo@hilo ]$ cat out.txt #查看识别到的验证码
##　提高图片质量
	识别成功率跟图片质量关系密切，一般拿到后的验证码都得经过灰度化，二值化，去噪，利用imgick就可以很方便的做到．

	convert -monochrome foo.png bar.png　#将图片二值化

这是推荐读下鬼仔的[高级验证码识别]

## 我只想识别字符和数字？
ok, 没有问题，可以参考[faq],结尾仅需要加digits
	
	tesseract imagename outputbase digits

## 训练你的tesseract
不得不说，tesseract英文识别率已经很不错了(归功于现有的tesseract-data-eng）,但是数字验证码识别还是太鸡肋了, 要想更精确的识别， 还需要对tesseract 进行适当的训练．
	
	未完

# FAQ
这里罗列一下[faq]上没有提到的的问题：

## empty page!!
严格来说，这不是一个bug(tesseract 3.0),出现这个错误是因为tesseract搞不清图像的字符布局，如果你看过[tesseract wiki],你就应该知道如何解决：

	-psm N
		Set Tesseract to only run a subset of layout analysis and assume a certain form of image. The options for N are:

		0 = Orientation and script detection (OSD) only.
		1 = Automatic page segmentation with OSD.
		2 = Automatic page segmentation, but no OSD, or OCR.
		3 = Fully automatic page segmentation, but no OSD. (Default)
		4 = Assume a single column of text of variable sizes.
		5 = Assume a single uniform block of vertically aligned text.
		6 = Assume a single uniform block of text.
		7 = Treat the image as a single text line.
		8 = Treat the image as a single word.
		9 = Treat the image as a single word in a circle.
		10 = Treat the image as a single character.

对于我们的验证码a.tif排列来说，采用-psm 7(single text line)比较合适。
	
	$ tesseract 84.tif out -l eng  -psm 7 ;cat out.txt
	
# 参考
- [tesseract-ocr]
- [leptonica]
- [faq]
- [tesseract wiki]
- [高级验证码识别]

[tesseract-ocr]: http://code.google.com/p/tesseract-ocr/ "tesseract"
[leptonica]: http://www.leptonica.com/source/README.html "leptonica readme"
[faq]: http://code.google.com/p/tesseract-ocr/wiki/FAQ#How_do_I_recognize_only_digits "faq"
[tesseract wiki]: http://code.google.com/p/tesseract-ocr/wiki/ReadMe "readme"
[高级验证码识别]: http://huaidan.org/archives/2085.html "ocr-Recognition"
