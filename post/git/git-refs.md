---
title: git refs
date: 2022-08-19
private: true
---
# .git 目录

    $ ls .git
    HEAD: 这个文件包含了当前检出的分支或提交的引用。
    FETCH_HEAD: 这个文件包含了最后一次执行 git fetch 或 git pull 命令时从远程仓库获取的分支的最新提交的哈希值。
    ORIG_HEAD: 这个文件通常包含了执行一些会改变 HEAD 的命令（如 git commit、git merge、git rebase 等）之前 HEAD 的值。

    index: 这个文件是 Git 的暂存区(binary)，它包含了下一次提交将会包含的更改。
    logs: 这个目录包含了所有分支和 HEAD 的更新记录。

    refs: 这个目录包含了所有的引用，如分支和标签
    objects: 这个目录包含了 Git 仓库的所有对象，如提交、树和 blob。
    packed-refs: 这个文件包含了被打包的引用，用于优化大量引用的存储。

# git refs
## refs 存储分支 commit sha 
refs 目录:　存储分支/HEAD/remotes 的commit sha
    
    ls .git/refs/
        heads/          // local
            master -> c3e9
        remotes/origin        //remote snapshot
            HEAD   -> c3e9
            master -> c3e9
        stash -> index  // 指向index 
        tags/v1.0.1 -> 76c5

ref 中存放的sha:

    $ cat .git/refs/heads/dev
    c5e017a57b4a88639418

##  sha到ref 的映射(只含remotes)
打包的分支引用

    $ head .git/packed-refs
    d15e054 refs/remotes/origin/dev
    0c5fd1f refs/remotes/origin/master

# git objects
## objects 目录
### 修改文件时的存储
修改一个文件并提交时:
1. Git 会创建一个新的 blob 对象来存储这个文件的新版本。
   1. blob 对象包含了文件的整个内容，而不仅仅是你所做的修改。
   2. 创建一个新的 tree 对象来表示包含了这个新 blob 对象的目录
   3. 创建一个新的 commit 对象来记录这次修改。
2. 每个 blob 对象的存储
   1. 文件存储到 .git/objects/8a 可能是完整文件，也可能可能是delta（取决于文件版本间的差异）
   2. 运行 git gc 命令或者对象数量达到一定的阈值时(为了优化存储空间和提高效率), 会将碎片化的对象打包到pack
      1. Git 会将这些对象 "打包" 到 .git/objects/pack 目录下
      2. 此时存储的是紧凑 delta patch, 如果文件版本间文件的差异太大则会存储整个文件内容

### ls .git/objects/8a
存储的是未打包的对象。每个对象都存储在一个以它的哈希值的前两个字符命名的子目录中

    可能存文件的完整内容, 也可能存增量更新delta patch（如果版本间差异太大的话，就存储全部内容）

### ls .git/objects/pack

    pack-*.idx 文件： 对象的哈希值 -> 对象在文件的offset, size
        这是索引文件，用于git verify-pack -v 快速查找打包文件中的对象.  

    pack-*.pack 文件：
        这是打包文件，包含了被打包的对象的内容。

    pack-*.rev 文件： 对象在文件的offset -> 对象的哈希值 
        这是可选的反向索引文件，git rev-list --objects --all  就是分析它

### ls .git/objects/info

    packs           pack 列表
    commit-graph    (可选)用于存储提交图的二进制表示。
        这个文件用来加速需要遍历commit graph的操作，如 git log、git gc 等
        你可以使用 git commit-graph write 命令来生成这个文件。

## object 类型
object 查看:

    git verify-pack -v .git/objects/pack/*.idx| sort -k 3 -n 
        sha  object-type ori-size packed-size offset  
        e085f4de.. blob   46    47 42853337
        ffb91c08.. commit 223   142 12
        de80af91.. tree   298   277 7923

    git rev-list --objects --all | ag e085f4de
        e085f4de readme.md

可以看到　object　有三个类型：

    blob：代表一个文件。每个 blob 对象都包含一个文件的内容
    commit: 每个 commit 对象都包含了一些元数据（如作者、提交者、提交信息等）和一个指向树对象的指针，这个树对象代表了仓库在这个提交时的状态。
    tree：目录对象, 每个 tree 对象都包含了一些指向 blob 对象或其他 tree 对象的指针

### top 10 files

    git rev-list --objects --all | grep -f <(git verify-pack -v .git/objects/pack/*.idx| sort -k 3 -n | cut -f 1 -d " " | tail -10)

## 删除文件
    # 使用 git filter-branch 命令来删除所有引用到 langdao.tgz 的提交
    git filter-branch --force --index-filter \
        "git rm --cached --ignore-unmatch langdao.tgz" \
        --prune-empty --tag-name-filter cat -- --all

    # 使用 git filter-branch 命令来删除所有引用到特定对象的提交
    git filter-branch --force --index-filter \
        "git rm --cached --ignore-unmatch d5503e2a" \
        --prune-empty --tag-name-filter cat -- --all

    # 清理所有reflog记录
    git reflog expire --expire=now --all

    # 清理所有未被任何对象引用的对象
    git gc --prune=now --aggressive

## sha对应object的不存在
    error: cannot lock ref 'refs/remotes/origin/mj/dev': 
        'refs/remotes/origin/mj' exists; 
        cannot create 'refs/remotes/origin/mj/dev'

两种原因：
1. 分支名冲突, 删除分支就行：git branch -D mj
2. 还有一种情况是，ref(refs/remotes/mj)引用的object 不存在：需要执行 git remote prune origin 清理没有被引用的objects