---
layout: page
title: Reference
category: blog
description: 
date: 2018-09-27
---
# Reference
- [systemd] by ruanyifeng

[systemd]: http://www.ruanyifeng.com/blog/2016/03/systemd-tutorial-commands.html

# Preface
使用了 Systemd，就不需要再用init了。Systemd 取代了initd，成为系统的第一个进程（PID 等于 1），其他进程都是它的子进程。

	$ systemctl --version

systemd 框架：

![](/img/systemd-framework.png)

# 系统管理
Systemd 并不是一个命令，而是一组命令，涉及到系统管理的方方面面。

## systemctl
systemctl是 Systemd 的主命令，用于管理系统。

	# 重启系统
	$ sudo systemctl reboot

	# 关闭系统，切断电源
	$ sudo systemctl poweroff

	# CPU停止工作
	$ sudo systemctl halt

	# 暂停系统
	$ sudo systemctl suspend

	# 让系统进入冬眠状态
	$ sudo systemctl hibernate

	# 让系统进入交互式休眠状态
	$ sudo systemctl hybrid-sleep

	# 启动进入救援状态（单用户状态）
	$ sudo systemctl rescue

## 3.2 systemd-analyze
systemd-analyze命令用于查看启动耗时。

	# 查看启动耗时
	$ systemd-analyze

	# 查看每个服务的启动耗时
	$ systemd-analyze blame

	# 显示瀑布状的启动过程流
	$ systemd-analyze critical-chain

	# 显示指定服务的启动流
	$ systemd-analyze critical-chain atd.service

## 3.3 hostnamectl
hostnamectl命令用于查看当前主机的信息。centos7

	# 显示当前主机的信息
	$ hostnamectl

	# 设置主机名。
	$ sudo hostnamectl set-hostname rhel7

## 3.4 localectl
localectl命令用于查看本地化设置。

	# 查看本地化设置
	$ localectl

	# 设置本地化参数。
	$ sudo localectl set-locale LANG=en_GB.utf8
	$ sudo localectl set-keymap en_GB

## 3.5 timedatectl
timedatectl命令用于查看当前时区设置。

	# 查看当前时区设置
	$ timedatectl

	# 显示所有可用的时区
	$ timedatectl list-timezones

	# 设置当前时区
	$ sudo timedatectl set-timezone America/New_York
	$ sudo timedatectl set-time YYYY-MM-DD
	$ sudo timedatectl set-time HH:MM:SS

## 3.6 loginctl
loginctl命令用于查看当前登录的用户。

	# 列出当前session
	$ loginctl list-sessions

	# 列出当前登录用户
	$ loginctl list-users

	# 列出显示指定用户的信息
	$ loginctl show-user ruanyf

# Unit

## 4.1 Unit 分类
Systemd 可以管理所有系统资源。不同的资源统称为 Unit（单位）。
Unit 一共分成12种。

	Service unit：系统服务
	Target unit：多个 Unit 构成的一个组
	Device Unit：硬件设备
	Mount Unit：文件系统的挂载点
	Automount Unit：自动挂载点
	Path Unit：文件或路径
	Scope Unit：不是由 Systemd 启动的外部进程
	Slice Unit：进程组
	Snapshot Unit：Systemd 快照，可以切回某个快照
	Socket Unit：进程间通信的 socket
	Swap Unit：swap 文件
	Timer Unit：定时器

## list 列表
	list-units 
		List known units
		针对的是enabled 的x.service、x.device、session.scope
	list-unit-files 
		List installed unit files and their enablement state
		(不含.device)
	status [PATTERN...|PID...]]
		运行状态(include disabled units)
	show [PATTERN...|JOB...]
           Show properties of one or more units, jobs,
		   相似于cat，但是把默认属性也全部打印

systemctl list-units命令可以查看当前系统的所有 Unit

	# 列出正在运行的 Unit
	$ systemctl list-units

	# 列出所有Unit，包括没有找到配置文件的或者启动失败的
	$ systemctl list-units --all

	# 列出所有没有运行的 Unit
	$ systemctl list-units --all --state=inactive

	# 列出所有加载失败的 Unit
	$ systemctl list-units --failed

	# 列出所有正在运行的、类型为 service 的 Unit
	$ systemctl list-units --type=service

## 4.2 Unit 的状态
systemctl status命令用于查看系统状态和单个 Unit 的状态。

	# 显示系统状态
	$ systemctl status
		├─user.slice
		│ └─user-0.slice
		│   ├─session-34773.scope
		│   │ ├─6520 sshd: root@pts/3
		│   │ ├─6928 systemctl status
		│   │ └─6929 vim -
		└─system.slice
			├─mariadb.service
			│ └─18432 /usr/sbin/mysqld
			├─sshd.service
			│ └─893 /usr/sbin/sshd

	# 显示单个 Unit/Pid 的状态
	$ sysystemctl status mysqld.service
	$ sysystemctl status mysqld
	$ sysystemctl status 18432
		Drop-In: /etc/systemd/system/mariadb.service.d # include *.d/*.conf
				└─migrated-from-my.cnf-settings.conf
		Active: active (running) since Sat 2017-11-04 20:10:11 CST; 1 day 15h ago
		CGroup: /system.slice/mariadb.service
				└─18432 /usr/sbin/mysqld

	# 显示远程主机的某个 Unit 的状态
	$ systemctl -H root@rhel7.example.com status httpd.service
	除了status命令，systemctl还提供了三个查询状态的简单方法，主要供脚本内部的判断语句使用。

	# 显示某个 Unit 是否正在运行
	$ systemctl is-active application.service

	# 显示某个 Unit 是否处于启动失败状态
	$ systemctl is-failed application.service

	# 显示某个 Unit 服务是否建立了启动链接
	$ systemctl is-enabled application.service

## 4.3 Unit 管理
对于用户来说，最常用的是下面这些命令，用于启动和停止 Unit（主要是 service）。

	# 立即启动一个服务
	$ sudo systemctl start apache.service
		Loaded行：配置文件的位置，是否设为开机启动
		Active行：表示正在运行
		Main PID行：主进程ID
		Status行：由应用本身提供的软件当前状态
		CGroup块：应用的所有子进程
		日志块：应用的日志

	# 立即停止一个服务
	$ sudo systemctl stop apache.service

	# 重启一个服务
	$ sudo systemctl restart apache.service

	# 杀死一个服务的所有子进程
	$ sudo systemctl kill apache.service

	# 重新加载一个服务的配置文件
	$ sudo systemctl reload apache.service

	# 重载所有修改过的配置文件
	$ sudo systemctl daemon-reload

	# 显示某个 Unit 的所有底层参数
	$ systemctl show httpd.service

	# 显示某个 Unit 的指定属性的值
	$ systemctl show -p CPUShares httpd.service

	# 设置某个 Unit 的指定属性
	$ sudo systemctl set-property httpd.service CPUShares=500 

## 4.4 依赖关系
Unit 之间存在依赖关系：A 依赖于 B，就意味着 Systemd 在启动 A 的时候，同时会去启动 B。

`systemctl list-dependencies`命令列出一个 Unit 的所有依赖。

	$ systemctl list-dependencies mysqld.service

上面命令的输出结果之中，有些依赖是 Target 类型（详见下文），默认不会展开显示。如果要展开 Target，就需要使用`--all`参数。

	$ systemctl list-dependencies --all mysqld

# 五、Unit 的配置文件
每一个 Unit 都有一个配置文件，告诉 Systemd 怎么启动这个 Unit 。

## Unit 的配置文件开机启用
如果你想让该软件开机启动，就执行下面的命令（以httpd.service为例）。

	$ sudo systemctl enable sshd

上面的命令实际上是在`/etc/systemd/system`目录添加一个符号链接，指向`/usr/lib/systemd/system`里面的 sshd.service文件。

	$ ls -l /etc/systemd/system/
	sshd.service -> /usr/lib/systemd/system/sshd.service
	mysqld.service -> /usr/lib/systemd/system/mariadb.service
	mysql.service -> /usr/lib/systemd/system/mariadb.service

与之对应的，`systemctl disable`命令用于在两个目录之间，撤销符号链接关系，相当于撤销开机启动。

	$ sudo systemctl disable mysqld
	$ sudo systemctl mask mysqld ; # 禁止建立启动项 link to /dev/null

配置文件的后缀名，就是该 Unit 的种类，比如sshd.socket。如果省略，Systemd 默认后缀名为.service，所以sshd会被理解成sshd.service。

## 5.2 配置文件的列表、状态、服务的状态
systemctl list-unit-files命令用于列出所有配置文件: `*.service, *.target, *.socket, etc`

	# 列出所有配置文件
	$ systemctl list-unit-files
	UNIT FILE              STATE
	chronyd.service        enabled
	clamd@.service         static
	clamd@scan.service     disabled

	# 列出指定类型的配置文件
	$ systemctl list-unit-files --type=service
	$ systemctl list-unit-files --type=target
	$ systemctl list-unit-files --type timer ; # 定时器单元，可以提供crontab的功能

这个列表显示每个配置文件的状态，一共有四种。

	enabled：已建立启动链接
	disabled：没建立启动链接
	static：该配置文件没有[Install]部分（无法执行），只能作为其他配置文件的依赖
	masked：该配置文件被禁止建立启动链接

注意，从配置文件的状态无法看出，该 Unit 是否正在运行。这必须执行前面提到的`systemctl status`命令。

	$ systemctl status bluetooth.service

一旦修改配置文件，就要让 SystemD 重新加载配置文件，然后重新启动，否则修改不会生效。

	$ sudo systemctl restart httpd.service

## 5.3 配置文件的格式
systemctl cat命令可以查看配置文件的内容, 分不同的区块

	$ systemctl cat atd.service

	[Unit]
	Description=ATD daemon

	[Service]
	Type=forking
	ExecStart=/usr/bin/atd

	[Install]
	WantedBy=multi-user.target

从上面的输出可以看到，配置文件分成几个区块。每个区块的第一行，是用方括号表示的区别名，比如[Unit]。注意，配置文件的区块名和字段名，都是大小写敏感的。

每个区块内部是一些等号连接的键值对。 注意，键值对的等号两侧不能有空格。

	[Section]
	Directive1=value
	Directive2=value
	. . .

## 5.4 配置文件的各区块
### Unit 区块：启动顺序与依赖关系。
`[Unit]`区块通常是配置文件的第一个区块，用来定义 Unit 的元数据，以及配置与其他 Unit 的关系。它的主要字段如下。

	Description：简短描述
	Documentation：文档地址

	# Wants字段与Requires字段只涉及依赖关系，与启动顺序无关，默认情况下是同时启动的。
	Wants：弱依赖，与当前 Unit 配合的其他 Unit，如果它们没有运行，当前 Unit 不会启动失败
	Requires：强依赖，当前 Unit 依赖的其他 Unit，如果它们没有运行，当前 Unit 会启动失败

	BindsTo：与Requires类似，它指定的 Unit 如果退出，会导致当前 Unit 停止运行

	# After和Before字段只涉及启动顺序，不涉及依赖关系。
	Before：如果该字段指定的 Unit 也要启动，那么必须在当前 Unit 之后启动
	After：如果该字段指定的 Unit 也要启动，那么必须在当前 Unit 之前启动
	Conflicts：这里指定的 Unit 不能与当前 Unit 同时运行
	Condition...：当前 Unit 运行必须满足的条件，否则不会运行
	Assert...：当前 Unit 运行必须满足的条件，否则会报启动失败

	[Install]通常是配置文件的最后一个区块，用来定义如何启动，以及是否开机启动。它的主要字段如下。
	WantedBy：它的值是一个或多个 Target，当前 Unit 激活时（enable）符号链接会放入/etc/systemd/system目录下面以 Target 名 + .wants后缀构成的子目录中
	RequiredBy：它的值是一个或多个 Target，当前 Unit 激活时，符号链接会放入/etc/systemd/system目录下面以 Target 名 + .required后缀构成的子目录中
	Alias：当前 Unit 可用于启动的别名
	Also：当前 Unit 激活（enable）时，会被同时激活的其他 Unit

###  Timer 区块定时任务
见ruanyifeng 例子为： /usr/lib/systemd/system目录里面，新建一个mytimer.timer

    [Unit]
    Description=Runs mytimer every hour

    [Timer]
    OnUnitActiveSec=1h
    Unit=mytimer.service

    [Install]
    WantedBy=multi-user.target

比如crontab 它支持更丰富的定时条件:

    OnUnitActiveSec=*-*-* 02:00:00表示每天凌晨两点执行，
    OnUnitActiveSec=Mon *-*-* 02:00:00表示每周一凌晨两点执行
    OnUnitInactiveSec： 定时器上次关闭后多少时间，再次执行
    OnBootSec：系统启动后，多少时间开始执行任务
    ....

### Service 区块：启动行为
`[Service]`区块用来 Service 的配置，只有 Service 类型的 Unit 才有这个区块。它的主要字段如下。

	ExecStartPre：启动当前服务之前执行的命令
	ExecStart：启动当前服务的命令
	ExecStartPost：启动当前服务之后执行的命令

	ExecStop：停止当前服务时执行的命令
	ExecStopPost：停止当其服务之后执行的命令

	ExecReload：重启当前服务时执行的命令
	Restart：定义何种情况 Systemd 会自动重启当前服务，可能的值包括always（总是重启）、on-success、on-failure、on-abnormal、on-abort、on-watchdog
	RestartSec：自动重启当前服务间隔的秒数
	TimeoutSec：定义 Systemd 停止当前服务之前等待的秒数
	Environment：指定环境变量

	Type: 启动类型

#### 6.1 启动命令及参数
许多软件都有自己的环境参数文件，该文件可以用EnvironmentFile字段读取。
1. sshd 的环境参数文件是/etc/sysconfig/sshd。
2. 启动sshd，执行的命令是/usr/sbin/sshd -D $OPTIONS，其中的变量$OPTIONS就来自EnvironmentFile字段指定的环境参数文件。

	EnvironmentFile字段：指定当前服务的环境参数文件。该文件内部的key=value键值对，可以用$key的形式，在当前配置文件中获取。

请看下面的例子。

	[Service]
	ExecStart=/bin/echo execstart1
	ExecStart=
	ExecStart=/bin/echo execstart2
	ExecStartPost=/bin/echo post1
	ExecStartPost=/bin/echo post2

上面这个配置文件，第二行ExecStart设为空值，等于取消了第一行的设置，运行结果如下。

	execstart2
	post1
	post2

> 所有的启动设置之前，都可以加上一个连词号（-），表示"抑制错误"，即发生错误的时候，不抛出错误影响其他命令的执行。比如，:
`EnvironmentFile=-/etc/sysconfig/sshd`

#### 6.2 启动类型
Type字段定义启动类型。它可以设置的值如下。

	type=
		Type=simple：默认值，执行ExecStart指定的命令，启动主进程
		Type=forking：以 fork 方式从父进程创建子进程，创建后父进程会立即退出
		Type=oneshot：一次性进程，Systemd 会等当前服务退出，再继续往下执行
		Type=dbus：当前服务通过等待D-Bus 信号再启动
		Type=notify：当前服务启动完毕，会通知Systemd，再继续往下执行
		Type=idle：要等到其他任务都执行完，才会启动该服务。一种使用场合是为让该服务的输出，不与其他服务的输出相混合

下面是一个oneshot的例子，笔记本电脑启动时，要把触摸板关掉，配置文件可以这样写。

	[Unit]
	Description=Switch-off Touchpad

	[Service]
	Type=oneshot
	ExecStart=/usr/bin/touchpad-off

	[Install]
	WantedBy=multi-user.target

如果关闭以后，将来某个时候还想打开，配置文件修改如下。

	[Unit]
	Description=Switch-off Touchpad

	[Service]
	Type=oneshot
	ExecStart=/usr/bin/touchpad-off start
	ExecStop=/usr/bin/touchpad-off stop
	RemainAfterExit=yes

	[Install]
	WantedBy=multi-user.target

上面配置文件中，RemainAfterExit字段设为yes，表示进程退出以后，服务仍然保持执行。这样的话，一旦使用systemctl stop命令停止服务，ExecStop指定的命令就会执行，从而重新开启触摸板。

#### 6.3 重启行为
Service区块有一些字段，定义了重启行为。

	KillMode字段：定义 Systemd 如何停止 服务。
		control-group（默认值）：当前控制组里面的所有子进程，都会被杀掉
		process：只杀主进程 
			将KillMode设为process，表示只停止主进程，不停止任何sshd 子进程，即子进程打开的 SSH session 仍然保持连接。这个设置不太常见，但对 sshd 很重要，否则你停止服务的时候，会连自己打开的 SSH session 一起杀掉。
		mixed：主进程将收到 SIGTERM 信号，子进程收到 SIGKILL 信号
		none：没有进程会被杀掉，只是执行服务的 stop 命令。

	Restart字段：定义了 sshd 退出后，Systemd 的重启方式。
		no（默认值）：退出后不会重启
		on-success：只有正常退出时（退出状态码为0），才会重启
		on-failure：非正常退出时（退出状态码非0），包括被信号终止和超时，才会重启
			对于守护进程，推荐设为on-failure。对于那些允许发生错误退出的服务，可以设为on-abnormal。
		on-abnormal：只有被信号终止和超时，才会重启
		on-abort：只有在收到没有捕捉到的信号终止时，才会重启
		on-watchdog：超时退出，才会重启
		always：不管是什么退出原因，总是重启

	RestartSec字段：表示 Systemd 重启服务之前，需要等待的秒数。上面的例子设为等待42秒。

### Install 区块: 怎么样做到开机启动。
这个设置非常重要，因为执行systemctl enable sshd.service命令时，sshd.service的一个符号链接，就会放在/etc/systemd/system目录下面的multi-user.target.wants子目录之中。

	WantedBy字段：表示该服务所在的 Target。
		WantedBy=multi-user.target


# Target
Target 就是一个 Unit 组，包含许多相关的 Unit 。
1. 启动某个 Target 的时候，Systemd 就会启动里面所有的 Unit。
2. 传统的init启动模式里面，有 RunLevel 的概念，跟 Target 的作用很类似。不同的是，RunLevel 是互斥的，不可能多个 RunLevel 同时启动，但是多个 Target 可以同时启动。

## 查看Target

	# 查看当前系统的所有 Target
	$ systemctl list-unit-files --type=target

	# 查看一个 Target 强弱依赖的所有 Unit/target
	$ systemctl list-dependencies multi-user.target

## 默认的target

	# 查看启动时的默认 Target
	$ systemctl get-default
	multi-user.target

	# 设置启动时的默认 Target
	$ sudo systemctl set-default multi-user.target

## 切换target

	# 切换到另一个 target
	$ sudo systemctl isolate shutdown.target

	# 切换 Target 时，默认不关闭前一个 Target 启动的进程， 使用 isolate 命令改变这种行为，
	$ systemctl isolate graphical.target

## Target 与 传统 RunLevel 的对应关系如下。

	Traditional runlevel      New target name     Symbolically linked to...

	Runlevel 0           |    runlevel0.target -> poweroff.target
	Runlevel 1           |    runlevel1.target -> rescue.target
	Runlevel 2           |    runlevel2.target -> multi-user.target
	Runlevel 3           |    runlevel3.target -> multi-user.target
	Runlevel 4           |    runlevel4.target -> multi-user.target
	Runlevel 5           |    runlevel5.target -> graphical.target
	Runlevel 6           |    runlevel6.target -> reboot.target

它与init进程的主要差别如下。

	（1）默认的 RunLevel（在/etc/inittab文件设置）现在被默认的 Target 取代，位置是/etc/systemd/system/default.target，通常符号链接到graphical.target（图形界面）或者multi-user.target（多用户命令行）。jjjjj
	（2）启动脚本的位置，以前是/etc/init.d目录，符号链接到不同的 RunLevel 目录 （比如/etc/rc3.d、/etc/rc5.d等），现在则存放在/lib/systemd/system和/etc/systemd/system目录。
	（3）配置文件的位置，以前init进程的配置文件是/etc/inittab，各种服务的配置文件存放在/etc/sysconfig目录。现在的配置文件主要存放在/lib/systemd目录，在/etc/systemd目录里面的修改可以覆盖原始设置。

## Target 的配置文件
Target 也有自己的配置文件。

	$ systemctl cat multi-user.target

	# /lib/systemd/system/multi-user.target
	[Unit]
	Description=Multi-User System
	Documentation=man:systemd.special(7)
	Requires=basic.target
	Conflicts=rescue.service rescue.target
	After=basic.target rescue.service rescue.target
	AllowIsolate=yes

注意，Target 配置文件里面没有启动命令。

上面输出结果中，主要字段含义如下。

	Requires字段：要求basic.target一起运行。
	Conflicts字段：冲突字段。如果rescue.service或rescue.target正在运行，multi-user.target就不能运行，反之亦然。
	After：表示multi-user.target在basic.target 、 rescue.service、 rescue.target之后启动，如果它们有启动的话。
	AllowIsolate：允许使用systemctl isolate命令切换到multi-user.target。

# Log 管理
[linux-systemd-journalctl](/p/linux-systemd-log.md)