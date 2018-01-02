---
layout: page
title:
category: blog
description:
---
# Preface


# Presentation, 演示(demonstrate)

## Markdown to Presentation(slide)

### marp
https://github.com/yhatt/marp
阮一峰推荐的

### Remark
在线的，比较简单
http://remarkjs.com/#1

### reveal.js
slides 使用的是reveal.js 非常漂亮

#### Installation

	npm install -g reveal-md

Quick demo

	reveal-md demo

Markdown in reveal.js

	# Title

	* Point 1
	* Point 2

	---

	## Second slide

	> Best quote ever.

#### use

To open specific Markdown file as Reveal.js slideshow:

	reveal-md slides.md

You can also provide a url that resolves to a Markdown resource (over http(s)).

	reveal-md https://raw.github.com/webpro/reveal-md/master/demo/a.md

Show (recursive) directory listing of Markdown files:

	reveal-md dir/

Show directory listing of Markdown files in current directory:

	reveal-md

Override theme (default: black):

	reveal-md slides.md --theme solarized

Override reveal theme with a custom one:

	# you'll need a theme/my-custom.css file
	reveal-md slides.md --theme my-custom

Override highlight theme (default: zenburn):

	reveal-md slides.md --highlightTheme github

Override slide separator (default: `\n---\n`):

	reveal-md slides.md --separator "^\n\n\n"

Override `vertical/nested` slide separator (default: `\n----\n`):

	reveal-md slides.md --verticalSeparator "^\n\n"

Override port (default: 1948):

	reveal-md slides.md --port 8888

Disable to automatically open your web browser:

	reveal-md slides.md --disableAutoOpen

#### Print Support
Requires phantomjs to be installed (preferably globally)

This will try to create a pdf with the passed in file (eg slides.md) and outputted to the name passed into the --print parameter (eg slides.pdf)

	reveal-md slides.md --print slides.pdf

### swipe
有点复杂,在线的

https://www.swipe.to/markdown/

### pandoc
阳志平的：[http://www.yangzhiping.com/tech/pandoc.html](http://www.yangzhiping.com/tech/pandoc.html)
参考：[http://blog.2baxb.me/archives/997](http://blog.2baxb.me/archives/997)

pandoc 规范： http://pandoc.herokuapp.com/

## beamer
Latex to Presentation, 注重排版，但不太漂亮, 适合评审

参考: [beamer theme](http://deic.uab.es/~iblanes/beamer_gallery/index_by_theme.html)
