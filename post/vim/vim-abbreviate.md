---
layout: page
title:	
category: blog
description: 
---
# Preface

# abbreviate

与map 相比:

1. They are used in Insert mode, Replace mode and Command-line mode.
2. They only abbreviate `keyword`.

	:abbreviate :ab 
	:iabbrev	:ia
	:rabbrev	:na
	:inoreabbre	:inorea

Exmaple, 自动修正单词`adn`, 单词定义`:set iskeyword?`

	:iabbrev adn and
	:iabbrev <buffer> adn and
	:iunabbrev adn

filename's keyword:

	:h 'isfname'
