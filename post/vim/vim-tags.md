---
layout: page
title:
category: blog
description:
---
# Preface

# Autocmd to update ctags file

	function! DelTagOfFile(file)
	  let fullpath = a:file
	  let cwd = getcwd()
	  let tagfilename = cwd . "/tags"
	  let f = substitute(fullpath, cwd . "/", "", "")
	  let f = escape(f, './')
	  let cmd = 'sed -i "/' . f . '/d" "' . tagfilename . '"'
	  let resp = system(cmd)
	endfunction

	function! UpdateTags()
	  let f = expand("%:p")
	  let cwd = getcwd()
	  let tagfilename = cwd . "/tags"
	  let cmd = 'ctags -a -f ' . tagfilename . ' --c++-kinds=+p --fields=+iaS --extra=+q ' . '"' . f . '"'
	  call DelTagOfFile(f)
	  let resp = system(cmd)
	endfunction
	autocmd BufWritePost *.cpp,*.h,*.c call UpdateTags()

# symbols
https://github.com/atom/symbols-view/issues/9

    cd {your project directory}
    ctags -R .
