# 目录说明
	config
		ln ~/.config
	conf
		install-conf.sh 安装常用的配置
		install/	安装脚本
	tool/	工具库

# install
## install 
    cd www
    git clone git@github.com:ahuigo/a.git
    git clone git@github.com:ahuigo/go-lib.git
    git clone git@github.com:ahuigo/c-lib.git
    git clone git@github.com:ahuigo/py-lib.git
    git clone git@github.com:ahuigo/js-lib.git
    git clone git@github.com:ahuigo/xx.git

## install conf
    mkdir ~/bin
    sudo mkdir /usr/local/bin
    mkdir ~/www
    #git clone https://github.com/ahuigo/a ~/www/a
    ln -s ~/www/a/conf ~/
    ln -s ~/www/a/conf/.profile ~/
        #export PATH=$PATH:$HOME/www/a/bin:~/bin:/usr/local/sbin
    ln -s ~/www/a/conf/.gitconfig ~/
    ln -s ~/www/a/conf/.gitmessage ~/
    cd xx/conf && make init

## cli and app

    brew install the_silver_searcher wget gsed tree
    brew install --cask karabiner-elements
    sudo ln -s `which pip3` /usr/local/bin
    pip3 install pynvim


    # config
    ln -s ~/www/a/config/nvim ~/.config/
    ln -s ~/www/a/config/karabiner/assets/complex_modifications ~/.config/karabiner/assets/

    ## nvim-plugin.md

    ## profile
    cat <<'MM' >> ~/.zshrc
    alias p='python3'
    alias pi='pip3'
    [ -f ~/.profile ] && source ~/.profile

    export PYTHONPATH=.
    MM


# keyboard iterm2
## refer to keyboard.md

## vscode
配置同步

## home

### passwd
