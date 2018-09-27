#!/usr/bin/env python3
import sys
import os
import re
#from subprocess import getoutput
from datetime import datetime
from collections import OrderedDict
def parseBlog(path):
    blog = {}
    data = open(path).read();
    if data.startswith('---\n'):
        pos = data.index('\n---\n', 4)
        if pos > 100:
            quit(f'path {path} postion broken!')
        blogStr = data[4:pos]
        data = data[pos+5:]
        for line in blogStr.split('\n'):
            k, v = line.split(':', 1)
            blog[k] = v.strip()
        if blog.get('title', ''):
            print(f"Skip {path}")
            return True;

    content = data.strip()
    print(path, '--------')
    title,_ = content.split('\n', 1)
    title = title.strip('# ')
    content = content.replace('\n# Reference\n', '\n# References\n')
    if title.lower() == 'preface':
        title = path.split('/')[-1][:-3]
    blog['title'] = title
    if not blog.get('date', ''):
        blog['date'] = datetime.now().strftime('%Y-%m-%d')
    blog['content'] = content
    return blog


from glob import glob
def loopMd():
    #for path in glob('post/eng/**/*.md', recursive=True):
    for path in glob('post/proj/**/*.md', recursive=True):
        yield path

import itertools
for path in loopMd():
    blog = parseBlog(path)
    if isinstance(blog, dict) and blog['content']:
        print(path)
        yaml = '---\n'
        for k,v in blog.items():
            if k !='content':
                yaml += f'{k}: {v}\n'
        yaml+='---\n'
        content = yaml + blog['content']
        print(content[:100])
        print(content[-100:])
        #y = input('confirm:')
        #if not y:
        #    print('%r'%y)
        open(path, 'w').write(content)

