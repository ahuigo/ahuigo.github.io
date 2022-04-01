from subprocess import getoutput
import re

def main():
    out=getoutput('sw_vers')
    m = re.search(r'ProductVersion:\s+?(?P<ver>[\w\.]+)', out)
    print("macosx:",m.group('ver'))
    print("java:", getoutput('java -version'))
    print("vscode:", getoutput('code -v'))
    print("java extensions:\n", getoutput('code --show-versions --list-extensions |grep java'))
main()
    
