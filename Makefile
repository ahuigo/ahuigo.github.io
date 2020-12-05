init:
	git remote add gitee https://gitee.com/ahuigo/all.git

.PHONY: config
config:
	echo ln ~/.config
	#ln -s `pwd`/config/* ~/.config/
	sh conf/install-conf.sh

.PHONY: conf
conf:
	ln -s `pwd`/conf/.gitconfig ~/
	ln -s `pwd`/tool/pre-commit ~/.git/hooks/pre-commit
echo:
	echo abc

