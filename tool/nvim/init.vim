set backupdir=~/.data/backup
"info
set laststatus=2
"open
:au BufReadPost *
	 \ if line("'\"") > 1 && line("'\"") <= line("$") && &ft !~# 'commit' 
	 \ |   exe "normal! g`\""
	 \ | endif

"search
nnoremap <F1> :let @/ = ""<CR>
nnoremap  \w :%s/\s\+$//e<CR>

"close & write
nnoremap <C-q> :qa<CR>

" provide hjkl movements in Insert mode
inoremap <C-b>  <Left>
inoremap <C-f>  <Right>
inoremap ∂ <C-d>
inoremap <C-d> <DEL>
inoremap <C-a> <Home>
inoremap <C-e> <End>
inoremap <C-k>  <C-o>D
nnoremap <C-k>  D

" provide hjkl movements in ex mode
cnoremap <C-a> <Home>
cnoremap <C-b> <Left>
cnoremap ƒ <C-f>
cnoremap <C-f> <Right>
"nnoremap <D-a> a

" select
"nnoremap <space> vas
nnoremap - ddp
nnoremap _ ddkP


""""""""""""""""""""""
    "Quickly Run
""""""""""""""""""""""
map <F5> :call CompileRunGcc()<CR>
func! CompileRunGcc()
	exec "w"
if &filetype == 'c'
		exec "!g++ % -o %<"
		exec "!time ./%<"
elseif &filetype == 'cpp'
		exec "!g++ % -o %<"
		exec "!time ./%<"
elseif &filetype == 'java'
		exec "!javac %"
		exec "!time java %<"
elseif &filetype == 'sh'
		:!time bash %
elseif &filetype == 'python'
		exec "!time python3 %"
elseif &filetype == 'html'
		exec "!firefox % &"
elseif &filetype == 'go'
"        exec "!go build %<"
		exec "!time go run %"
elseif &filetype == 'mkd'
		exec "!~/.vim/markdown.pl % > %.html &"
		exec "!firefox %.html &"
endif
endfunc

" Search
"" search current word
map ft :call Search_Word()<CR>:copen<CR>
function Search_Word()
	let w = expand("<cword>")
	execute "vimgrep " . w . " *"
endfunction

" crontab with no backup
autocmd filetype crontab setlocal nobackup nowritebackup

" Blog
noremap <F9> :execute "0r _posts/test.md"<CR>

"vimdiff
noremap <Leader>1 :diffget 1<CR>
noremap <Leader>2 :diffget 2<CR>
noremap <Leader>3 :diffget 3<CR>

"file
function! Move(src, dst)
	exe '!mv' a:src a:dst
endfunction
"call Move(1,2)
com! -complete=file -nargs=* Move call Move(<f-args>)

"inoremap <D-V> <ESC>:r!pasteImg.py '%:t:r'<CR>
inoremap <D-V> <ESC>:r!pasteImg.py '%'<CR>
"clipboard
" config iTerm2 keys: Esc+Ac, Esc+As, Esc+Aa
vnoremap <M-A>c "+y
nnoremap <M-A>s :up<CR>
inoremap <M-A>s <C-o>:up<CR>
nnoremap <M-A>a ggVG
nnoremap \p "+p

function! Strip(input_string)
	return substitute(a:input_string, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction

function! Pipe2Shell(args)
  let pos = stridx(a:args, '|')
  let exCmd = strpart(a:args, 0, pos)
  let shellCmd = Strip(strpart(a:args, pos+1))
  redir => message
  silent execute exCmd
  redir END
  if empty(message)
	echoerr "no output"
  else
	new
	setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted nomodified
	silent put=message
	exec '%!' shellCmd
  endif
endfunction
command! -nargs=+ -complete=command Pipe2Shell call Pipe2Shell(<q-args>)

call plug#begin('~/.vim/plugged')
    Plug 'vim-scripts/AutoComplPop'
    " snippet: for<C-\>
    Plug 'drmingdrmer/xptemplate'
    " new async grammar check: better than sync 'syntastic' 
    Plug 'neomake/neomake'
    " 基于jedi 可以提示obj 属性: sys.path.
    Plug 'davidhalter/jedi-vim'
    " ctrlp
    Plug 'Shougo/denite.nvim'
		" ack
    Plug 'mileszs/ack.vim'
    Plug 'Chiel92/vim-autoformat'
call plug#end()

" When writing a buffer (no delay), and on normal mode changes (after 750ms)
" call neomake#configure#automake('nw', 500)
call neomake#configure#automake('w')

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
"exec "source ".fnameescape(expand('<sfile>:p:h').'/denite.vim')
exec "source ".expand('<sfile>:p:h').'/denite.vim'
nnoremap <C-p> :Denite buffer file/rec<CR>

""""""""""""""
" DEV
"""""""""""""
colorscheme desert
set mouse=a
set wrap
" xterm
set t_Co=8
set fileencoding=utf-8
set fileencodings=utf-8,gbk
set ts=4 sw=4 softtabstop=4 nu autoindent
set cuc cul
set ignorecase smartcase
set expandtab

" vim: set ts=2 sw=2 tw=80 noet :
