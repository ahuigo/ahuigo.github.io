#!/usr/bin/env python3
from pathlib import Path
from collections import OrderedDict

def iterdir(d):
    post = OrderedDict()
    for f in d.iterdir():
        if f.name.startswith('.'):
            continue
        k = ''+f.name.strip('.md')
        if f.is_file():
            post[k] = 1
        else:
            post[k] = iterdir(f)
    return post

d = Path('../post/')
post = iterdir(d)

import json
print(json.dumps(post))
