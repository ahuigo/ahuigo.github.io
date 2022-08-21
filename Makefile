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
title: 递归树法
date: 2017-11-11
---
# 递归树法证明
![proof](/img/algo/master-theorem-tree.png)
endef

export indexmd

.PHONY: tpl
tpl:
	set -x
	mkdir -p tpl/post tpl/img/algo tpl/tool
	cp -r 404.html README.md assets index.html atom.xml md.html tpl
	cp tool/pre-commit tpl/tool
	cp ./img/algo/master-theorem-tree.png tpl/img/algo/master-theorem-tree.png
	echo "$$indexmd" > tpl/post/algo.md
	echo "# Index\n- 2021-01-01 [复杂度证明](/b/algo)" > tpl/index.md
