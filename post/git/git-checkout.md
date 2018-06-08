# sparse checkout
Refer: \
https://stackoverflow.com/questions/600079/how-do-i-clone-a-subdirectory-only-of-a-git-repository

## init repo
This creates an empty repository with your remote, and fetches `-f` all objects but doesn't check them out. 

    mkdir <repo>
    cd <repo>
    git init
    git remote add -f origin <url>

    #Then do config:
    git config core.sparseCheckout true

Now you need to define which files/folders you want to actually check out. 

    echo "some/dir/" >> .git/info/sparse-checkout
    echo "another/sub/tree" >> .git/info/sparse-checkout
    git pull origin master

# fiter-branch

    git filter-branch --prune-empty --subdirectory-filter FOLDER-NAME  BRANCH-NAME
