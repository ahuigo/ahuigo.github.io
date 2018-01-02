# mysql

1. 主从复制（Master-Slave）的方式来同步数据，
2. 再通过读写分离（MySQL-Proxy）来提升数据库的并发负载能力
2. 从服务器可作为备份

## 主从复制
场景描述：
主数据库服务器：192.168.10.130
从数据库服务器：192.168.10.131

### 主服务器上进行的操作
授权给从数据库服务器192.168.10.131

  mysql> GRANT REPLICATION SLAVE ON *.* to 'rep1'@'192.168.10.131' identified by 'password';

查询主数据库状态

  Mysql> show master status;
  +------------------+----------+--------------+------------------+
  | File | Position | Binlog_Do_DB | Binlog_Ignore_DB |
  +------------------+----------+--------------+------------------+
  | mysql-bin.000005 | 261 | | |
  +------------------+----------+--------------+------------------+
  记录下 FILE 及 Position 的值，在后面进行从服务器操作的时候需要用到。

### 配置从服务器
修改从服务器的配置文件/opt/mysql/etc/my.cnf

  将 server-id = 1修改为 server-id = 10，并确保这个ID没有被别的MySQL服务所使用。

通过命令行登录管理MySQL从服务器

  /opt/mysql/bin/mysql -uroot -p'new-password'

执行同步SQL语句

  mysql> change master to
  master_host=’192.168.10.130’,
  master_user=’rep1’,
  master_password=’password’,
  master_log_file=’mysql-bin.000005’,
  master_log_pos=261;


正确执行后启动Slave同步进程

  mysql> start slave;


主从同步检查

  mysql> show slave status\G
  ==============================================
  **************** 1. row *******************
  Slave_IO_State:
  Master_Host: 192.168.10.130
  Master_User: rep1
  Master_Port: 3306
  Connect_Retry: 60
  Master_Log_File: mysql-bin.000005
  Read_Master_Log_Pos: 415
  Relay_Log_File: localhost-relay-bin.000008
  Relay_Log_Pos: 561
  Relay_Master_Log_File: mysql-bin.000005
  Slave_IO_Running: YES
  Slave_SQL_Running: YES
  Replicate_Do_DB:
  ……………省略若干……………
  Master_Server_Id: 1
  1 row in set (0.01 sec)
  ==============================================


其中Slave_IO_Running 与 Slave_SQL_Running 的值都必须为YES，才表明状态正常。

如果主服务器已经存在应用数据，则在进行主从复制时，需要做以下处理：

  (1)主数据库进行锁表操作，不让数据再进行写入动作

  mysql> FLUSH TABLES WITH READ LOCK;

  (2)查看主数据库状态

  mysql> show master status;


  (3)记录下 FILE 及 Position 的值。

  将主服务器的数据文件（整个/opt/mysql/data目录）复制到从服务器，建议通过tar

  (4)取消主数据库锁定

  mysql> UNLOCK TABLES;

由此，整个MySQL主从复制的过程就完成了，接下来，我们进行MySQL读写分离的安装与配置。

## MySQL读写分离
> http://m.oschina.net/blog/29671

场景描述：

  数据库Master主服务器：192.168.10.130
  数据库Slave从服务器：192.168.10.131
  MySQL-Proxy调度服务器：192.168.10.132

以下操作，均是在192.168.10.132即MySQL-Proxy调度服务器 上进行的。

### 安装配置MySQL-Proxy

## 主从延迟
实时性要求高的，建议中间层加redis
