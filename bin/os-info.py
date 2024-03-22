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

def getOs():
    import subprocess
    import re

    # Get process info
    ps = subprocess.Popen(['ps', '-caxm', '-orss,comm'], stdout=subprocess.PIPE).communicate()[0].decode()
    vm = subprocess.Popen(['vm_stat'], stdout=subprocess.PIPE).communicate()[0].decode()

    # Iterate processes
    processLines = ps.split('\n')
    sep = re.compile('[\s]+')
    rssTotal = 0 # kB
    for row in range(1,len(processLines)):
        rowText = processLines[row].strip()
        rowElements = sep.split(rowText)
        try:
            rss = float(rowElements[0]) * 1024
        except:
            rss = 0 # ignore...
        rssTotal += rss

    # Process vm_stat
    vmLines = vm.split('\n')
    sep = re.compile(':[\s]+')
    vmStats = {}
    for row in range(1,len(vmLines)-2):
        rowText = vmLines[row].strip()
        rowElements = sep.split(rowText)
        vmStats[(rowElements[0])] = int(rowElements[1].strip('\.')) * 4096

    lines = [
    ('Wired Memory:\t\t%d MB(系统核心和其他代码需要使用的内存，不能被移动到swap)' % (vmStats["Pages wired down"]/1024/1024)),
    ('Active Memory:\t\t%d MB(正在运行的应用程序的数据)' % (vmStats["Pages active"]/1024/1024)),
    ('Inactive Memory:\t%d MB(这部分内存目前没有被使用，内存不足时可放到硬盘swap缓存/paging out)' % (vmStats["Pages inactive"]/1024/1024)),
    ('Free Memory:\t\t%d MB' % (vmStats["Pages free"]/1024/1024)),
    ('Real Mem Total (ps):\t%.3f MB' % (rssTotal/1024/1024)),
    ]
    return '\n'.join(lines)
def isCmdExisted(cmd):
    from subprocess import getstatusoutput
    return getstatusoutput('hash '+cmd)[0]==0

def getOsRelease():
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
    print("os-release:",getOsRelease())
    print("cpu:",getCpu())
    print("kernel:",getoutput('uname -r'))
    print("OSinfo:\n",getOs(),sep='')
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
    
