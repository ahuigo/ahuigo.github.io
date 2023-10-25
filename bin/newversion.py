#!/usr/bin/env python3
# newversion.py
import sys
import re
if len(sys.argv)<2:
    print(''' use version:
    # method1
    1. newversion.py version [0.0.5]
    2. version = open('version').read().strip(),
    # method2
    1. newversion.py pyproject.toml [0.0.1]
    ''')

versionFile = sys.argv[1]

def incrNum(m):
    v = str(int(m.group())+1)
    return v

newversion = '0.0.0'
def incrVersion(m):
    global newversion
    version = m.group()
    v = re.sub(r'(?<=\.)\d+$',incrNum, version)
    newversion = v
    return v

def upgradePlainFile(versionFile):
    global newversion
    if len(sys.argv)==3:
        v = sys.argv[2]
    else:
        try:
            version = open(versionFile).read().strip()
            v = re.sub(r'(?<=\.)(-)?\d+$',incrNum, version)
        except FileNotFoundError:
            # 如果文件不存在，则写入默认版本号
            v = "v0.0.1"

    newversion = v
    open(versionFile,'w').write(v)
    return newversion

def upgradePyprojectToml(filename):
    if len(sys.argv)==3:
        v = sys.argv[2]
    else:
        filetext = open(versionFile).read().strip()
        filetext = re.sub(r'(?<=version = ")\d+\.\d+\.\d+(?=")',incrVersion, filetext, count=1)

    open(versionFile,'w').write(filetext)
    return newversion

if __name__ == '__main__':
    if versionFile.endswith("pyproject.toml"):
        v = upgradePyprojectToml(versionFile)
    else:
        v = upgradePlainFile(versionFile)

    print(v, end='')

