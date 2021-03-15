---
title: php coredump
date: 2021-03-13
private: true
---
# php coredump
# PHP Core
http://www.laruence.com/2011/06/23/2057.html
https://rtcamp.com/tutorials/php/core-dump-php5-fpm/

## config
First you need to enable core dumps in linux

	su -
	echo '/tmp/core-%e.%p' > /proc/sys/kernel/core_pattern
	echo 0 > /proc/sys/kernel/core_uses_pid
	ulimit -c unlimited

allown fpm coredump(默认的好像):

	echo 'rlimit_core = unlimited' >> /etc/php-fpm.d/www.conf
	service php-fpm restart

## use core
php 在编译时应该开启debug

先通过php-cli 或者 fpm 产生coredump:

	$ php test.php
	Segmentation fault (core dumped)

调试 php/fpm coredump:

    $ gdb [exec file] [core file]
	$ gdb php core.31656
	$ gdb php-fpm core-fpm.31663

fpm coredump example:

	$ sudo gdb /usr/sbin/php5-fpm /tmp/core-php-fpm.31656
	(gdb) bt
	#0  0x000000000061eea1 in gc_zval_possible_root ()
	#1  0x00000000005f6c1f in zend_cleanup_internal_class_data ()
	#2  0x0000000000605839 in zend_cleanup_internal_classes ()
	#3  0x00000000005f4b0b in shutdown_executor ()
	#4  0x00000000005ffd52 in zend_deactivate ()
	#5  0x00000000005a356c in php_request_shutdown ()
	#6  0x00000000006b1819 in main ()

我们看看, Core发生在PHP的什么函数中, 在PHP中, 对于FCALL_* Opcode的handler来说, execute_data代表了当前函数调用的一个State, 这个State中包含了信息:

	(gdb)f 1
	#1  0x00000000006ea263 in zend_do_fcall_common_helper_SPEC (execute_data=0x7fbf400210) at /home/laruence/package/php-5.2.14/Zend/zend_vm_execute.h:234
	234               zend_execute(EG(active_op_array) TSRMLS_CC);
	(gdb) p execute_data->function_state.function->common->function_name
	$3 = 0x2a95b65a78 "recurse"
	(gdb) p execute_data->function_state.function->op_array->filename
	$4 = 0x2a95b632a0 "/home/laruence/test.php"
	(gdb) p execute_data->function_state.function->op_array->line_start
	$5 = 2

现在我们得到, 在调用的PHP函数是recurse, 这个函数定义在/home/laruence/test.php的第二行