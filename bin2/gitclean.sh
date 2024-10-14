#!/usr/bin/env bash
# find top 10 files
git rev-list --objects --all | grep -f <(git verify-pack -v .git/objects/pack/*.idx| sort -k 3 -n | cut -f 1 -d " " | tail -10)
echo -n "Clean all git commit?(y/n)? "
read answer
if [ "$answer" != "${answer#[Yy]}" ] ;then
    current_branch=$(git branch --show-current)
    # checkout empty branch(无历史提交)
    git checkout --orphan latest_branch 
    git add -A
    git commit -am "Delete all previous commit"
    git branch -D $current_branch
    git branch -m main
fi

## see https://github.com/18F/C2/issues/439
echo -n "Start?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) echo "Cleanup refs and logs"
            rm -Rf .git/refs/original
            rm -Rf .git/logs/

            echo "Cleanup unnecessary files"
            # --aggressive 选项会使命令更彻底地清理仓库
            # --prune=now 选项会立即删除所有未被任何对象引用的对象
            git gc --aggressive --prune=now

            echo "Prune all unreachable objects"
            git prune --expire now
            break;;
        No ) exit;;
    esac
done

#git push -f origin HEAD


################## list object files ###################
# du -sh .git/objects/*
# git verify-pack -v .git/objects/pack/pack-746cb01fab7421d1f9565ed4aae632eb67e0c1b2.pack
# $ git rev-list --objects --all | grep -f <(git verify-pack -v .git/objects/pack/*.idx| sort -k 3 -n | cut -f 1 -d " " )
# $ git rev-list --objects --all | grep d5503e2a37d80c1d27742780ed3212c97d4f9aaf
# d5503e2a37d80c1d27742780ed3212c97d4f9aaf langdao.txt
# git show d5503e2a37d80c1d27742780ed3212c97d4f9aaf

# 使用 git filter-branch 命令来删除所有引用到 langdao.tgz 的提交
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch langdao.tgz" \
  --prune-empty --tag-name-filter cat -- --all

# 使用 git filter-branch 命令来删除所有引用到特定对象的提交
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch d5503e2a37d80c1d27742780ed3212c97d4f9aaf" \
  --prune-empty --tag-name-filter cat -- --all

# 清理所有reflog记录
git reflog expire --expire=now --all

# 使用 git gc 命令来清理未被任何对象引用的对象
git gc --prune=now --aggressive
