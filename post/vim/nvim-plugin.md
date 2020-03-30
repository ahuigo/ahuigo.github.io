---
date: 2018-05-09
title: vim plug 插件系统
---
# vim plug 插件系统

    curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

    cat <<MM | tee -a ~/.config/nvim/init.vim
    call plug#begin('~/.vim/plugged')
        Plug 'vim-scripts/AutoComplPop'
    call plug#end()
    MM

## use

    :PluginInstall
    :PluginClean 

## Pluginlist
自动补全

    "变量/函数/path
    Plug 'vim-scripts/AutoComplPop'

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

let ack use ag:

    $ .vimrc
    let g:ackprg = 'ag --vimgrep'


    :Ack [options] {pattern} [{directories}]

# Denite
文件切换

    nnoremap <C-p> :Denite file/rec buffer<CR>
    :h denite-usage

shortcuts:

    <ESC> <C-o> normal 选择
        p preview
    i   insert filter