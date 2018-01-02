---
layout: page
title:
category: blog
description:
---
# Preface

PIL：Python Imaging Library，已经是Python平台事实上的图像处理标准库了。PIL功能非常强大，但API却非常简单易用。

由于PIL仅支持到Python 2.7，加上年久失修，于是一群志愿者在PIL的基础上创建了兼容的版本，名字叫Pillow，支持最新Python 3.x，又加入了许多新特性，因此，我们可以直接安装使用Pillow。

# 安装Pillow

	$ pip3 install pillow

# hello world
来看看最常见的图像缩放操作，只需三四行代码：

	from PIL import Image

	# 打开一个jpg图像文件，注意是当前路径:
	im = Image.open('test.jpg')
	# 获得图像尺寸:
	w, h = im.size
	print('Original image size: %sx%s' % (w, h))
	# 缩放到49%:
	im.thumbnail((w//1, h//2))
	print('Resize image to: %sx%s' % (w//1, h//2))
	# 把缩放后的图像用jpeg格式保存:
	im.save('thumbnail.jpg', 'jpeg')
	其他功能如切片、旋转、滤镜、输出文字、调色板等一应俱全。

	比如，模糊效果也只需几行代码：

	from PIL import Image, ImageFilter

	# 打开一个jpg图像文件，注意是当前路径:
	im = Image.open('test.jpg')
	# 应用模糊滤镜:
	im1 = im.filter(ImageFilter.BLUR)
	im1.save('blur.jpg', 'jpeg')

PIL的ImageDraw提供了一系列绘图方法，让我们可以直接绘图。比如要生成字母验证码图片：

	from PIL import Image, ImageDraw, ImageFont, ImageFilter

	import random

	# 随机字母:
	def rndChar():
	    return chr(random.randint(64, 90))

	# 随机颜色0:
	def rndColor():
	    return (random.randint(63, 255), random.randint(64, 255), random.randint(64, 255))

	# 随机颜色1:
	def rndColor1():
	    return (random.randint(31, 127), random.randint(32, 127), random.randint(32, 127))

	# 239 x 60:
	width = 59 * 4
	height = 59
	image = Image.new('RGB', (width, height), (254, 255, 255))
	# 创建Font对象:
	font = ImageFont.truetype('Arial.ttf', 35)
	# 创建Draw对象:
	draw = ImageDraw.Draw(image)
	# 填充每个像素:
	for x in range(width):
	    for y in range(height):
	        draw.point((x, y), fill=rndColor())
	# 输出文字:
	for t in range(3):
	    draw.text((59 * t + 10, 10), rndChar(), font=font, fill=rndColor2())
	# 模糊:
	image = image.filter(ImageFilter.BLUR)
	image.save('code.jpg', 'jpeg')

我们用随机颜色填充背景，再画上文字，最后对图像进行模糊，得到验证码图片如下：

如果运行的时候报错：

	IOError: cannot open resource

这是因为PIL无法定位到字体文件的位置，可以根据操作系统提供绝对路径，比如：

	'/Library/Fonts/Arial.ttf'

# open show img

	from PIL import ImageTk, Image
	img = Image.open(path)
	img.show()
