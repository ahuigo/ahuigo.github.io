import sys
from subprocess import getoutput as sh
import shlex
import re

ip = ''
res = sh('VBoxManage showvminfo %s' % shlex.quote(sys.argv[1]))
m = re.search(r'MAC: (\w+)', res) 
if m:
    mac = m.group(1)
    l = [mac[i:i+2].lower().lstrip('0') or '0' for i in range(0, len(mac), 2)]
    mac = ':'.join(l)
    res = sh('arp -a | grep %s' % mac )
    print(mac)
    print(res)
    m = re.search(r'([\d\.]+)', res)
    if m:
        print(m.group(1))
