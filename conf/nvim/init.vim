set backupdir=~/.data/backup
"info
set laststatus=2
"open
:au BufReadPost *
	 \ if line("'\"") > 1 && line("'\"") <= line("$") && &ft !~# 'commit' 
	 \ |   exe "normal! g`\""
	 \ | endif

""""
" change like vscode: vwS'
"""""""""""""""
vnoremap " di"<esc>pa"<esc>
vnoremap ' di'<esc>pa'<esc>
vnoremap ( di(<esc>pa)<esc>
vnoremap [ di[<esc>pa]<esc>
vnoremap { di{<esc>pa}<esc>
""""""""""""""""""""""""""""


"search
nnoremap <F1> :let @/ = ""<CR>
nnoremap  \w :%s/\s\+$//e<CR>


nnoremap <leader>g :set operatorfunc=GrepOperator<cr>g@<cr>
vnoremap <leader>g :<c-u>call GrepOperator(visualmode())<cr>

function! GrepOperator(type)
	echom a:type
endfunction


"close & write
nnoremap <C-q> :qa<CR>

" provide hjkl movements when wrap
noremap <silent> k gk
noremap <silent> j gj
noremap <silent> 0 g0
"noremap <silent> $ g$

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

" window
noremap <c-h> :bp<cr>
noremap <c-l> :bn<cr>

" Blog
noremap <F9> :execute "0r _posts/test.md"<CR>

"vimdiff
noremap <Leader>1 :diffget 1<CR>
noremap <Leader>2 :diffget 2<CR>
noremap <Leader>3 :diffget 3<CR>
noremap <c-j> ]c
noremap <c-k> [c

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

call plug#begin('~/.local/share/nvim/plugged')
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

		"autoformat
		"let g:autoformat_verbosemode=1
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

""""""""""""
" python3
"""""""""""""
let g:python3_host_prog = '/usr/local/bin/python3'

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

"https://github.com/romainl/Apprentice/blob/master/colors/apprentice.vim
"autocmd ColorScheme *
hi DiffAdd      gui=none    guifg=NONE          guibg=#cccccc
hi DiffChange   gui=none    guifg=NONE          guibg=#e5d5ac
hi DiffDelete   gui=bold    guifg=#ff8080       guibg=#ffb0b0
hi DiffText     gui=none    guifg=NONE          guibg=#8cbee2
"autocmd ColorScheme * hi DiffText     gui=none    guifg=NONE          guibg=#cccccc
hi DiffAdd ctermbg=135  ctermfg=208  guibg=#262626 guifg=#87af87 cterm=reverse gui=reverse

""""""""""""""""""""""""""""""""""""""""""""""""
function! Strip(input_string)
    return substitute(a:input_string, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction

" :Pipe2Shell echo 1234 | wc -l
function! Pipe2Shell(args)
  let pos = stridx(a:args, '|')
  let exCmd = strpart(a:args, 0, pos)
  "let pattern = shellescape(Strip(strpart(a:args, pos+1)))
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

" vim: set ts=2 sw=2 tw=80 noet :
