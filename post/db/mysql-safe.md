---
layout: page
title:	mysql safe
category: blog
description:
---
# Preface

# OS Safe

- 及时打OS 和各软件的补丁
- 禁用不使用的service
- 禁用不使用的端口
- 审计用户帐户
- 设置mysql root passwd

passwd

	mysql> set password for root@localhost=PASSWORD('secret')
	mysql> flush privileges;
	"or
	mysqlamdin -uroot password 'secret'

# Mysqld Safe
开启mysqld 的安全选项

	--skip-networking "或者在my.cnf 加[mysqld] skip_networking
	--skip-name-resolve
	--skip-show-database "这样只有拥有show 特定权限的用户才能show databases;
	--local-infile "禁止加载(locad data local infile)服务器端的本地文件
	--safe-user-create
		只有拥有特定权限（对user 表有insert）的用户才能创建权限小于等于自己的用户

# 127.0.0.1 vs localhost
1. locahost or without a host name:a UNIX mysqld uses sockets
2. locahost: tcp socket

# Privileges table 权限表
权限表位于: `mysql` 库
权限系统分为验证和授权

## 验证
使用`mysql.user 表`确定接受或拒绝连接: 用户是否匹配主机(Host)，是否需要安全连接(SSL)，是否密码正确(Password). 以及资源限制(max_connections, max_user_connections, max_updates).

不匹配则拒绝连接

	| User | host           | Insert_priv | ssl_type |
	-------------------------------------------------
	| root | localhost      | Y           |          |
	|      | localhost      | N           |          |

获取当前用户：

	SELECT USER();
	SELECT CURRENT_USER();

User:
不可用通配符，但是可以为空(表示所有用户)

Host:

	localhost
	%.ahuigo.github.io
	192.168.1.10
	192.168.1.10/255.255.255.0

> host 是排序的，msyql 始终会使用最匹配的user@host, 这与匹配先后无关。

## 授权

### user 表
检查user 表给予相应的全局权限

	user:
		select_priv/drop_priv/reload_priv/shutdown_priv/process_priv/grant_priv

如果没有给定的权限就检查db 表

### db 表
检查db 中的：

1. User/Host/Db 匹配：
	如果授予了权限则接受请求，否则检查tables_priv/columns_priv
2. User/Db 匹配,Host 为空
	则检查host 表

> % _ 可用于Host/Db 字段，不能用于User 字段. 这是很合理的事情嘛

### host 表
host 表仅在db 表中Host 为空时使用(它是db 表的扩展，提供多个host). 这个表没有User 字段了, 因为DB 表已经有User了
如果 host 表能找到匹配的Host:
	则用户对host 表指示的数据库有相应的权限(特定的数据库db用特定的host 限制访问)

> host 表与user 表一样，host 是排序的，这样msyql 始终会使用最匹配的host, 这与匹配先后无关。

### tables_priv 表
存储特定用户权限, 仅当user/db/host 三个表不满足用户任务请求时起作用.
tables_priv:

	Table_name/User/Db/Host Table_priv/Column_priv

> 为了提升性能，tables_priv 中也有column_priv, 当这个字段有相应的权限时，才会进一步检查columns_priv 表

### column_priv 表
存储特定用户权限, 仅当user/db/host/column_priv 四个表都不满足用户任务请求时起作用.
Columns_priv:

	Column_name/Table_name/User/Db/Host Column_priv

# Privilegs Command 权限命令
Mysql 3.22.11 以前都是使用Privilegs Table 来管理权限的，但是3.22.11 之后使用的新的方法来管理权限：GRANT/REVOKE 命令，这个命令比直接操作权限表更方便直观 还不易出错。

## User Manager
Mysql 5.0.2 又增加了用户管理的命令`create/drop/rename user`：

### create user

	help create user
	Name: 'CREATE USER'
	Syntax:
	CREATE USER user_specification [, user_specification] ...
		user_specification:
			user
			[
			  | IDENTIFIED WITH auth_plugin [AS 'auth_string']
				IDENTIFIED BY [PASSWORD] 'password'
			]

Example:

	CREATE USER 'hilojack'@'%' IDENTIFIED BY 'mypass';
	CREATE USER 'hilojack' IDENTIFIED BY 'mypass';//host '%' is default
	CREATE USER 'hilojack'@'localhost' IDENTIFIED BY 'mypass';

`identified by 'secret'`, 当`secret` 为空时，不会改变用户密码

### drop user

	drop user 'hilojack'@'%'

> 删除用户user@host 及其`所有的权限`

### rename user

	rename user 'hilojack'@'%', name1 to name2;

### passwd user

	SET PASSWORD [FOR 'jeffrey'@'localhost'] = PASSWORD('cleartext password');

## Grant/Revoke
Grant 和 Revoke 提供对每个用户操作权限的控制。这比直接使用sql 操作mysql 表，然后再`flush privileges`更方便.

	priv_type:
	All PRIVILEGES	影响除With grant option 之外的所有权限
	Alter			影响alter table 权限
	Alter ROUTINE	影响修改删除存储例程的权限
	Create			影响create table 权限
	Create ROUTINE	影响创建存储例程的权限
	Drop			影响 drop table 权限
	Excute			影响执行存储例程的权限
	file			影响select into outfile, load data infile的权限
	select			影响select 的权限

### GRANT
授权

	GRANT priv_type [(column_list)] [, priv_type [(column_list)]] ...
		ON [object_type] priv_level
		TO user_specification [, user_specification] ...
		[REQUIRE {NONE | ssl_option [[AND] ssl_option] ...}]
		[WITH with_option ...]

Example:

	grant ALL PRIVILEGES on *.* TO ''@'localhost' ;

	grant select,update on db_name.* TO 'hilojack'@'%' identified by 'secret';
	grant update(column1,column2) on db_name.table_name TO 'hilojack'@'%';
	grant update on *.* TO 'hilojack'@'localhost' ;


#### limit user
在`identified by 'secret'`中, 当`secret` 为空时，不会改变用户密码

	IDENTIFIED by 'secret';

限制其它资源:

	with max_connections_per_hour 3600;//每个用户每个小时的最大连接数
	with max_updates_per_hour 3600;
	with max_questions_per_hour 3600;
	with max_user_connections 60;//某用户的并行最大连接数

#### with ssl
ssl 开启前需要创建或者购买server/client 证书, 再启用证书

	mysqld_safe
	"--ssl-capath "指定PEM(Privacy-Enhanced Email 私有增强邮件)格式的可信ssl 证书存储目录
	--ssl-ca=/path/cacert.pem "指定Ca证书授权机构列表
	--ssl-cert=/mysql-cert.pem "安全连接的ssl 证书
	"--ssl-cipher=des3:bf "指定加密算法
	--ssl-key=/server.key.pem "指定ssl 密钥


客户端也需要启用ssl 证书

	mysql --ssl-ca=xx --ssl-cert=cret.pem --ssl-key=client.pem

也可以在my.cnf中配置ssl:

	[mysqld]
	ssl-ca = /path/cacert.pem
	ssl-cert = /cert.pem
	ssl-key = /server-key.pem
	[mysql]
	ssl-ca = /path/cacert.pem
	ssl-cert = /cert.pem
	ssl-key = /client-key.pem

##### 通过grant 强制使用ssl

	grant insert on * TO ''@'%' REQUIRE SSL;//强制ssl 连接
	REQUIRE SSL REQUIRE X509;//强制用户提供合法的CA 证书, 这样才是可信用户

强制用户提供合法的由CA发行的证书, 必须包含合法的信息:必须来自于US, 来源洲Ohio, ..., 拥有者名字，域和邮箱。

	REQUIRE SSL REQUIRE ISSUER 'C=US, ST=Ohio,.... , OU=ADMIN, CN=ahuigo.github.io/Email=hilojack@sina.com';

强制用户提供合法的由CA发行的证书, 必须包括合法主题

	REQUIRE SSL REQUIRE SUBJECT 'C=US, ST=Ohio,.... , OU=ADMIN, CN=ahuigo.github.io/Email=hilojack@sina.com';

强制使用特定的算法(EDH,RSA，DES,CBC3,SHA)：

	REQUIRE SSL REQUIRE CIPHER 'DES-RSA';

### REVOKE

	REVOKE
		priv_type [(column_list)]
		  [, priv_type [(column_list)]] ...
		ON [object_type] priv_level
		FROM user [, user] ...

Example:

	REVOKE select,update on db_name.* FROM 'hilojack'@'%'
	REVOKE update(column1,column2) on db_name.table_name FROM 'hilojack'@'%';

Revoke all privileges:

	revoke all privileges on *.* from 'hilojack';//clear db
	DROP USER hilojack@'%';//clear user

> 不能用`*.*` revoke 所有的数据库，必须显式的对每个数据库进行操作?

## show grants

	show grants for user@'localhost'
	show grants for current_user();
