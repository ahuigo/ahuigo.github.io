# 主从
参考: http://369369.blog.51cto.com/319630/790921

## 1、主从服务器分别作以下操作：
  1.1、版本一致
  1.2、初始化表，并在后台启动mysql
  1.3、修改root的密码

假如有两个db:

    db1 : 10.10.10.10
    db2 : 11.11.11.11

## 2、修改主服务器master:

   #vi /etc/my.cnf
       [mysqld]
       log-bin=mysql-bin   //[必须]启用二进制日志
       server-id=222      //[必须]服务器唯一ID，默认是1，一般取IP最后一段, 其实是任意取

## 3、修改从服务器slave:
   #vi /etc/my.cnf
       [mysqld]
       log-bin=mysql-bin   //[不是必须]启用二进制日志
       server-id=226      //[必须]服务器唯一ID，默认是1，一般取IP最后一段

## 4、重启两台服务器的mysql
   /etc/init.d/mysql restart

## 5、在主服务器上建立帐户并授权slave:

    master >GRANT REPLICATION SLAVE ON *.* to 'mysync'@'%' identified by 'q123456';
        %表示所有客户端都可以连， 也可以指定ip 比如slave 的ip 11.11.11.11
        *.* 表示所有的db.table

## 6、登录主服务器的mysql，查询master的状态
   mysql>show master status;
   +------------------+----------+--------------+------------------+
   | File             | Position | Binlog_Do_DB | Binlog_Ignore_DB |
   +------------------+----------+--------------+------------------+
   | mysql-bin.000004 |      308 |              |                  |
   +------------------+----------+--------------+------------------+
   1 row in set (0.00 sec)

## 7、配置从服务器Slave：
   mysql>change master to master_host='10.10.10.10',master_user='mysync',master_password='q123456',
         master_log_file='mysql-bin.000004',master_log_pos=308;

   Mysql>start slave;    //启动从服务器复制功能

## 8、检查从服务器复制功能状态：

   mysql> show slave status\G

   *************************** 1. row ***************************

              Slave_IO_State: Waiting for master to send event
              Master_Host: 10.10.10.10  //主服务器地址
              Master_User: mysync   //授权帐户名，尽量避免使用root
              Master_Port: 3306    //数据库端口，部分版本没有此行
              Connect_Retry: 60
              Master_Log_File: mysql-bin.000004
              Read_Master_Log_Pos: 600     //#同步读取二进制日志的位置，大于等于Exec_Master_Log_Pos
              Relay_Log_File: ddte-relay-bin.000003
              Relay_Log_Pos: 251
              Relay_Master_Log_File: mysql-bin.000004
              Slave_IO_Running: Yes    //此状态必须YES
              Slave_SQL_Running: Yes     //此状态必须YES
                    ......

注：Slave_IO及Slave_SQL进程必须正常运行，即YES状态，否则都是错误的状态(如：其中一个NO均属错误)。

以上操作过程，主从服务器配置完成。在master 创建个库, 看看能否同步 过来吧.


## 停机做主从同步
假如有两个db:

    db1 master: 10.10.10.10
    db2 slave: 11.11.11.11

我们想让db1 做Master, db2 做slave.

1. 先查下db1 的状态: 备份+查看状态 应该原子的, 一般要停master 写数据

    mysql -h10.10.10.10 >10.sql
    mysql>show master status\G;
    *************************** 1. row ***************************
      File: mysql-bin.000001    (slave)
      Position: 111   (slave 同步位置)
      Binlog_Do_DB: dbname
      Binlog_Ignore_DB: mysql


然后操作db2 就好了

    mysql -uroot -h11.11.11.11 < 10.sql
    mysql -uroot -h11.11.11.11
    mysql > stop  slave;
    mysql > change master to master_host='10.10.10.10', master_user='root', master_password='root@passwd', master_log_file='mysql-bin.000001', master_log_pos=111;
    mysql > start slave;

查看从库的状态

    mysql>show slave status\G;
    Slave_IO_Running: Yes
    Slave_SQL_Running: Yes
