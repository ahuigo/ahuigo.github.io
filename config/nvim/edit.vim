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
    elseif ext == 'sh'
        !bash %
    elseif ext == 'js'
        !deno run %
    elseif ext == 'lua'
        !lua %
    elseif ext == 'ts'
        let filepath = expand('%')
        if filepath =~ '_test.ts$'
            !deno test -A %
        else
            !deno run -A %
        endif

    elseif ext == 'rs'
        !rustc % -o a && ./a
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

" vim -b : edit binary using xxd-format!
" :h hex-editing:
augroup Binary
  au!
  au BufReadPre  *.bin let &bin=1
  au BufReadPost *.bin if &bin | %!xxd
  au BufReadPost *.bin set ft=xxd | endif
  au BufWritePre *.bin if &bin | %!xxd -r
  au BufWritePre *.bin endif
  au BufWritePost *.bin if &bin | %!xxd
  au BufWritePost *.bin set nomod | endif
augroup END

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
" F1...F12 
""""""""""""""""""""""
" search
nnoremap <F1> :let @/ = ""<CR>
nnoremap  \w :%s/\s\+$//e<CR>
nnoremap <F2> "+p
inoremap <F2> <C-o>"+p
vnoremap <F2> "+y
"Shift+F2
nnoremap <F14> :w<CR>:call edit#run()<CR>
inoremap <F14> <ESC>:w<CR>:call edit#run()<CR>

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


""""""""""""""""""""""
" Vimdiff
""""""""""""""""""""""
noremap <Leader>1 :diffget 1<CR>
noremap <Leader>2 :diffget 2<CR>
noremap <Leader>3 :diffget 3<CR>
noremap <c-j> ]c
noremap <c-k> [c

""""""""""""""
" Corlor Format
"""""""""""""
"https://github.com/romainl/Apprentice/blob/master/colors/apprentice.vim
"autocmd ColorScheme *
"autocmd ColorScheme * hi DiffText     gui=none    guifg=NONE          guibg=#cccccc
"colorscheme industry
"hi DiffAdd      ctermbg=135  ctermfg=208  guibg=#262626 guifg=#87af87 cterm=reverse gui=reverse
" Refer to Xterm-color-table: https://vim.fandom.com/wiki/Xterm256_color_names_for_console_Vim?file=Xterm-color-table.png
highlight DiffAdd    cterm=bold ctermfg=10 ctermbg=88 gui=none guifg=bg guibg=Red
highlight DiffDelete cterm=bold ctermfg=10 ctermbg=16 gui=none guifg=bg guibg=Red
highlight DiffChange cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
highlight DiffText   cterm=bold ctermfg=10 ctermbg=88 gui=none guifg=bg guibg=Red
"cterm - sets the style
"ctermfg - set the text color
"ctermbg - set the highlighting
"DiffAdd - line was added
"DiffDelete - line was removed
"DiffChange - part of the line was changed (highlights the whole line)
"DiffText - the exact part of the line that changed
