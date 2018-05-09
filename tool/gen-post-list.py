#!/usr/bin/env python3
from pathlib import Path
from collections import OrderedDict
import os
import json

POST_DIR = Path(__file__).resolve().parent.parent/'post'
if not (POST_DIR).is_dir():
    quit(str(POST_DIR)+'do not exists')
else:
    os.chdir(POST_DIR)


class gentree():
    ignore_dirs = ['ai', 'atom']
    def gen_dir(self):
        tree = []
        for d in POST_DIR.iterdir():
            if d.name.startswith('.'):
                continue
            if d.is_dir() and not d.name in self.ignore_dirs:
                tree.append((d.name, self.gen_file(d)))
        return tree


    def gen_file(self, d):
        li = []
        for f in d.glob('**/*.md'):
            name = f.relative_to(POST_DIR).__str__()
            li.append(name[:-3])
        return li

index = {
    "site_name": "ahui132",
    "copyright": "CC",
    "cates": [
        {"name": "tech", "text":""}
    ],
    'tree': gentree().gen_dir(),
}

with Path('tree.json').open('w') as fp:
    fp.write(json.dumps(index))
print('done')
quit()
def iterdirRecur(d):
    post = OrderedDict()
    for f in d.iterdir():
        if f.name.startswith('.'):
            continue
        k = ''+f.name.strip('.md')
        if f.is_file():
            post[k] = 1
        else:
            post[k] = iterdirRecur(f)
    return post

d = Path(POST_DIR)
post = iterdirRecur(d)

