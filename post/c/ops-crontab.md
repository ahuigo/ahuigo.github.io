---
layout: page
title: ops-crontab
category: blog
description: 
date: 2018-09-27
---
# Preface
    man 5 crontab

# example

	0 * * * * php a.php >> /dev/null 2>&1

    minute        0-59
    hour          0-23
    day of month  1-31
    month         1-12 (or names, see below)
    day of week   0-7 (0 or 7 is Sun, or use names)

# flock
火丁笔记， 任务加锁

    flock -xn

# PATH

	$ man 5 crontab | grep -C5 PATH | tail
	$ vim /etc/crontab
	SHELL=/bin/sh
	PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

	# m h dom mon dow usercommand
	17 * * * *  root  cd / && run-parts --report /etc/cron.hourlyPATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

print path:

	* * * * * env > env_dump.txt


# debug
The easiest way is simply to send all STDOUT and STDERR to Syslog


	* * * * * echo "test message" 2>&1 |logger

To ensure your jobs are executed tail on /var/log/cron

	tail -f /var/log/cron

To see all the outputs in Syslog

	tail -f /var/log/messages