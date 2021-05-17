#!/usr/bin/env python3
# newversion.py
import sys
import re
if len(sys.argv)<2:
    quit(f'Usage: newversion.py version.file')

print(''' use version:
1. newversion.py version
2. version = open('version').read().strip(),
''')

versionFile = sys.argv[1]

def incrNum(m):
    v = m.group()
    v = str(int(v)+1)
    return v


if len(sys.argv)==3:
    v = sys.argv[2]
else:
    version = open(versionFile).read().strip()
    v = re.sub(r'(?<=\.)\d+$',incrNum, version)

print(v, end='\n')
open(versionFile,'w').write(v)
