init:
	ln -s `pwd`/.gitconfig .git/config
	ln -s `pwd`/tool/pre-commit .git/hooks/pre-commit

