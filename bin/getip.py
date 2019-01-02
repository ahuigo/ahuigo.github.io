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
    print(mac)

    myip = sh("ifconfig |grep -oP 'inet (\d+\.){3}\d+ .* broadcast' ")
    myip = re.search(r'[\d\.]+', myip).group(0)
    if '10.28.' in myip:
        print('myip %s' % myip)
        sh('for i in {142..145};do echo $i;ping -t1 -c1 10.28.209.$i ; done')

    res = sh('arp -a | grep %s' % mac )
    print(res)
    m = re.search(r'([\d\.]+)', res)
    if m:
        print(m.group(1))
