---
date: 2018-05-09
title: vim plug 插件系统
---
# vim plug 插件系统
vim-plug 是用于安装vim/nvim 插件的

    curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

    # call plug#begin('~/.vim/plugged')
    cat <<MM | tee -a ~/.config/nvim/init.vim
    call plug#begin('~/.local/share/nvim/plugged')
        Plug 'neoclide/coc.nvim', {'branch': 'release'}
        Plug 'neomake/neomake'
    call plug#end()
    MM

## install

    :PluginInstall
    :PluginClean 
    :CheckHealth

或者：直接在shell 中执行，参考vim-command-ex.md

    nvim +PluginInstall +PluginClean   +qall
    nvim +CheckHealth

## uninstall plugin
1. Remove the line from your config,
2. Quit and restart Vim, and then
2. Run `:PlugClean`. You will be prompted to delete the directory, type Y.

If the above does not work for some reason, you can delete the directory manually from the `~/.config/plugged` directory.
## config reload

    :so %
    :source %

# ag
a code search cli tool with focus on speed.
1. It is an order of magnitude faster than ack.
2. It ignores file patterns: .gitignore and .hgignore.
    1.  if node_modules is in .gitignore, it will ignore
3. Other ignore patterns to a .ignore file. (*cough* *.min.js *cough*)

    ack test_blah ~/code/  104.66s user 4.82s system 99% cpu 1:50.03 total
    ag test_blah ~/code/  4.67s user 4.58s system 286% cpu 3.227 total

## usage:

    $ brew install the_silver_searcher

## Ack搜索：默认ack, 支持ag
    Plug 'mileszs/ack.vim'

let ack use ag:

    $ .vimrc
    let g:ackprg = 'ag --vimgrep'
    :Ack [options] {pattern} [{directories}]
    :Ack [options] {pattern} %

# Denite(ctrl+p)
文件切换

    nnoremap <C-p> :Denite file/rec buffer<CR>
    :h denite-usage

shortcuts:

    <ESC> <C-o> normal 选择
        p preview
    i   insert filter

# debug
## health check
see vim-debug.md for  `:checkhealth`
