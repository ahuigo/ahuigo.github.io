#!/usr/bin/env python3
from pathlib import Path
from collections import OrderedDict
import os,sys
import json
from   typing import Set

# todo
# 1. create seo page
# 1. create seo archive
POST_DIR = Path(__file__).resolve().parent.parent/'post'
B_DIR = POST_DIR.parent.parent/'b'

if not (POST_DIR).is_dir():
    quit(str(POST_DIR)+'do not exists')
else:
    os.chdir(POST_DIR.parent)
    
class SeoRepo:
    @staticmethod
    def IsDeletedSeoFile(seopath:Path, files:Set[Path]):
        if not seofile.isfile():
            return False
        oriPath = POST_DIR/seofile.relative_to(B_DIR)
        if files.has(oriPath):
            return False
        return True

    # post/a.md -> b/post/a.html
    @staticmethod
    def SeoPath(path:Path)->Path:
        seopath = B_DIR/path.relative_to(POST_DIR)
        return seopath

    def publishBlog(oriPath:Path):
        todo

def generateSeoPagePath(path:Path, files:Set[Path]):
    # 2. delete page
    for seofile in SeoPath(path):
        if SeoRepo.IsDeletedSeoFile(seopath, files):
            print('delete', seopath)
            quit()
            seopath.delete()

    # 1. create seo page? if page is not existed or modified
    for file in files:
        seopath = B_DIR/file.resolve()[:-3]
        if not seopath.exists() or seopath.modified > file.modified:
            generateSeoPage(file)

# gendir -
def gendir(path:Path|str)->str:
    if isinstance(path,str):
        path = Path(path)
    files = []
    for d in path.iterdir():
        if d.name.startswith('.'):
            continue
        if str(d)== 'post/ai':
            continue
        if d.is_dir():
            files.append({
                "name": d.name,
                "path": str(d),
                "type":"dir",
            })
        elif d.name.endswith('.md'):
            files.append({
                "name": d.name,
                "path": str(d),
                "type":"file",
            })

    files = sorted(files, key=lambda data: data['name'])
    dirJsonPath = path/".dir.json"
    data = json.dumps(files, ensure_ascii=False,indent=2).encode()
    # print(data.decode())
    if not dirJsonPath.exists() or open(dirJsonPath,'rb').read()!=data:
        print(f"generate {dirJsonPath}")
        open(dirJsonPath,'wb').write(data)

    # 1. create archive page? if data changed
    # 2. create seo page? if not exists or in modified
        # 2. delete page
    generateSeoPagePath(path, files)


from subprocess import getoutput
import re
def getModifiedPaths()->[set,set]:
    # cmd = 'git diff-index --cached --name-status --diff-filter=ACMR HEAD | grep -E "\spost/.+.md$" '
    cmd = 'git diff-index --name-status --diff-filter=ACMR HEAD post | grep -oE "\spost/.+.md$" '
    out = getoutput(cmd).strip()
    paths = set()
    filePaths = set()
    if not out:
        return
    for line in out.split('\n'):
        m = re.search(r'(post/.+)/[\w\-\.]+\.md', line)
        if not m:
            quit(f'bad path:`{line}`')
        paths.add(m.group(1))
        filePaths.add(m.group(0))
    return sorted(paths, key=lambda path: path), filePaths


#path = Path('post')
def alldirs(path):
    yield path
    for d in path.iterdir():
        if d.name.startswith('.'):
            continue
        if not d.is_dir():
            continue
        for sd in alldirs(d):
            yield sd
        yield d

if __name__ == '__main__':
    # gendir('post')
    if '-a' in sys.argv:
        print('generate .dir.json for all directory')
        dirs = alldirs(Path('post'))
    else:
        print('generate .dir.json for modified directory')
        dirs,filePaths = getModifiedPaths()
    for path in dirs:
        gendir(path, modifiedPath)
