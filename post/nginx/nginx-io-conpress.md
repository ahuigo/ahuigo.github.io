# compress

## gzip
context: http,server:
There are many compress algorithm: gzip, deflate, sdch

	gzip on;
	gzip_min_length  1100; # The length is determined only from the “Content-Length” response header field.
	gzip_types	text/plain application/x-javascript application/json text/xml text/css;
	gzip_vary on;		# Enables or disables inserting the “Vary: Accept-Encoding” response header field
	gzip_comp_level  6;# range from 1 to 9, default: 1,  too much compression does not make a substantial difference,

# io

	location /video/ {
		sendfile       on;#default off
		tcp_nopush     on;
			# `tcp_nopush = on` 时执行系统调用 `tcp_cork()` ，结果就是数据包不会马上传送出去，等到数据包最大时，一次性的传输出去，这样有助于解决网络堵塞。
			# tcp_nopush 基本上控制了包的“Nagle化”，Nagle化在这里的含义是采用Nagle算法把较小的包组装为更大的帧。
		tcp_nodelay   on;
			# tcp_nodelay 与nopush 相反，不会同时生效, 仅适合于keepalive
		aio            on; # use of asynchronous file I/O (AIO) on FreeBSD and Linux
	}

## sendfile
传统网络传输过程：

	read(file,tmp_buf, len);
	write(socket,tmp_buf, len);
	硬盘 >> kernel buffer >> user buffer>> kernel socket buffer >>协议栈

用`sendfile()` 来进行网络传输的过程：

	sendfile(socket,file, len);
	硬盘 >> kernel buffer (快速拷贝到kernelsocket buffer) >>协议栈

Refer: http://blog.csdn.net/zmj_88888888/article/details/9169227



## buffers
Sets the number and size of the buffers used for reading a response from a disk.

	Syntax:	output_buffers number size;
	Default:	output_buffers 1 32k;
	Context:	http, server, location

## file cache
*open_file_cache*

	open_file_cache max=1000 inactive=20s;
		# only cache this 1000 of file entries. Old inactive entries are automatically flushed out(>20s)

	open_file_cache_valid 30s;
		# 1. Validity of a cache entry (open_file_cache_valid).
	open_file_cache_min_uses 2;
		# 1. Minimum number of times the cache entry has to be accessed before the inactive number of seconds, so that it stays in cache (open_file_cache_min_uses)
	open_file_cache_errors on;
		#1. Cache errors while searching a file (open_file_cache_errors)

The open file cache is a caching system for metadata operations (file mtime, file existence etc), not for file content

# Reference
- [nginx-performance]: http://www.slashroot.in/nginx-web-server-performance-tuning-how-to-do-it