---
title: brew
date: 2018-09-27
---
# brew
- brew(Homebrew) 是近来极流行的 安装gawk,gsed,macvim等命令的安装工具，所有的包都被安装到/usr/local/Cellar下，然后再以`ln -s` 软链接的形式链接到`/usr/local/`目录下

- Homebrew-cask是一套建立在homebrew基础上的Mac软件安装命令行工具 ，有了它再也不想用dmg了（每次都要下载，不停的点下一步，拖放多麻烦呀）

## brew 源
homebrew主要分两部分：git repo（位于GitHub）和二进制bottles（位于bintray）

### brew 下载太慢
可以用vpn 或其它ss. 也可以手动下载，以go 为例子：

    cd `brew --cache`
    rm go-1.6.2.el_capitan.bottle.tar.gz
    mv /Downloads/go-1.6.2.el_capitan.bottle.tar.gz ./
    
    cd `brew --cache`/Cask
    ~/Library/Caches/Homebrew/Cask

    
继续执行：brew install go, 据说，你可能会遇到签名问题

#### brew cask path
    ==> Homebrew-cask Staging Location:
    /opt/homebrew-cask/Caskroom
    ==> Homebrew-cask Cached Downloads:
    /Library/Caches/Homebrew
    /Library/Caches/Homebrew/Casks
    ~/Library/Caches/Homebrew/Cask


### brew 使用curl 下载
可以用curl 代理，编辑~/.curlrc:

    socks5 = "127.0.0.1:1080"

or:

    export ALL_PROXY=socks5://127.0.0.1:1080

### 替换及重置Homebrew默认源

    #替换brew.git:
    git -C "$(brew --repo)" remote set-url origin https://mirrors.ustc.edu.cn/brew.git

    #替换homebrew-core.git:
    cd "$(brew --repo)/Library/Taps/homebrew/homebrew-core"
    git remote set-url origin https://mirrors.ustc.edu.cn/homebrew-core.git

切换回官方源：

    #重置brew.git:
    cd "$(brew --repo)"
    git remote set-url origin https://github.com/Homebrew/brew.git

    # 重置homebrew-core.git:
    cd "$(brew --repo)/Library/Taps/homebrew/homebrew-core"
    git remote set-url origin https://github.com/Homebrew/homebrew-core.git

### Homebrew Bottles是Homebrew提供的二进制代码包
下载二进制会用到

    export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles

## install brew

	ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"

	# install gsed
	brew install gsed
	# intall macvim
	brew install macvim --override-system-vim
	# brew link php54
	brew unlink php54 && brew link php54

所有的安装文件都是放在.(通过link连接到其它的地方, 非常方便管理)

	ls /usr/local/Cellar

查看单个包的安装目录：

	$ brew --prefix homebrew/php/php55
	/usr/local/Cellar/php55/5.5.16
    # 查看文件
	$ brew list php55

# brew命令

## brew sth.

### brew update
Update formulae: brew update

### brew prune

	brew prune [--dry-run]:
	    Remove dead symlinks

### brew edit
Edit formulae

	brew edit <softname>
	brew edit emacs

## brew install
install cli program via brew

	brew install vim                 # installs from Homebrew/homebrew
	brew install username/repo/vim   # installs from your custom repo

### forece uninstall
    brew uninstall --force luarocks


## brew tap
brew tap allows you to add more Github repos to the list of formulae that brew tracks, updates and installs from.

	brew tap; #list all tap
	brew tap username/repo
	brew untap phinze/cask

	brew tap caskroom/cask
	brew install brew-cask
	brew cask install virtualbox
	brew cask install virtualbox-extension-pack

## brew upgrade
find all outdated packages:

	brew outdated

upgrade all packages except mysql

	brew pin mysql
	brew upgrade

## install brew-cask
brew-cask 相当于app store的命令版, app管理方式更优雅 更简洁
所有安装的软件位置: `/opt/homebrew-cask/Caskroom`, 现在已经变成了： ~/Library/Caches/Homebrew/Cask

	brew install caskroom/cask/brew-cask
	brew upgrade brew-cask
	brew upgrade; # upgrade all packages

使用：

	# install chrome & alfred2 ...
	brew cask install chrome Alfred2 qq
	# cleanup cached downloads
	brew cask cleanup
	# uninstall qq
	brew cask uninstall qq
	# update app
	brew cask uninstall APP && brew cask install APP
	# Alfred : just add manage the scope addition
	brew cask alfred link

Refer to : [brew-cask](http://ksmx.me/blog/2013/10/05/homebrew-cask-cli-workflow-to-install-mac-applications/)

> 在Alfred中添加brew cask安装程序的路径，`/opt/homebrew-cask/Caskroom`

### debug

	 brew update && brew upgrade brew-cask
	 brew cleanup && brew cask cleanup
