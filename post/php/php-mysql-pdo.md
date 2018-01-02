---
layout: page
title:
category: blog
description:
---
# Preface

# 连接超时

	$DBH = new PDO(
	    "mysql:host=$host;dbname=$dbname",
	    $username,
	    $password,
	    array(
	        PDO::ATTR_TIMEOUT => "Specify your time here (seconds)",
	        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
	    )
	);

# 读写超时
> 参考：http://blog.yiibook.com/?p=743

需求，一般情况下，php读写mysql时并没有超时设定，仅仅通过php的set_time_limit设置总超时时间，强制停止。

## 超时时
超时时，mysql 的执行会中断. 可以用例程+sleep+update 验证

## via mysqlnd
注意：设置项 `mysqlnd.net_read_timeout` 的级别是PHP_INI_SYSTEM。在php代码中不能修改mysql查询的超时时间。

## mysqli 读写超时
> http://www.laruence.com/2011/04/27/1995.html

mysqli 没有暴露超时的常量，我们需要查看MySQL的代码, 得到MYSQL_OPT_READ_TIMEOUT的实际值, 然后直接调用mysql_options:

	enum mysql_option {
	  MYSQL_OPT_CONNECT_TIMEOUT, MYSQL_OPT_COMPRESS, MYSQL_OPT_NAMED_PIPE,
	  MYSQL_INIT_COMMAND, MYSQL_READ_DEFAULT_FILE, MYSQL_READ_DEFAULT_GROUP,
	  MYSQL_SET_CHARSET_DIR, MYSQL_SET_CHARSET_NAME, MYSQL_OPT_LOCAL_INFILE,
	  MYSQL_OPT_PROTOCOL, MYSQL_SHARED_MEMORY_BASE_NAME, MYSQL_OPT_READ_TIMEOUT,
	  MYSQL_OPT_WRITE_TIMEOUT, MYSQL_OPT_USE_RESULT,
	  MYSQL_OPT_USE_REMOTE_CONNECTION, MYSQL_OPT_USE_EMBEDDED_CONNECTION,
	  MYSQL_OPT_GUESS_CONNECTION, MYSQL_SET_CLIENT_IP, MYSQL_SECURE_AUTH,
	  MYSQL_REPORT_DATA_TRUNCATION, MYSQL_OPT_RECONNECT,
	  MYSQL_OPT_SSL_VERIFY_SERVER_CERT
	};

可以看到, MYSQL_OPT_READ_TIMEOUT为11.  现在, 我们就可以设置查询超时了:

	$mysqli = mysqli_init();
	$mysqli->options(11 /*MYSQL_OPT_READ_TIMEOUT*/, 10);//10*3=30s

因为在libmysql中有重试机制(尝试一次, 重试俩次), 所以, 最终我们设置的超时阈值都会三倍于我们设置的值.

	define('MYSQL_OPT_READ_TIMEOUT',  11);
	define('MYSQL_OPT_WRITE_TIMEOUT', 12);

## 源码修改

	vim ext/pdo_mysql/mysql_driver.c

查找

	#include "zend_exceptions.h"

	改为
	#include "zend_exceptions.h"
	#include "SAPI.h"

查找

	if (driver_options) {
			long connect_timeout = pdo_attr_lval(driver_options, PDO_ATTR_TIMEOUT, 30 TSRMLS_CC);
	改为
	if (driver_options) {
			long connect_timeout = pdo_attr_lval(driver_options, PDO_ATTR_TIMEOUT, 30 TSRMLS_CC);
			//new code
			long write_timeout = pdo_attr_lval(driver_options, PDO_MYSQL_ATTR_WRITE_TIMEOUT, 60 TSRMLS_CC);
			long read_timeout = pdo_attr_lval(driver_options, PDO_MYSQL_ATTR_READ_TIMEOUT, 60 TSRMLS_CC);
			long read_write_timeout_env = pdo_attr_lval(driver_options, PDO_MYSQL_ATTR_RW_TIMEOUT_ENV, PDO_MYSQL_RW_ENV_CLI TSRMLS_CC);
			int enable_read_write_timeout = 0;
			//all env
			if (read_write_timeout_env == PDO_MYSQL_RW_ENV_ALL)  {
					enable_read_write_timeout = 1;
			}
			// web
			else if ( read_write_timeout_env == PDO_MYSQL_RW_ENV_WEB && strcmp(sapi_module.name, "cli") != 0 ) {
					enable_read_write_timeout = 1;
			}
			// cli
			else if ( read_write_timeout_env == PDO_MYSQL_RW_ENV_CLI && strcmp(sapi_module.name, "cli") == 0 ) {
					enable_read_write_timeout = 1;
			}
			else if ( read_write_timeout_env == PDO_MYSQL_RW_ENV_NONE ) {
					enable_read_write_timeout = 0;
			}
查找

	#ifndef PDO_USE_MYSQLND
	        H->max_buffer_size = pdo_attr_lval(driver_options, PDO_MYSQL_ATTR_MAX_BUFFER_SIZE, H->max_buffer_size TSRMLS_CC);
	#endif
	改为
	#ifndef PDO_USE_MYSQLND
	        H->max_buffer_size = pdo_attr_lval(driver_options, PDO_MYSQL_ATTR_MAX_BUFFER_SIZE, H->max_buffer_size TSRMLS_CC);
	        // new code
	        if (enable_read_write_timeout == 1) {
	                if (mysql_options(H->server, MYSQL_OPT_WRITE_TIMEOUT, (const char *)&write_timeout)) {
	                        pdo_mysql_error(dbh);
	                        goto cleanup;
	                }
	                if (mysql_options(H->server, MYSQL_OPT_READ_TIMEOUT, (const char *)&read_timeout)) {
	                        pdo_mysql_error(dbh);
	                        goto cleanup;
	                }
	        }
	#endif
	#if defined(PDO_USE_MYSQLND)
	        if (enable_read_write_timeout == 1) {
	                H->server->data->net->data->options.timeout_read = (uint) read_timeout;
	                H->server->data->net->data->options.timeout_write = (uint) write_timeout;
	        }
	#endif

ext/pdo_mysql/php_pdo_mysql_int.h

查找

	#if MYSQL_VERSION_ID > 50605 || defined(PDO_USE_MYSQLND)
	        PDO_MYSQL_ATTR_SERVER_PUBLIC_KEY
	#endif
	改为
	        PDO_MYSQL_RW_ENV_ALL,
	        PDO_MYSQL_RW_ENV_CLI,
	        PDO_MYSQL_RW_ENV_WEB,
	        PDO_MYSQL_RW_ENV_NONE,
	        PDO_MYSQL_ATTR_RW_TIMEOUT_ENV,
	        PDO_MYSQL_ATTR_WRITE_TIMEOUT,
	        PDO_MYSQL_ATTR_READ_TIMEOUT,
	#if MYSQL_VERSION_ID > 50605 || defined(PDO_USE_MYSQLND)
	        PDO_MYSQL_ATTR_SERVER_PUBLIC_KEY
	#endif

ext/pdo_mysql/pdo_mysql.c

查找

	#if MYSQL_VERSION_ID > 50605 || defined(PDO_USE_MYSQLND)
	        REGISTER_PDO_CLASS_CONST_LONG("MYSQL_ATTR_SERVER_PUBLIC_KEY", (long)PDO_MYSQL_ATTR_SERVER_PUBLIC_KEY);
	#endif
	改为
	        REGISTER_PDO_CLASS_CONST_LONG("MYSQL_RW_ENV_ALL",    (long)PDO_MYSQL_RW_ENV_ALL);
	        REGISTER_PDO_CLASS_CONST_LONG("MYSQL_RW_ENV_CLI",    (long)PDO_MYSQL_RW_ENV_CLI);
	        REGISTER_PDO_CLASS_CONST_LONG("MYSQL_RW_ENV_WEB",    (long)PDO_MYSQL_RW_ENV_WEB);
	        REGISTER_PDO_CLASS_CONST_LONG("MYSQL_RW_ENV_NONE",    (long)PDO_MYSQL_RW_ENV_NONE);
	        REGISTER_PDO_CLASS_CONST_LONG("MYSQL_ATTR_RW_TIMEOUT_ENV", (long)PDO_MYSQL_ATTR_RW_TIMEOUT_ENV);
	        REGISTER_PDO_CLASS_CONST_LONG("MYSQL_ATTR_WRITE_TIMEOUT", (long)PDO_MYSQL_ATTR_WRITE_TIMEOUT);
	        REGISTER_PDO_CLASS_CONST_LONG("MYSQL_ATTR_READ_TIMEOUT", (long)PDO_MYSQL_ATTR_READ_TIMEOUT);
	#if MYSQL_VERSION_ID > 50605 || defined(PDO_USE_MYSQLND)
	        REGISTER_PDO_CLASS_CONST_LONG("MYSQL_ATTR_SERVER_PUBLIC_KEY", (long)PDO_MYSQL_ATTR_SERVER_PUBLIC_KEY);
	#endif

## 编译
编译方式正常，不管是使用mysqlnd还是libmysqlclient方式，都可以。但是两种方式编译后，产生的读写超时，报错信息不一致

libmysqlclient方式会产生

	SQLSTATE[HY000]: General error: 2013 Lost connection to MySQL server during query

mysqlnd

	PDOStatement::execute(): MySQL server has gone away

>因为mysqlnd在设置读写超时时，也是使用了stream_set_timeout，没有mysqlclient的错误信息直观使用

## 使用
通过以上操作，我们新增加了两个pdo的属性，用于动态设置读写超时，单位秒 , 默认60秒

	PDO::MYSQL_ATTR_READ_TIMEOUT
	PDO::MYSQL_ATTR_WRITE_TIMEOUT

另一个属性用来设置开启读写超时的运行环境

	PDO::MYSQL_ATTR_RW_TIMEOUT_ENV

取值范围是

	PDO::MYSQL_RW_ENV_ALL  // 所有环境
	PDO::MYSQL_RW_ENV_CLI  // cli环境
	PDO::MYSQL_RW_ENV_WEB  // web环境，或者说是非cli
	PDO::MYSQL_RW_ENV_NONE //不使用读写超时
	默认是PDO::MYSQL_RW_ENV_CLI, 即仅在cli方式下允许读写超市

请参考以下代码

    'attributes'=>array(
        PDO::MYSQL_ATTR_READ_TIMEOUT=>10,
        PDO::MYSQL_ATTR_WRITE_TIMEOUT=>10,
     )
