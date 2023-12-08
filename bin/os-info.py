#!/usr/bin/env python3
from subprocess import getoutput
import re,sys

def printJava():
    print("java:", getoutput('java -version'))
    print("java extensions:", getoutput('code --show-versions --list-extensions |grep java'))

def printDeno():
    print(getoutput('deno --version'))
    print("deno extensions:", getoutput('code --show-versions --list-extensions |grep deno'))
def printVscode():
    print("vscode:", getoutput('code -v').replace('\n', ' '))
    print("vscode extensions:\n", getoutput('code --list-extensions --show-versions'))

def printNode(short=False):
    print("node:", getoutput('node -v')+' '+(getoutput('which node') if not short else ''))
    print("npm:", getoutput('npm -v')+' '+(getoutput('which npm') if not short else ''))
    print("yarn:", getoutput('yarn -v')+' '+(getoutput('which yarn') if not short else ''))
    print("pnpm:", getoutput('pnpm -v')+' '+(getoutput('which pnpm') if not short else ''))

def printCpuMem():
    print("code --status:", getoutput('code --status'))
    print("============================================")
    print('''1. `code --disable-extensions` to run VS Code without any extensions ''')
    print('2. Open Activity Monitor.app please for more')

def getCpu():
    lines = getoutput('sysctl -a | grep machdep.cpu').split('\n')
    out = getoutput('uname -mrs')
    for line  in lines:
        if 'core_count:' in line:
            out += ' core('+line.split(':')[1].strip()+')'
        if 'brand_string:' in line:
            out += line.split(':')[1]
    return out

def isCmdExisted(cmd):
    from subprocess import getstatusoutput
    return getstatusoutput('hash '+cmd)[0]==0

def getOs():
    if isCmdExisted('sw_vers'):
        out=getoutput('sw_vers')
        m = re.search(r'ProductVersion:\s+?(?P<ver>[\w\.]+)', out)
        return "macOSX "+m.group('ver')
    elif isCmdExisted('hostnamectl'):
        out=getoutput('hostnamectl')
        return out
    else:
        out=open('/etc/os-release').read()
        return out

def main():
    short = True if '-s' in sys.argv else False
    print("kernel:",getoutput('uname -r'))
    print("os:",getOs())
    print("cpu:",getCpu())
    if 'deno' in sys.argv:
        printDeno()
    if 'node' in sys.argv:
        printNode(short)
    if 'java' in sys.argv:
        printJava()
    if 'cpu' in sys.argv:
        printCpuMem()
    if 'vsc' in sys.argv:
        printVscode()
main()
    
