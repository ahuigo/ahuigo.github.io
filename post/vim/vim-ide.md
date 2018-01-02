---
layout: page
title:	
category: blog
description: 
---
# Preface

# Todo
vim-ide: https://github.com/humiaozuzu/dot-vimrc

# macvim 
macVim是在mac下编译(编译时增加了+python3, clipboard)并定制好的gvim[macvim.app]

>This will create vim, vimdiff, etc. symlinks to mvim in /usr/local/bin/vim, and as long as /usr/local/bin is before /usr/bin in your PATH, you'll get the results you're looking for.

安装方法：

	brew install macvim --override-system-vim 

## help

	:h mac-*

# neovim

# wiki gollum
http://www.jianshu.com/p/9c35812b9bae

# ExVim
[/p/vim-exvim](/p/vim-exvim)
而exVim是一个以ide为目标精心定制的vim [exVim](http://exvim.github.io/)
默认gui版的exvim会使用一种字体美化，如果你的系统不支持该字体，可以在`.vimrc.plugins`中禁用, 或者从windows 中copy 一份字体：

	let g:airline_powerline_fonts = 0

http://vim.spf13.com/?nsukey=0UGUDAGrAn9112sWbGXpxQVeYuzug%2FDXYfJU8YmpQb9oKLX4ayYO9D3UtyIoSv5L95rvVrHwr6fzF9vKlfmWKQ%3D%3D#contributing
http://feihu.me/blog/2014/intro-to-vim/#vim

> 有一个bug: 在`:set ic`时, `/keepurlP` 搜索不了 'keepUrlParams'

## vim-airline

	" vim-airline
	" ---------------------------------------------------
	Plugin 'bling/vim-airline'

	if has('gui_running')
		let g:airline_powerline_fonts = 0
	else
		let g:airline_powerline_fonts = 0
	endif

	let g:airline#extensions#tabline#enabled = 1
	let g:airline#extensions#tabline#show_buffers = 1
	let g:airline#extensions#tabline#buffer_nr_show = 1
	let g:airline#extensions#tabline#fnamemod = ':t'
	" let g:airline_section_b = "%{fnamemodify(bufname('%'),':p:.:h').'/'}"
	" let g:airline_section_c = '%t'
	let g:airline_section_warning = airline#section#create(['syntastic'])
