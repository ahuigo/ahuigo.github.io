---
title: nginx http
date: 2018-10-04
---
# header

## add_header

	add_header Access-Control-Allow-Origin *
	context: server, location

# keepalive
给客户端分配超时时间
context: http, server, location

	keepalive_disable msie6;//default: msie6, some browser don't support http1.1

	# timeout
	keepalive_timeout 75s;
	keepalive_timeout 0;//keepalive_disable all

	# reset timeout(FIN_WAIT1)
	reset_timedout_connection on;
		# avoid keeping an already closed socket with filled buffers in a FIN_WAIT1 state for a long time.

	# requests
	keepalive_requests 100; # the maximum number of requests for a keep-alive connection
