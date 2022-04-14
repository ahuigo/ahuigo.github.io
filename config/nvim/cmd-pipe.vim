"""""""""""""""""""""""""""""
" Vim common function Pipe2Shell
"""""""""""""""""""""""""""""
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
