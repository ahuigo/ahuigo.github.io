#!/usr/bin/env python3
from pathlib import Path
from collections import OrderedDict
import os,sys
import json

POST_DIR = Path(__file__).resolve().parent.parent/'post'

if not (POST_DIR).is_dir():
    quit(str(POST_DIR)+'do not exists')
else:
    os.chdir(POST_DIR.parent)

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

from subprocess import getoutput
import re
def getModifiedPaths()->set:
    # cmd = 'git diff-index --cached --name-status --diff-filter=ACMR HEAD | grep -E "\spost/.+.md$" '
    cmd = 'git diff-index --name-status --diff-filter=ACMR HEAD . | grep -oE "\spost/.+.md$" '
    out = getoutput(cmd).strip()
    paths = set()
    if not out:
        return
    for line in out.split('\n'):
        m = re.search(r'(post/.+)/[\w\-\.]+\.md', line)
        if not m:
            quit(f'bad path:`{line}`')
        paths.add(m.group(1))
    return sorted(paths, key=lambda path: path)


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
        dirs = getModifiedPaths()
    for path in dirs:
        gendir(path)
