---
layout: page
title:	
category: blog
description: 
---
# Preface
OM(Operation Maintenance) 运维
http://www.178linux.com/archives/999

1. Bootstrapping： Kickstart、Cobbler、rpmbuild/xen、kvm、lxc、Openstack、 Cloudstack、Opennebula、Eucalyplus、RHEV
1. 配置类工具: Capistrano、Chef、puppet、func、salstack、Ansible、rundeck
1. 监控类工具: Cacti、Nagios(Icinga)、Zabbix、基于时间监控前端Grafana、Mtop、MRTG(网络流量监控图形工具)、Monit 
1. 性能监控工具: dstat(多类型资源统计)、atop(htop/top)、nmon(类Unix系统性能监控)、slabtop(内核slab缓存信息)、sar(性能监控和瓶颈检查)、sysdig(系统进程高级视图)、tcpdump(网络抓包)、iftop(类似top的网络连接工具)、iperf(网络性能工具)、smem)(高级内存报表工具)、collectl(性能监控工具)
1. 免费APM工具: mmtrix(见过的最全面的分析工具)、alibench
1. 进程监控: mmonit、Supervisor 
1. 日志系统: Logstash、Scribe
1. 绘图工具: RRDtool、Gnuplot
1. 流控系统: Panabit、在线数据包分析工具Pcap Analyzer
1. 安全检查: chrootkit、rkhunter
1. PaaS： Cloudify、Cloudfoundry、Openshift、Deis （Docker、CoreOS、Atomic、ubuntu core/Snappy） 
1. Troubleshooting:Sysdig 、Systemtap、Perf
1. 持续集成: Go、Jenkins、Gitlab
1. 磁盘压测: fio、iozone、IOMeter(win)
1. Memcache Mcrouter(scaling memcached)
1. Redis Dynomite、Twemproxy、codis/SSDB/Aerospike
1. MySQL 监控: mytop、orzdba、Percona-toolkit、Maatkit、innotop、myawr、SQL级监控mysqlpcap、拓扑可视化工具 
1. MySQL基准测试: mysqlsla、sql-bench、Super Smack、Percona's TPCC-MYSQL Tool、sysbench 
1. MySQL Proxy: SOHU-DBProxy、Altas、cobar、58同城Oceanus
1. MySQL逻辑备份工具: mysqldump、mysqlhotcopy、mydumper、MySQLDumper 、mk-parallel-dump/mk-parallel-restore
1. MySQL物理备份工具: Xtrabackup、LVM Snapshot
1. MongoDB压测: iibench&sysbench

# 自动管理
配置类工具: Capistrano、Chef、puppet、func、salstack、Ansible、rundeck

# puppet
puppet是一个开源的软件自动化配置和部署工具，它使用简单且功能强大，正得到了越来越多地关注，现在很多大型IT公司均在使用puppet对集群中的软件进行管理和部署，如google利用puppet管理超过6000台地mac桌面电脑

## start & stop

	service puppet stop
	service puppet start

# cfengine
cfengine（配置引擎）是一种 UNIX 管理工具，其目的是使简单的管理的任务自动化，使困难的任务变得较容易。Cfengine 适用于管理各种环境，从一台主机到上万台主机的机群均可使用。到2.2 版本为止，我们现在所知的用于一般性管理的最大安装机群约为20，000 台。
