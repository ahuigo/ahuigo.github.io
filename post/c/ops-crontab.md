---
layout: page
title: ops-crontab
category: blog
description: 
date: 2018-09-27
---
# 使用帮助
    man 5 crontab

Unix/Linux 下以用户身份编辑`crontab -e`, 在`/etc/crontab` 中编辑的话则需要在命令前指定用户身份

	> crontab -e
	# run at 10 pm on weekdays, annoy Joe
	5 4 * * sun  echo "run at 5 after 4 every sunday"
	# shutdown -h now at 11pm
	00 23 * * * /sbin/shutdown -h now

	> crontab -l

For log via `tail -f /var/log/cron.log`, for more see `man 5 crontab`

If you use mac OSX, you should disable backup when you edit crontab with vim [](http://calebthompson.io/crontab-and-vim-sitting-in-a-tree/)

	autocmd filetype crontab setlocal nobackup nowritebackup

# crontab 服务
## crontab 配置文件路径

	$ man 5 crontab | grep -C5 PATH | tail
	$ vim /etc/crontab
	SHELL=/bin/sh
	PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

	# m h dom mon dow usercommand
	17 * * * *  root  cd / && run-parts --report /etc/cron.hourlyPATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

print path:

	* * * * * env > env_dump.txt


## Task: Start cron service

To start the cron service, use:

	/etc/init.d/crond start
	service crond start

	;OR RHEL/Centos Linux 7.x user:
	systemctl start crond.service

Task: Stop cron service

	/etc/init.d/crond stop
	service crond stop

	;OR RHEL/Centos Linux 7.x user:
	systemctl stop crond.service

Task: Restart cron service

	/etc/init.d/crond restart
	service crond restart

	# systemctl restart crond.service

## crontab 定时任务表达式

	0 * * * * go run /tmp/a.go >> /dev/null 2>&1

    minute        0-59
    hour          0-23
    day of month  1-31
    month         1-12 (or names, see below)
    day of week   0-7 (0 or 7 is Sun, or use names)

示例:

    */5 * * * *         每5分钟
    0 */2 * * *         每2小时
    30 16 * * *         表示每天16:30
    40 3 3,15,23 * *    表示每月3、15、23日的3 : 40
    30 3 * * 6,0        表示每周六、周日的3 : 30
    0,30 20-22 * * *    表示在每天20:00至22:00之间每隔30分钟
    0 23 * * 6          表示每星期六的23:00

# debug cron
The easiest way is simply to send all STDOUT and STDERR to Syslog


	* * * * * echo "test message" 2>&1 |logger

To ensure your jobs are executed tail on /var/log/cron

	tail -f /var/log/cron

To see all the outputs in Syslog

	tail -f /var/log/messages