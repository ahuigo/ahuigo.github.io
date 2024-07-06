---
title: os info
date: 2024-07-06
private: true
---
# os info

## os version
check os version:

	cat /etc/*-release

	lsb_release -a
	OS=$(lsb_release -si)
	ARCH=$(uname -m | sed 's/x86_//;s/i[3-6]86/32/')
	VER=$(lsb_release -sr)

kernel version:

	 uname -a
	 uname -r
	 uname -mrs

see kernel version and gcc version used to build the same:

	$ cat /proc/version

## cpuinfo
Set process count as cpu cores is a good start:

	# grep -c ^processor /proc/cpuinfo
	worker_processes 2;
