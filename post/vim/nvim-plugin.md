# vim-plug

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
