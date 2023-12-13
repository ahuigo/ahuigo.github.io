---
title: git clean
date: 2023-12-09
private: true
---
# clean untracked
clean files

	git clean " clean untracked files only
        -X  "ignore only
        -x  "ignore and untrack
        -d  "directory
        -f  "force
        -n -f " with check

If you want to also remove *directories*, run

	git clean -f -d or git clean -fd

# clean history
/tool/gitclean.sh

# git config files 
/tool/gitfile
# git sync branch
/tool/git-sync
