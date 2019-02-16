---
title: Change ssh port
date: 2019-02-16
---
# Change ssh port

1.Config : `$ vi /etc/ssh/sshd_config`, if you wanna support multiple port like 2222

    Port 22
    Port 2222

2.Config firewall

    firewall-cmd --zone=public --add-port=2222/tcp --permanent
    # selinux
    semanage port -a -t ssh_port_t -p tcp 2222
    firewall-cmd --reload

2.reboot sshd

    service sshd restart
    systemctl restart sshd