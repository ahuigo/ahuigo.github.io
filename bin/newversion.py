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

def panic(s):
    print(s)
    quit(1)

versionFile = sys.argv[1]
if not re.match(r'[a-zA-Z]', versionFile):
    print('invalid file:', versionFile)
    quit(1)


forceVersion = ""
if len(sys.argv)>=3:
    v = sys.argv[2]
    if re.match(r'\d+(\.\d+){2}$', sys.argv[2]):
        forceVersion = v
    else:
        panic(f"invalid version: {v}")



def incrNum(m):
    v = str(int(m.group())+1)
    return v


def upgradePlainFile(versionFile):
    if forceVersion:
        v = forceVersion
    else:
        try:
            version = open(versionFile).read().strip()
            v = re.sub(r'(?<=\.)(-)?\d+$',incrNum, version)
        except FileNotFoundError:
            # 如果文件不存在，则写入默认版本号
            v = "v0.0.1"

    open(versionFile,'w').write(v)
    return v

def getVersionFromStr(s:str):
    m=re.search(r'\d+(\.\d+){2}',s) 
    return m.group(0)

def upgradePyFile(versionFile):
    if forceVersion:
        v = forceVersion
    else:
        try:
            version = open(versionFile).read().strip()
            v = re.sub(r'(?<=\.)\d+(?=\')',incrNum, version)
        except FileNotFoundError:
            # 如果文件不存在，则写入默认版本号
            v = "0.0.1"

    open(versionFile,'w').write(v)
    return getVersionFromStr(v)

def upgradePyprojectToml(filename):
    filetext = open(versionFile).read().strip()
    if forceVersion:
        def incrVersion(m):
            return forceVersion
        filetext = re.sub(r'(?<=\nversion = ")\d+\.\d+\.\d+(?=")',incrVersion, filetext, count=1)
    else:
        def incrVersion(m):
            version = m.group()
            v = re.sub(r'(?<=\.)\d+$',incrNum, version)
            return v
        filetext = re.sub(r'(?<=\nversion = ")\d+\.\d+\.\d+(?=")',incrVersion, filetext, count=1)

    open(versionFile,'w').write(filetext)
    return getVersionFromStr(filetext)

if __name__ == '__main__':
    if versionFile.endswith("pyproject.toml"):
        v = upgradePyprojectToml(versionFile)
    elif versionFile.endswith(".py"):
        v = upgradePyFile(versionFile)
    else:
        v = upgradePlainFile(versionFile)

    print(v, end='')

