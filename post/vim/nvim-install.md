---
title: install
date: 2018-10-04
---
# install
    brew install neovim
    nvim 
    :CheckHealth
    :scriptnames

## iterm2
iterm2 默认的 Profile - Terminal: Report Terminal Type = xterm , 导致nvim 乱码`:5:130m`. 
1. Report Terminal Type 改成 `xterm-256color` 或则 vim `:let &t_Co=8`

    term            | t_Co
    -----------------+------ 
    xterm           | 8
    xterm-256color  | 256

## config

    ln -s ~/.vimrc ~/.config/nvim/init.vim

    nvim -u NORC ;#not load init.vim
    nvim -u NONE ;#not load all
    nvim --clean ("use factory defaults").

like vim

    vim -u DEFAULTS
