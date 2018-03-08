---
layout: page
title:	linux nginx 配置
category: blog
description:
---
# Preface

# command
Options:
  -?,-h         : this help
  -v            : show version and exit
  -V            : show version and configure options then exit
  -t            : test configuration and exit
  -q            : suppress non-error messages during configuration testing
  -s signal     : send signal to a master process: stop, quit, reopen, reload
  -p prefix     : set prefix path (default: /usr/local/nginx//)
  -c filename   : set configuration file (default: conf/nginx.conf)
  -g directives : set global directives out of configuration file

## check conf
$     nginx -t
nginx: the configuration file /usr/local/nginx//conf/nginx.conf syntax is ok

### include

	include mime.types;
	include vhosts/*.conf;

## conf file 层级
events{}
http{
	server{
	}
}


### user

	Syntax:	user user [group];
