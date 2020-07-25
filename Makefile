.PHONY: config
config:
	echo ln ~/.config
	ln -s `pwd`/config/* ~/.config/

.PHONY: conf
conf:
	ln -s `pwd`/conf/.gitconfig ~/
	ln -s `pwd`/tool/pre-commit ~/.git/hooks/pre-commit
echo:
	echo abc

