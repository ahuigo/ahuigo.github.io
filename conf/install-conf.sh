# conf
mkdir ~/www
git clone https://github.com/ahuigo/a ~/www/a
ln -s ~/www/a/conf/.profile ~/
ln -s ~/www/a/conf/.gitconfig ~/

## profile
cat <<'MM' >> ~/.zshrc
alias p='python3'
alias pi='pip3'
[ -f ~/.profile ] && source ~/.profile

export PYTHONPATH=.
MM

