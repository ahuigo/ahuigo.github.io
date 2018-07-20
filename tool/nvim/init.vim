"" DEV
colorscheme desert
set mouse=a
set wrap
" xterm
set t_Co=8
"encoding
set fileencoding=utf-8
set fileencodings=utf-8,gbk
set ts=4 sw=4 softtabstop=4 nu autoindent
set ignorecase smartcase
set expandtab
"info
set laststatus=2
"open
:au BufReadPost *
	 \ if line("'\"") > 1 && line("'\"") <= line("$") && &ft !~# 'commit' 
	 \ |   exe "normal! g`\""
	 \ | endif

"search
noremap <F3> :let @/ = ""<CR>

"close & write
nnoremap <C-q> :qa<CR>

" provide hjkl movements in Insert mode
inoremap <C-b>  <Left>
inoremap <C-f>  <Right>
inoremap ∂ <C-d>
inoremap <C-d> <DEL>
inoremap <C-a> <Home>
inoremap <C-e> <End>

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
call plug#end()

" When writing a buffer (no delay), and on normal mode changes (after 750ms)
" call neomake#configure#automake('nw', 500)
call neomake#configure#automake('w')

""""""""""""""
" ag
""""""""""""
let g:ackprg = 'ag --vimgrep'

""""""""""""
" denite.nvim
" -----------

" INTERFACE
call denite#custom#option('_', {
	\ 'prompt': 'λ:',
	\ 'empty': 0,
	\ 'winheight': 16,
	\ 'source_names': 'short',
	\ 'vertical_preview': 1,
	\ 'auto-accel': 1,
	\ 'mode' : 'insert',
	\ 'auto-resume': 1,
	\ })

call denite#custom#option('list', {})

call denite#custom#option('mpc', {
	\ 'quit': 0,
	\ 'mode': 'normal',
	\ 'winheight': 20,
	\ })

" MATCHERS
" Default is 'matcher_fuzzy'
call denite#custom#source('tag', 'matchers', ['matcher_substring'])
if has('nvim') && &runtimepath =~# '\/cpsm'
	call denite#custom#source(
		\ 'buffer,file_mru,file_old,file_rec,grep,mpc,line',
		\ 'matchers', ['matcher_cpsm', 'matcher_fuzzy'])
endif

" SORTERS
" Default is 'sorter_rank'
call denite#custom#source('z', 'sorters', ['sorter_z'])

" CONVERTERS
" Default is none
call denite#custom#source(
	\ 'buffer,file_mru,file_old',
	\ 'converters', ['converter_relative_word'])

" FIND and GREP COMMANDS
if executable('ag')
	" The Silver Searcher
	call denite#custom#var('file_rec', 'command',
		\ ['ag', '-U', '--hidden', '--follow', '--nocolor', '--nogroup', '-g', ''])

	" Setup ignore patterns in your .agignore file!
	" https://github.com/ggreer/the_silver_searcher/wiki/Advanced-Usage

	call denite#custom#var('grep', 'command', ['ag'])
	call denite#custom#var('grep', 'recursive_opts', [])
	call denite#custom#var('grep', 'pattern_opt', [])
	call denite#custom#var('grep', 'separator', ['--'])
	call denite#custom#var('grep', 'final_opts', [])
	call denite#custom#var('grep', 'default_opts',
		\ [ '--skip-vcs-ignores', '--vimgrep', '--smart-case', '--hidden' ])

elseif executable('ack')
	" Ack command
	call denite#custom#var('grep', 'command', ['ack'])
	call denite#custom#var('grep', 'recursive_opts', [])
	call denite#custom#var('grep', 'pattern_opt', ['--match'])
	call denite#custom#var('grep', 'separator', ['--'])
	call denite#custom#var('grep', 'final_opts', [])
	call denite#custom#var('grep', 'default_opts',
			\ ['--ackrc', $HOME.'/.config/ackrc', '-H',
			\ '--nopager', '--nocolor', '--nogroup', '--column'])
endif

" KEY MAPPINGS
let insert_mode_mappings = [
	\  ['jj', '<denite:enter_mode:normal>', 'noremap'],
	\  ['<Esc>', '<denite:enter_mode:normal>', 'noremap'],
	\  ['<C-N>', '<denite:assign_next_matched_text>', 'noremap'],
	\  ['<C-P>', '<denite:assign_previous_matched_text>', 'noremap'],
	\  ['<Up>', '<denite:assign_previous_text>', 'noremap'],
	\  ['<Down>', '<denite:assign_next_text>', 'noremap'],
	\  ['<C-Y>', '<denite:redraw>', 'noremap'],
	\ ]

let normal_mode_mappings = [
	\   ["'", '<denite:toggle_select_down>', 'noremap'],
	\   ['<C-n>', '<denite:jump_to_next_source>', 'noremap'],
	\   ['<C-p>', '<denite:jump_to_previous_source>', 'noremap'],
	\   ['gg', '<denite:move_to_first_line>', 'noremap'],
	\   ['st', '<denite:do_action:tabopen>', 'noremap'],
	\   ['sg', '<denite:do_action:vsplit>', 'noremap'],
	\   ['sv', '<denite:do_action:split>', 'noremap'],
	\   ['sc', '<denite:quit>', 'noremap'],
	\   ['r', '<denite:redraw>', 'noremap'],
	\ ]

for m in insert_mode_mappings
	call denite#custom#map('insert', m[0], m[1], m[2])
endfor
for m in normal_mode_mappings
	call denite#custom#map('normal', m[0], m[1], m[2])
endfor
nnoremap <C-p> :Denite buffer file/rec<CR>
exec "source ".expand('%:h').'/denite.vim'

" vim: set ts=2 sw=2 tw=80 noet :
