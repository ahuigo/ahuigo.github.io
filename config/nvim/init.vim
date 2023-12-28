""""""""""""""""""""""
" Plugin: plug
""""""""""""""""""""""
call plug#begin('~/.local/share/nvim/plugged')
		" auto complete: coc better than YouCompleteMe
		"coc.vim:　基于 LSP 的插件，具备了代码补全，语法检查，标签跳转等功能。
		"YouCompleteMe: 整合了:clang_complete、AutoComplPop 、Supertab 、neocomplcache 、Syntastic(c/c++/obj-c代码)
		":h coc-config-suggest
		Plug 'neoclide/coc.nvim', {'branch': 'release'}
		"init:
		":CocInstall coc-json coc-tsserver
		"
		"config: https://github.com/neoclide/coc.nvim/wiki/Using-the-configuration-file
		"open config and write: {"suggest.noselect":true}
		":CocConfig

    " 基于jedi 可以提示obj 属性: sys.path.
		"Plug 'pappasam/coc-jedi', { 'do': 'yarn install --frozen-lockfile && yarn build', 'branch': 'main' }


    " snippet: for<C-\>
    "Plug 'drmingdrmer/xptemplate'
	
    " new async syntax lint
    Plug 'neomake/neomake'

		" ack 搜索
		" use :Ack [options] {pattern} [{directories}] // custom: let g:ackprg = 'ag --vimgrep'
		Plug 'mileszs/ack.vim'


    " ctrlp 目录
    "Plug 'Shougo/denite.nvim'
		Plug 'Shougo/ddu.vim'


		"autoformat
		"let g:autoformat_verbosemode=1
    "Plug 'Chiel92/vim-autoformat'
call plug#end()
""""""""""""""""""
" coc.nvim press <CR>  select first popup item
"inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
""""""""""""""""""

""""""""""""""""""
" autoformat
"""""""""""""""
" autocmd FileType python set equalprg=Autopep8.sh
nnoremap = :Autoformat<CR>
vnoremap = :Autoformat<CR>

""""""""""""""
" Ack use ag to search, install 
" :Ack [options] {pattern} [{directories}]
""""""""""""
let g:ackprg = 'ag --vimgrep'

""""""""""""
" denite.nvim ctrlp
" -----------
""exec "source ".fnameescape(expand('<sfile>:p:h').'/denite.vim')
"exec "source ".expand('<sfile>:p:h').'/denite.vim'
"nnoremap <C-p> :Denite buffer file/rec<CR>

""""""""""""
" python3
"""""""""""""
let g:python3_host_prog = '/usr/local/bin/python3'

exec "source ".expand('<sfile>:p:h').'/edit.vim'
set ts=4 sw=4 softtabstop=4 nu autoindent
" vim: set ts=2 sw=2 tw=80 noet :
