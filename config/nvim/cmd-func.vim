""""""""""""""""""""""
" :call Move('a.txt','b.txt')
""""""""""""""""""""""
function! Move(src, dst)
	exe '!mv' a:src a:dst
endfunction
com! -complete=file -nargs=* Move call Move(<f-args>)
