""""""""""""""""""""""
" Plugin: plug
""""""""""""""""""""""
call plug#begin('~/.local/share/nvim/plugged')
    Plug 'vim-scripts/AutoComplPop'

    " snippet: for<C-\>
    "Plug 'drmingdrmer/xptemplate'
	
    " new async grammar check: better than sync 'syntastic' 
    Plug 'neomake/neomake'

    " 基于jedi 可以提示obj 属性: sys.path.
    Plug 'davidhalter/jedi-vim'

    " ctrlp
    "Plug 'Shougo/denite.nvim'

		" ack
    "Plug 'mileszs/ack.vim'

		"autoformat
		"let g:autoformat_verbosemode=1
    "Plug 'Chiel92/vim-autoformat'
call plug#end()

"" When writing a buffer (no delay), and on normal mode changes (after 750ms)
"" call neomake#configure#automake('nw', 500)
"call neomake#configure#automake('w')

""""""""""""""""""
" autoformat
"""""""""""""""
" autocmd FileType python set equalprg=Autopep8.sh
nnoremap = :Autoformat<CR>
vnoremap = :Autoformat<CR>


""""""""""""""
" ag
""""""""""""
let g:ackprg = 'ag --vimgrep'

""""""""""""
" denite.nvim
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
