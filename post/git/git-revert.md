---
title: git revert
date: 2022-03-18
private: true
---
# git revert
## revet commit

    # 只回滚commitA 的修改
    git revert -n commitA

    # 回滚多个
    git revert -n commitA commitB commitC

    # 回滚commitA之间commitB的所有修改（不含最初提交：commitA或commitB）, 以下等价
    git revert -n commitA...commitB
    git revert -n commitB...commitA

note: `git revert -n` 指not commit, 需要继续的话

    git revert --continue
    # or
    git revert --abort

## revert abort

    # 取消合并
    git revert --abort

    # 取消合并, 但保留变化文件
    git revert --quit


## -m

    C1->C2->C3->B2C3->C5->C6->C7->HEAD
      |-B2->B2/

git revert -m1 B2C3 创建了新分支: `HEAD-(B2-C3)`
git revert -m2 B2C3 创建了新分支: `HEAD-(C3-C2)`

    C1->C2->C3->C4->C5->C6->C7->HEAD

git revert C3 会创建新分支: `HEAD-(C3-C2)`

恢复到HEAD 之前的提交:

	git revert HEAD //Creat a new commit to drop HEAD's modifies. '
        相当于merge HEAD^ based on HEAD: 
        git checkout HEAD^ . ; // copy HEAD^ -> working === index 
            git checkout . ; // copy index -> working
        git commit -m 'rever version xxx'

    # merge parent based on HEAD^^
	git revert HEAD^^ -m 1
	git revert A2 -m 1

        git log --graph
        A0 -- A1 -- A2 -- A3 -- A4(HEAD)
         \        /      
          B0-----B1

        -m 1 :merge A1 (Base on A2)
        -m 2 :merge B1 (Base on A2)

> Note: git revert is used to record some new commits to reverse the effect of some earlier commits (often only a faulty one).
