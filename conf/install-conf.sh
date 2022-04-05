# conf
mkdir ~/www
#git clone https://github.com/ahuigo/a ~/www/a
ln -s ~/www/a/conf/.profile ~/
ln -s ~/www/a/conf/.gitconfig ~/
sudo mkdir /usr/local/bin

# cli and app
brew install the_silver_searcher wget gsed
brew install --cask karabiner-elements
sudo ln -s `which pip3` /usr/local/bin
pip3 install pynvim


# config
ln -s ~/www/a/config/nvim ~/.config/
ln -s ~/www/a/config/karabiner/assets/complex_modifications/* ~/.config/karabiner/assets/complex_modifications/

## nvim-plugin.md

## profile
cat <<'MM' >> ~/.zshrc
alias p='python3'
alias pi='pip3'
[ -f ~/.profile ] && source ~/.profile

export PYTHONPATH=.
MM


# keyboard iterm2

