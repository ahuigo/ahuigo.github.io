#!/bin/sh
myIp=`ifconfig | grep broadcast | perl -nle'print $1 if m{inet ([\d.]+) netmask.+broad}'`
echo $myIp;
arp -a | perl -nle'print $1 if m{\(([\d\.]+)\) at 8:0:27:20:8f:48}'
