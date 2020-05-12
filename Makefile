conf1:
	echo ln ~/.config
	ln -s `pwd`/config/* ~/.config/
init:
	ln -s `pwd`/.gitconfig .git/config
	ln -s `pwd`/tool/pre-commit .git/hooks/pre-commit
echo:
	echo abc

