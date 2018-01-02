# sparse checkout
Refer: \
https://stackoverflow.com/questions/600079/how-do-i-clone-a-subdirectory-only-of-a-git-repository

## init repo
This creates an empty repository with your remote, and fetches `-f` all objects but doesn't check them out. 
```s
mkdir <repo>
cd <repo>
git init
git remote add -f origin <url>
```
Then do config:
```s
git config core.sparseCheckout true
```
Now you need to define which files/folders you want to actually check out. 

```s
echo "some/dir/" >> .git/info/sparse-checkout
echo "another/sub/tree" >> .git/info/sparse-checkout
git pull origin master
```s