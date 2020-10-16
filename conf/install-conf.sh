# conf
mkdir ~/www
#git clone https://github.com/ahuigo/a ~/www/a
ln -s ~/www/a/conf/.profile ~/
ln -s ~/www/a/conf/.gitconfig ~/

# config
ln -s ~/www/a/config/nvim ~/.config/
ln -s ~/www/a/config/karabiner/assets/complex_modifications/* ~/.config/karabiner/assets/complex_modifications/

# keyboard: vim

## profile
cat <<'MM' >> ~/.zshrc
alias p='python3'
alias pi='pip3'
[ -f ~/.profile ] && source ~/.profile

export PYTHONPATH=.
MM

