---
layout: page
title:
category: blog
description:
---
# Preface

# config
[/p/vim-exvim](/p/vim-exvim)
而exVim是一个以ide为目标精心定制的vim [exVim](http://exvim.github.io/)
默认gui版的exvim会使用一种字体美化，如果你的系统不支持该字体，可以在`.vimrc.plugins`中禁用, 或者从windows 中copy 一份字体：

	let g:airline_powerline_fonts = 0

http://vim.spf13.com/?nsukey=0UGUDAGrAn9112sWbGXpxQVeYuzug%2FDXYfJU8YmpQb9oKLX4ayYO9D3UtyIoSv5L95rvVrHwr6fzF9vKlfmWKQ%3D%3D#contributing
http://feihu.me/blog/2014/intro-to-vim/#vim

# project

	project_type = doc -- { all, build, clang, data, doc, game, server, shell, web, ... }

	-- File and folder filters:
	folder_filter_mode = exclude -- { include, exclude }
	folder_filter += img,doc

## project window

	nnoremap <unique> <silent> <F3> :EXProjectToggle<cr>
	:call EXProjectToNERDTree()
	n  <C-Tab>     *@:call nerdtree#ui_glue#invokeKeyMap("<C-Tab>")<CR>
	n  <C-Tab>     * :EXbalt<CR>

	\fc		定位到当前文件名

# ctags

	:Update
		ctags -o ./.exvim.lp/_tags --fields=+iaS --extra=+q -L ./.exvim.lp/files

tag jump

	<c-]> :ts tag-name
	<leader>] :TS tag-name

## Symbols

	Commands	Usage
	<leader>ss	List all symbols in the symbol window.
	<leader>sq	Open symbol window and show the last listed symbols.
	<leader>sg	Use current word under the cursor as search tag, list all tags match it in the symbol window.
	:SL <your-tag>	Use <your-tag> as search tag, list all tags match it in the symbol window.

### filter
filter

	/ ?

remove:

	Commands	Usage
	<leader>r	Remove the symbols listed in symbol window not contains the Vim's search pattern.
	<leader>d	Remove the symbols listed in symbol window contains the Vim's search pattern.

# Search
Search Text
ex-gsearch has two main ways for search text in your project.

	<leader>gg: It will search the current words under the cursor as text.
	:GS <word>: It will search the <word> you input as text in command line.
	:GS \<word\>: It will search the <word> you input in command line.

search results

	\gs :EXGSearchToggle
	gd	search word
	u or <c-r>

filter

	Commands	Usage
	<leader>r	Remove the search results in whiches content part not contains the Vim's search pattern.
	<leader>d	Remove the search results in whiches content part contains the Vim's search pattern.
	<leader>fr	Remove the search results in whiches file part not contains the Vim's search pattern.
	<leader>fd	Remove the search results in whiches file part contains the Vim's search pattern.

# taglist(function list)
ex-taglist.vim

	<F4> call Tlist_Window_Toggle()

# vim-airline

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
