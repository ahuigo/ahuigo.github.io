---
layout: page
title:	vim-lib
category: blog
description: 
---
# Preface

# platform

## detect

	function! OSX()
		return has('macunix')
	endfunction
	function! LINUX()
		return has('unix') && !has('macunix') && !has('win32unix')
	endfunction
	has("win32")

# system

	"sleep 200ms
	:sleep 200m

	"sleep 2s
	:sleep 2

