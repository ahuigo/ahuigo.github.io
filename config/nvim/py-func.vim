""""""""""""""""""""
" example tts#Speak
""""""""""""""""""""
python3 << END
import vim
def GetRange():
    buf = vim.current.buffer
    print(buf, type(buf))
    (lnum1, col1) = buf.mark('<')
    (lnum2, col2) = buf.mark('>')
    lines = vim.eval('getline({}, {})'.format(lnum1, lnum2))
    print(lines)
    return (lnum1,lnum2)
    if len(lines) == 1:
        lines[0] = lines[0][col1:col2 + 1]
    else:
        lines[0] = lines[0][col1:]
        lines[-1] = lines[-1][:col2 + 1]
    return "\n".join(lines)

def Text2Speech(visual):
  if visual == "0":
    word = vim.eval("expand('<cWORD>')")
  else:
    word = GetRange()

  print("word:",word)
END

" source tts.vim|call tts#Speak(1)
function! tts#Speak(visual) 
  :py3 Text2Speech(vim.eval("a:visual"))
endfunction

""""""""""""""""""""
" example EditRun
""""""""""""""""""""
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
