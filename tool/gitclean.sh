## This script is used to clean all git commit
#git checkout --orphan latest_branch
#git add -A
#git commit -am "Delete all previous commit"
#git branch -D master
#git branch -m master
#git push -f origin master

# https://github.com/18F/C2/issues/439
rm -Rf .git/refs/original
rm -Rf .git/logs/
git gc --aggressive --prune=now
git prune --expire now
