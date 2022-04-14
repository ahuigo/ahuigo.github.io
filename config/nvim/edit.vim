"echom "my edit.vim"
""""""""""""""""""""""""""""""""""""""""""""
" run any file
" source tts.vim|cmd2
" """"""""""""""""""""""""""""""""""
function! edit#run()
	exec "up"
    let ext = expand('%:e')
    if ext == 'py'
        !python3 %
    elseif ext == 'js'
        !node %
    elseif ext == 'ts'
        !deno run %
    elseif ext == 'go'
        let filepath = expand('%')
        if filepath =~ '_test.go$'
            "exe '!go test -v' . filepath
            !go test -v %
            "term go test -v %
        else
            !go run %
            "term go run %
        endif
    elseif ext == 'vim'
        echom "save ".expand("%")
        "echom "source %"
    else
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
                exec "!open %"
        elseif &filetype == 'mkd'
                exec "!~/.vim/markdown.pl % > %.html &"
                exec "!firefox %.html &"
        endif
    endif
  ":py3 EditRun()
endfunction 

""""""""""""""""""""""
" F1...F12 
""""""""""""""""""""""
" search
nnoremap <F1> :let @/ = ""<CR>
nnoremap  \w :%s/\s\+$//e<CR>
nnoremap <F2> "+p
inoremap <F2> <C-o>"+p
nnoremap <F3> :w<CR>:call edit#run()<CR>

""""""""""""""""""""""""""
""" meta config
""""""""""""""""""""""""""""""
set backupdir=~/.data/backup
"info
set laststatus=2
"open
:au BufReadPost *
	 \ if line("'\"") > 1 && line("'\"") <= line("$") && &ft !~# 'commit' 
	 \ |   exe "normal! g`\""
	 \ | endif

colorscheme industry
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

"""""""""""""""""""""""""""""""""""
" Same as vscode's function: vwS'
"""""""""""""""""""""""""""""""""""
"vnoremap " di"<esc>pa"<esc>
"vnoremap ' di'<esc>pa'<esc>
vnoremap ( di(<esc>pa)<esc>
vnoremap [ di[<esc>pa]<esc>
vnoremap { di{<esc>pa}<esc>


"""""""""""""""""""""""""""""""""""
" provide hjkl movements when wrap
"""""""""""""""""""""""""""""""""""
noremap <silent> k gk
noremap <silent> j gj
noremap <silent> 0 g0
"noremap <silent> $ g$

"""""""""""""""""""""""""""""""""""""""""
" provide hjkl movements in Insert mode
" provide hjkl movements in ex mode
"""""""""""""""""""""""""""""""""""
noremap! <C-a> <Home>
inoremap <C-e> <End>
inoremap <A-BS> <C-\><C-o>db
noremap! <C-f>  <Right>
"cnoremap <A-f> <C-f>
cnoremap ƒ <C-f>
noremap! <C-b>  <Left>
inoremap <C-d> <DEL>
inoremap <C-k>  <C-o>D
nnoremap <C-k>  D
"nnoremap <D-a> a

"""""""""""""""""""""""""""""""""""
" select
"nnoremap <space> vas
"""""""""""""""""""""""""""""""""""
nnoremap - ddp
nnoremap _ ddkP


""""""""""""""""""""""
" Search current word
""""""""""""""""""""""
"map ft :call Search_Word()<CR>:copen<CR>
function Search_Word()
	let w = expand("<cword>")
	execute "vimgrep " . w . " *"
endfunction

""""""""""""""""""""""
" File management
""""""""""""""""""""""
" crontab with no backup
autocmd filetype crontab setlocal nobackup nowritebackup
" window
nnoremap <S-C-H> <C-W>h
nnoremap <S-C-L> <C-W>l
noremap <c-h> :bp<cr>
noremap <c-l> :bn<cr>
nnoremap <C-J> <C-W>j
nnoremap <C-K> <C-W>k
"noremap <F9> :execute "0r _posts/test.md"<CR>
"inoremap <D-V> <ESC>:r!pasteImg.py '%:t:r'<CR>
"inoremap <D-V> <ESC>:r!pasteImg.py '%'<CR>

""""""""""""""""""
" Copy Quit Save Select
" config iTerm2 keys: Esc+Ac, Esc+As, Esc+Aa
"""""""""""""""""""""
" Quit
nnoremap <C-q> :qa<CR>
" Copy
vnoremap <M-A>c "+y
" Save
nnoremap <M-A>s :up<CR>
inoremap <M-A>s <C-o>:up<CR>
" Select whole content
nnoremap <M-A>a ggVG

""""""""""""""""""""""
" Vimdiff
""""""""""""""""""""""
noremap <Leader>1 :diffget 1<CR>
noremap <Leader>2 :diffget 2<CR>
noremap <Leader>3 :diffget 3<CR>
noremap <c-j> ]c
noremap <c-k> [c

""""""""""""""
" File Format
"""""""""""""
"https://github.com/romainl/Apprentice/blob/master/colors/apprentice.vim
"autocmd ColorScheme *
hi DiffAdd      gui=none    guifg=NONE          guibg=#cccccc
hi DiffChange   gui=none    guifg=NONE          guibg=#e5d5ac
hi DiffDelete   gui=bold    guifg=#ff8080       guibg=#ffb0b0
hi DiffText     gui=none    guifg=NONE          guibg=#8cbee2
"autocmd ColorScheme * hi DiffText     gui=none    guifg=NONE          guibg=#cccccc
hi DiffAdd ctermbg=135  ctermfg=208  guibg=#262626 guifg=#87af87 cterm=reverse gui=reverse

