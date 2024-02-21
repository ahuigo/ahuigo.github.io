# gnu
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew install wget gnu-sed git
brew install python3 
brew cask install google-chrome iterm2 alfred  

## dict
# a.conf
mkdir ~/www
git clone https://github.com/ahuigo/a ~/www/a
ln -s ~/www/a/conf ~/

# iterm2 profile keys
# vim
mkdir -p ~/.data/backup/

# oh my-zsh
# autojump
brew install autojump
# .gitconfig
ln -s ~/conf/.gitconfig ~

# lnmp
brew install mariadb nginx php node

# translate-shell: https://github.com/soimort/translate-shell
wget git.io/trans -O ~/bin/trans
