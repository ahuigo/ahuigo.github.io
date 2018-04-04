---
layout: page
title:	mysql install
category: blog
description:
---
# Preface
mysql安装

# Install
安装后默认的密码帐号为空:
host=kw.get('host', 'localhost'),
port=kw.get('port', 3306),
user=kw.get('user', ''),
password=kw.get('password', ''),

## Via Source

	./configure --prefix=/usr/local/mysql
	make && make install

## Via yum

	yum install mysql-server mysql php-mysql
	yum install mariadb-server mariadb php-mysql

	#Set the MySQL service to start on boot
	chkconfig --levels 235 mysqld on

	#start
	service mysqld start
	systemctl start mariadb
	# systemctl enable mariadb
	# systemctl status mariadb

	# setting the root password, removing anonymous users, and so on.
	mysql_secure_installation
		Set root password? [Y/n] y        [设置root用户密码]
		...
		Remove anonymous users? [Y/n] y            [删除匿名用户]
		...
		Disallow root login remotely? [Y/n] n            [禁止root远程登录]
		...
		Remove test database and access to it? [Y/n] y       [删除test数据库]
		...
		Reload privilege tables now? [Y/n] y        [刷新权限]

	#Log into MySQL
	mysql -u root
		#Set the root user password for all local domains
		SET PASSWORD FOR 'root'@'localhost' = PASSWORD('new-password');
		SET PASSWORD FOR 'root'@'localhost.localdomain' = PASSWORD('new-password');
		SET PASSWORD FOR 'root'@'127.0.0.1' = PASSWORD('new-password');
		#Drop the Any user
		DROP USER ''@'localhost';
		DROP USER ''@'localhost.localdomain';

	# 设置远程登录
	GRANT ALL PRIVILEGES ON *.* TO 'root'@'%'IDENTIFIED BY '123456' WITH GRANT OPTION;
	FLUSH PRIVILEGES ;


### step by step

## via brew
在mac中安装 mysql

	$ brew install mysql

## mycli
> http://mycli.net/install

	brew install mycli

for centos

	sudo yum install python-pip
	pip3 install mycli
	#sudo easy_install mycli

# Config

## Securing your MySQL installation
It is always recommended to secure your MySQL installation. To do this, type the following on your Terminal:

	$ mysql_secure_installation
	Set root password? [Y/n] Y
	Remove anonymous users? [Y/n] Y
	Disallow root login remotely? [Y/n] Y
	Remove test database and access to it? [Y/n] Y
	Reload privilege tables now? [Y/n] Y

## add user

	mysql> CREATE USER 'monty'@'localhost' IDENTIFIED BY 'passwd';
	mysql> GRANT ALL PRIVILEGES ON database.* TO 'monty'@'localhost' ;
	mysql> GRANT ALL PRIVILEGES ON database.* TO 'monty'@'localhost' WITH GRANT OPTION; # 带grant 权限

For more: http://dev.mysql.com/doc/refman/5.0/en/resetting-permissions.html


## update mysql

	sudo mysql_upgrade -uroot -p

# Reset Passwd

## forget root

### via init sql

	$ sudo service mysqld stop
	$ echo "UPDATE mysql.user SET Password=PASSWORD('123456') WHERE User='root'; FLUSH PRIVILEGES;" > init.sql
	$ mysqld_safe --init-file=init.sql

### via skip grant

	$ mysqld  --skip-grant-tables
	//or
	$ mysqld_safe  --skip-grant-tables
	> UPDATE mysql.user SET Password=PASSWORD('123456') WHERE User='root';
	> FLUSH PRIVILEGES;

## forget user Passwd
If u have root authority

	> SET PASSWORD FOR 'jeffrey'@'localhost' = PASSWORD('cleartext password');
	# current user
	> SET PASSWORD = PASSWORD('cleartext password');

## current user
select current_user();

# Admin

## Common options

	-h host
	--defaults-file=/path_to_my.cnf
	--no-defaults
	--print-defaults

## Start Stop

### On MAC OSX
To have launchd start mysql at login:
```
    ln -sfv /usr/local/opt/mysql/*.plist ~/Library/LaunchAgents
```

Then to load mysql now:

    launchctl load/unload ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist

Or, if you don't want/need launchctl, you can just run:

    mysql.server start/stop

### On Linux

	sudo service mysqld start/stop/restart
	# or
	mysqld_safe --user=mysql &

## mysqld & mysql_safe
mysql_safe is used to manager mysqld , it added some feature:
1. restarting the server when an error occurs 
2. logging runtime information to an error log
3. specify a --mysqld or --mysqld-version option to mysqld_safe

	# view options
	mysqld --verbose --help
	mysqld --verbose --help | grep '^datadir'

	$ mysql -V
	mysql  Ver 15.1 Distrib 10.2.6-MariaDB, for osx10.11 (x86_64) using readline 5.1
	$ mysqld --print-defaults
	mysqld would have been started with the following arguments:

### params

	--safe-updates 防止没有where 的删除

### exec sql batch

	mysqld_safe --init_file=test.sql

	# 不执行没有where 子句的delete/update
	mysqld_safe --safe-update

### default table type
	mysqld_safe --default-table-type=innnodb

### debug

	> [ERROR] Fatal error: Can't open and lock privilege tables: Table 'mysql.host' doesn't exist
	mysql_install_db --user=mysql --datadir=/var/lib/mysql

	> Table 'mysql.plugin' doesn't exist
	mysqld_safe
	mysql_upgrade; # 升级数据库

	> mysql header
	sudo yum install -y mysql-devel

## my.conf

	sudo cp /usr/local/Cellar/mariadb/10.0.10/support-files/my-large.cnf /etc/my.cnf

### scope
包括:

	[client]
	[mysqld]
	[mysqldump]

### Find my.cnf

	mysqld --verbose --help | grep -A 1 "Default options"

### Connect

	# 并发访问最大连接数
	max_connections=151
	#mysql 的每个连接必须由主线程接收并委托给一个新线程处理, back_log 用于确定一个主线程的连接排队数
	back_log=150
	port=3306
	# 禁用dns
	skip_name_resolve
	# 限制为本地连接
	skip_networking

### autocomplete
tab autocomplete

	[mysql]
	auto-rehash

### log
log-slow-queries:

	[mysqld] only
	# 记录非索引查询(expire long_query_time)
	log-slow-queries = /tmp/mysql-slow.log
	log_queries_not_using_indexes=0

for mysql (>=5.6):

	# log slow queries (>long_query_time ) 可以用mysqldumpslow分析此日志
	[mysqld] only
	slow_query_log=1
	slow_query_log_file=/tmp/mysql-slow.log
	long_query_time=2
	log_queries_not_using_indexes = 1

### port

	#default
	[client]
	[mysqld]
	port		= 3306
	socket		= /tmp/mysql.sock

### network

	# fobidden dns (Only ip and locahost are allowed)
	skip_name_resolve
	# Only local app could connect mysqld
	skip_networking

### user

	$ mysqld_safe --user=mysql &

### data dir

	$ mysqld_safe --datadir=/usr/local/var/mysql --user=hilojack

find default datadir:

	$ mysqld --verbose --help |grep datadir

#### innodb datadir

	#default
	innodb_data_home_dir = /usr/local/var/mysql

可用shell 查看:

	mysqld --verbose --help | grep 'innodb-data-home-dir'

## status

### config variables

	//show config variables
	mysqladmin -uroot variables
	mysql> show VARIABLES;
	mysql> show VARIABLES like '%word%';

### server status

	//用`status` 或者 `\s` 获取服务器状态信息: uptime/ssl/socket/charset
	mysql>\s
	mysqladmin status
	// show system detail status
	mysql> show STATUS like '%word%';
	mysqladmin extended-status

### mysqladmin
mysqladmin 功能是mysql 的子集，主要用于完成: 监视服务状态、关闭守护进程

	mysqladmin [options] variables
	mysqladmin [options] status

Refer to `man mysqladmin`

#### flush 刷新

	mysqladmin flush-hosts # 刷新主机缓存，当接收到大量失败连接请求时(由max_connect_errors) 就需要清hosts 以解除对请求的阻塞
	mysqladmin flush-logs #关闭并重新打开所有的日志文件
	mysqladmin flush-status # 刷新状态
	mysqladmin flush-tables # 关闭打开的表
	mysqladmin refresh #flush-tables + flush-logs
	mysqladmin flush-threads # 清楚线程缓存
	mysqladmin flush-privilege #(alias to reload) 重新加载权限表，当使用了GRANT 或 REVOKE 命令就不需要

#### kill

	mysqladmin start-master #启动主服务器
	mysqladmin start-slave #启动从服务器

	mysqladmin kill id1,id2,...,idN #kill mysql进程id1...
	mysqladmin -uroot -p shutdown #关server

#### passwd

	mysqladmin password new-passwd
	/usr/bin/mysqladmin -u root password 'new-password'
	/usr/bin/mysqladmin -u root -h 49846707911b password 'new-password'

#### process

	mysqladmin processlist # 进程列表
	mysqladmin ping # 用ping 验证进程是否运行


## mysqlshow
列出数据库-表-字段:

	mysqlshow [options] [db [table [colume]]]

Example:

	mysqlshow 'test\_name'

## dump & import

	$ mysqldump -hroot -p123 source_db [table] | mysql -uUser -pPasswd dst_db; # 包含数据

### mysqldump
用于导出表结构或者数据. 默认导出的是'*.sql' 格式，输出到标准输出。默认包含 insert 和 create 语句

	mysqldump [opt] database [table] > db.sql
	mysqldump [opt] --databases [options] db1 db2 ...
	mysqldump [opt] --all-databases
		--no-create-info
		-d, --no-data
		--compact
			Produce less verbose output. This option enables the --skip-add-drop-table, --skip-add-locks,
			--skip-comments, --skip-disable-keys, and --skip-set-charset options.
		--add-drop-table
		--tab=backup_path
			Produce tab-separated text-format data files.
		--fields-terminated-by=str
			The string for separating column values (default: tab).
		--fields-enclosed-by=char
			The character within which to enclose column values (default: no character).
		-q quick
			Do not cache each query result

> 一定要加`-q`, 否则会占用大量的swap

Example:

	$ echo 'create database dst_db'| mysql -uUser -pPasswd #if no dst_db
	# or
	$ mysqladmin create dst_db
	$ mysqldump -hroot -p123 source_db | mysql -uUser -pPasswd dst_db; # 包含数据

### mysqlhotcopy
是优化的mysqldump 但只支持本机且只支持MyISAM/Archive. 这个我不用的

	mysqlhotcopy [options] --suffix=.sql db1 db2 ... dbN /backup/
	# 用posix正则匹配db
	mysqlhotcopy [options] db./^preg$/ /backup/

### mysqlimport
导入数据（.csv 数据而非.sql 数据）时，可以通过mysqlimport 为字段做定界:

	mysqlimport [options] --fields-terminated-by=\t dbname file1.txt [... fileN.txt]

Example:
1. First, create the directory for the output files and dump the database:

	shell> mkdir DUMPDIR
	shell> mysqldump --tab=DUMPDIR db_name # it will create *.sql(create tables), and *.txt(tab separator data for each table ) in DUMPDIR

Then transfer the files in the DUMPDIR directory to some corresponding directory on the target machine and load the files into MySQL there:

	shell> mysqladmin create db_name           # create database
	shell> cat DUMPDIR/*.sql | mysql db_name   # create tables in database
	shell> mysqlimport db_name DUMPDIR/*.txt   # load data into tables

## myisamchk
检查表是否有损坏(只能检查MyISAM, 且必須关闭守护进程)：

	myisamchk [options] /path/to/db/table_name.MYI
		--check 简单检查
		--medium-check 中度
		--extend-check 扩展检查
		-i 查看扩展信息
		-r 尝试修复错误

## mysqlcheck
mysqlcheck用于检查所有类型的表, 不需要关闭守护进程:

	mysqlcheck [options] db [table]
	mysqlcheck [options] --databases db1 db2 ... dbN
	mysqlcheck [options] --all-databases
		-a 分析
		-r 修复
		-o 优化
	mysqlcheck -r db table

# mysql client

	mysql -uroot -hhost -pxx database
	echo cmds | mysql
	mysql -e cmd -e cmd

## which database

	//show which database is in use
	SELECT DATABASE();

## exec
mysql client 有自己的interactive cli 模式，这种模式下每条语句以";"结束，也可以标记`\G`, `\H`，或者别名`status` 结束
也有non-active 方式

### exec sql batch
除了Mysql_safe外，mysql 客户端本身也可以批量执行sql命令：

	mysql -uroot < file.sql
	mysql> source < file.sql

	# force to execute sql(ignore error)
	mysql -f < file.sql

### exec cmd

	mysql -uroot -e 'user test; select * from test;'

### auto complete
It support that use ‘tab’ to complete command

	mysql --auto-rehash

## format & shell

	#垂直显示
	mysql> select * form db.tb\G
	mysql --vertical
	#prompt
	mysql -uroot --prompt='\u@\h \d>'
	[mysql]
		prompt=\u@\h \d>
	#html
	mysql --html < a.sql > db.html
	#xml
	mysql -X < a.sql > db.xml

### pager results

	mysql --paper=less; #分页显示程序

在mysql cli中使用pager:

	> pager grep 'pattern';
	> pager less
	> pager cat > /dev/null
	> pager cat > /dev/null
	> pager vim -
	> pager tee -a a.txt

	//close pager
	> nopager

## log cmd

### log results only

    shell> mysql -e 'select * from tb limit 10' > output.txt
    mysql> pager cat - >> output.txt
    mysql> pager tee -a output.txt

The file `output.txt` is stored on server's datadir(On mac OSX: /usr/local/var/mysql/). And it cannot be an existing file

    mysql> select * from db into outfile 'output.txt'

### log stdout

#### log stdout via shell
`\T file.log` 用于记录标准输出（包含命令提示符，命令，结果），`\t` 则结束日志记录

	--tee=file_name
		Append a copy of output to the given file. This option works only in interactive mode.

#### log stdout via mysql command
`\T file.log` 用于记录标准输出（包含命令提示符，命令，结果），`\t` 则结束日志记录

	mysql>\T a.log
	mysql> exec command
	mysql>\t or notee

## FLUSH

	//重新加载权限表
	FLUSH PRIVILEGES; alias to 'reload';
	//刷新连接的主机列表
	FLUSH HOSTS;
	//关闭打开的表，终止对表的查询
	FLUSH TABLES tbl_name [, tbl_name] ...
	// 重置状态变量为0
	FLUSH STATUS
	//Close and reopen all log files;
	flush logs;

## privileges

### Remote Access MySQL

You have to put this as root:

	GRANT ALL PRIVILEGES ON *.* TO  'USERNAME'@'IP'  IDENTIFIED  BY  'PASSWORD';

where IP is the IP you want to allow acess and USERNAME is the user you use to connect.
If you want to allow access from any IP just put `%` instead of your IP .

Then you only have to put

	# 重新加载权限表
	FLUSH PRIVILEGES

Or restart mysql server and that's it

## protocol
	mysql --protocol={TCP|SOCKET|PIPE|MEMORY} (tcp 协议的话需要打开3306端口)

> mysql client will access mysql unix socket via locahost, tcp/ip via 127.0.0.1

## describe

	describe db.table;
	desc db.table;
