"echom "my edit.vim"
nnoremap <F1> :let @/ = ""<CR>
nnoremap  \w :%s/\s\+$//e<CR>

python3 << END
import vim
def EditRun():
    ext = vim.eval("expand('%:e')")
    if ext == 'py':
        vim.command('!python3 %')
    elif ext == 'go':
        filepath = vim.eval("expand('%')")
        if filepath.endswith('_test.go'):
            vim.eval('!go test -v '+filepath)
        else:
            vim.eval('!go run %')
    elif ext == 'vim':
        vim.command('echom "save ".expand("%")')
        #vim.command('source %')
END

" source tts.vim|cmd2
function! edit#run()
    let ext = expand('%:e')
    if ext == 'py'
        !python3 %
    elseif ext == 'go'
        let filepath = expand('%')
        if filepath =~ '_test.go$'
            "exe '!go test -v' . filepath
            !go test -v %
        else
            !go run %
        endif
    elseif ext == 'vim'
        echom "save ".expand("%")
    endif
  ":py3 EditRun()
endfunction 


"" run code """""""""""""""""
nnoremap <F3> :w<CR>:call edit#run()<CR>

