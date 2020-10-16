# conf
mkdir ~/www
git clone https://github.com/ahuigo/a ~/www/a
ln -s ~/www/a/conf ~/

## profile
cat <<'MM' >> ~/.zshrc
export PS1='%n@%m%{$fg[cyan]%} %c%{$fg_bold[blue]%}$(git_prompt_info)%{$fg_bold[blue]%}>%{$reset_color%}'
alias p='python3'
alias pi='pip3'
[ -f ~/.profile ] && source ~/.profile
#[[ -s /etc/profile.d/autojump.sh ]] && . /etc/profile.d/autojump.sh

export PYTHONPATH=.
MM

