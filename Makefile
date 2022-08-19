init:
	git remote add gitee https://gitee.com/ahuigo/all.git

.PHONY: config
config:
	echo ln ~/.config
	#ln -s `pwd`/config/* ~/.config/
	sh conf/install-conf.sh

.PHONY: conf
conf:
	ln -s `pwd`/tool/pre-commit ~/.git/hooks/pre-commit
	ln -s `pwd`/tool/pre-commit ~/www/.git/modules/a/hooks/pre-commit
	#ln -s `pwd`/tool/pre-commit ~/www/a/.git/hooks/pre-commit
	ln -s `pwd`/conf/.gitconfig ~/

echo:
	echo abc


define indexmd
---
title:	主方法复杂度证明
date: 2017-11-11
---
# 证明图
![proof](/img/algo/master-theorem-tree.png)
endef

export indexmd

tpl:
	set -x
	mkdir -p tpl/post tpl/img/algo
	cp -r 404.html README.md assets index.html  md.html tpl
	cp ./img/algo/master-theorem-tree.png tpl/img/algo/master-theorem-tree.png
	echo "$$indexmd" > tpl/post/index.md
