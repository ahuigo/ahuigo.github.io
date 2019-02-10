# find top 10 files
git rev-list --objects --all | grep -f <(git verify-pack -v .git/objects/pack/*.idx| sort -k 3 -n | cut -f 1 -d " " | tail -10)

echo -n "Clean all git commit?(y/n)? "
read answer
if [ "$answer" != "${answer#[Yy]}" ] ;then
    git checkout --orphan latest_branch
    git add -A
    git commit -am "Delete all previous commit"
    git branch -D master
    git branch -m master
fi

## see https://github.com/18F/C2/issues/439
echo -n "Start?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) echo "Cleanup refs and logs"
            rm -Rf .git/refs/original
            rm -Rf .git/logs/

            echo "Cleanup unnecessary files"
            git gc --aggressive --prune=now

            echo "Prune all unreachable objects"
            git prune --expire now
            break;;
        No ) exit;;
    esac
done

#git push -f origin master
