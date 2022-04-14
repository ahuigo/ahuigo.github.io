""""""""""""""""""""""""""""
" operatorfunc
""""""""""""""""""""""""""""""""
nnoremap <leader>g :set operatorfunc=GrepOperator<cr>g@<cr>
vnoremap <leader>g :<c-u>call GrepOperator(visualmode())<cr>

function! GrepOperator(type)
	echom a:type
endfunction

nmap <silent> <F12> :set opfunc=CountSpaces<CR>g@
vmap <silent> <F12> :<C-U>call CountSpaces(visualmode(), 1)<CR>

function! CountSpaces(type, ...)
	let sel_save = &selection
	let &selection = "inclusive"
	let reg_save = @@

	if a:0  " Invoked from Visual mode, use gv command.
		silent exe "normal! gvy"
	elseif a:type == 'line'
		silent exe "normal! '[V']y"
	else
		silent exe "normal! `[v`]y"
	endif

	echomsg strlen(substitute(@@, '[^ ]', '', 'g'))
	echomsg @@
	echomsg a:type
	echomsg a:0

	let &selection = sel_save
	let @@ = reg_save
endfunction
