---
layout: page
title:	markdown & ma
category: blog
description:
---
# Preface

# markdownjs
- https://github.com/showdownjs/showdown

# pdf2html
http://coolwanglu.github.io/pdf2htmlEX/
	brew install pdf2htmlEX
http://wkhtmltopdf.org/

# Escape
Refer to:
http://meta.stackexchange.com/questions/82718/how-do-i-escape-a-backtick-in-markdown

    ``List`1``

when inline it will display List

	`1

Markdown provides backslash escapes for the following characters:

    \   backslash
    `   backtick
    *   asterisk
    _   underscore
    {}  curly braces
    []  square brackets
    ()  parentheses

##   hash mark

    +   plus sign
    -   minus sign (hyphen)
    .   dot
    !   exclamation mark

for example, this:

    ## \\ \` \* \_ \{ \} \[ \] \( \) \# \+ \- \. \!

returns:

    \ ` * _ { } [ ] ( ) # + - . !

Escaped codeblock, italics, bold, link, headings and list:

`not codeblock`, *not italics*, **not bold**, [not link](http://www.google.com)

    # not h1

    ## not h2

    ### not h3

    + not ul
    - not ul
