# 目录说明
	config
		ln ~/.config
	conf(app)
		install-conf.sh 安装常用的配置
		install/	安装脚本
	tool/	工具库
        gitclean.sh
            export PATH=$PATH:~/www/a/tool
    bin/

# my repo
    cd www
    git clone git@github.com:ahuigo/a.git
    git clone git@github.com:ahuigo/go-lib.git
    git clone git@github.com:ahuigo/c-lib.git
    git clone git@github.com:ahuigo/py-lib.git
    git clone git@github.com:ahuigo/js-lib.git
    git clone git@github.com:ahuigo/xx.git

# base install
    on-my-zsh
    brew.sh
    brew install the_silver_searcher wget gsed tree
    brew install --cask karabiner-elements
    sudo ln -s `which pip3` /usr/local/bin
    pip3 install pynvim

local:

    local.rc

# config
## copy conf
    mkdir ~/bin
    sudo mkdir /usr/local/bin
    mkdir ~/www
    #git clone https://github.com/ahuigo/a ~/www/a
    ln -s ~/www/a/conf ~/
    ln -s ~/www/a/conf/.profile ~/
        #export PATH=$PATH:$HOME/www/a/bin:~/bin:/usr/local/sbin
    ln -s ~/www/a/conf/.gitconfig ~/
    ln -s ~/www/a/conf/.gitmessage ~/
    ln -s ~/www/autotool/git_template ~/.git_template
    cd prixx/conf && make init

## link conf
    # config
    ln -s ~/www/a/config/nvim ~/.config/
    ln -s ~/www/a/config/karabiner/assets/complex_modifications ~/.config/karabiner/assets/

    ## profile
    cat <<'MM' >> ~/.zshrc
    alias p='python3'
    alias pi='pip3'
    [ -f ~/.profile ] && source ~/.profile
    export PYTHONPATH=.
    MM
# backup

    /bak

# app(/conf)
## nvim
see nvim-plugin.md

## keyboard iterm2
see keyboard.md

## vscode
配置同步

## openresty
    brew install openresty/brew/openresty-debug
    brew services restart openresty-debug
    ln -s ~/www/a/conf/nginx/nginx.conf /opt/homebrew/etc/openresty/nginx.conf
    ln -s ~/www/a/conf/nginx/resty.*.conf /opt/homebrew/etc/openresty/
