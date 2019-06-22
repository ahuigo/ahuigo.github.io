---
title: deny ngx_http_access_module
date: 2018-10-04
---
### deny ngx_http_access_module
Allows/Deny access for the specified network or address. If the special value unix: is specified (1.5.1), allows/drops access for all UNIX-domain sockets.

	Syntax:	allow/deny <address> | <CIDR> | unix: | all;
	Context:	http, server, location, limit_except

Example:

	location /.htaccess {
		deny  192.168.1.1;
		allow 192.168.1.0/24;
		allow 10.1.1.0/16;
		allow 2001:0db8::/32;
		deny all;
	}

For proxy `proxy_set_header X-Forwarded-For $remote_addr;`

	set $allow false;
	if ($remote_addr ~ " ?127\.0\.0\.1$") {
	if ($http_x_forwarded_for ~ " ?127\.0\.0\.1$") {
		set $allow true;
	}
	if ($allow = false) {
		return 403;
	}

### location 路由语句块
Sets configuration depending on a `request URI`.

location 是用于路由的. 默认路由 或者location 语句体为空，则直接去读静态资源

Syntax of location：

	Syntax: location [ = | ~ | ~* | ^~ ] uri { ... }
	location { } @ name { ... }
	Context: server / location

	location regExp{ }

Case sensitive for location on MacOSX:

	../configure --with-cc-opt="-D NGX_HAVE_CASELESS_FILESYSTEM=0"

#### 优先级

	~      #波浪线表示执行一个正则匹配，区分大小写
	~*    #表示执行一个正则匹配，不区分大小写
	^~    #^~表示普通字符前缀匹配，相当于没有`^~`
	=     #进行普通字符精确匹配
	@     #"@" 定义一个命名的 location，使用在内部定向时，例如 error_page, try_files

优先级(location 是顺序无关的):

	= 精确匹配会第一个被处理。如果发现精确匹配，nginx停止搜索其他匹配。
	正则表达式(本身按顺序)
	长普通字符匹配
	短普通字符匹配

##### with regular expression
In order to use regular expressions, you must always use a prefix:

	"~"  must be used for case sensitive matching
	"~*" must be used for case insensitive matching

	# 区分大小写
	location ~ "regExp" { }
	# 忽略大小写
	location ~* "regExp" { }

Example:

	location ~ "\.png$" {
		#mathes any query ending with png.
	}

Note: Nginx has the ability to decode URIs in real time. For example, in order to match “/app/%20/images” you may use “/app/ /images” to determine the location.

##### with literal strings
With solid literal strings

	# matches only the "^/literal$" query, "^$" is literal char.
	location = "^/literal$" { }

With temporary literal strings(`^~` 可忽略), 会继续匹配

	# Note: it will continue search next localtion with and this match will be valid only if it there is *no other more characters matches*
	# matches any query that start with "/literal$", note "$" is a literal char.
	location "/literal$" { }

### ngx_http_rewrite_module
directives: break, if, return, rewrite, rewrite_log, set and so on.

#### break
	Syntax:	break;
	Default:	—
	Context:	server, location, if

*Stops* processing the current set of *ngx_http_rewrite_module directives*,

If a directive is specified *inside the location*, further processing of the request *continues* in this location.
Eg:

	if ($slow) {
		limit_rate 10k;
		break;#break No.1
	}
	location ~ / {
		#directives inside location is not influenced by break No.1, but break No.2. ;
		if($http_user_agent ~* chrome){
			break;#break No.2
		}
	}

#### if

	Syntax:	if (condition) { ... }
	Default:	—
	Context:	server, location
	Note: There is a space between if and (

If condition is evaluated as true, the *moudle directives* specified *inside the braces* are executed.

Configurations inside the if directives are inherited from the previous configuration level.

A condition may be any of the following:

- a variable name; 	false if the value of a variable is an empty string or “0”;
- -f	checking of a file existence with the “-f” and “!-f” operators;
- -d 	checking of a directory existence with the “-d” and “!-d” operators;
- -e	checking of a file, directory, or symbolic link existence with "-e" or "!-e" operators;
- -x	checking of an excutive file with "-x" or "!-x" operators;
- ~		matching of a variable against a regular expression using the "~"(for case sensitive operation) or "~*" (for case insentitive). ""
		Negative operators "!~" and "!~*" are also avaliable.
		If regular expression inludes the "}" or "{", the whole regular expression should be enclosed in single or double qoutes.
- = 	matching of a variable against a string

Example0 : check variable existence

	if ($dir = false) {
		set $dir "";
	}

Example1:

	if ($request_method = POST) {
		return 405;
	}

Example2:

	if ($fastcgi_script_name !~ ".php$"){
	}

Equal to

	location ~ ".php$"{
	}

> http://wiki.nginx.org/IfIsEvil saied that:  "if" is part of rewrite module which evaluates instructions imperatively. You must use it with fully test, if there are non-rewrite module directives inside "if"

Static Example:


    $request_filename=/Users/hilojack/www/lumen/public/a/robots.txt
	if (-f $request_filename){
		rewrite ^/(.*) /static.php/$1 break;
	}
	location ~ /static.php/(.*){
		rewrite ^/static.php/(.*) /$1 break;
	}

##### Multiple if
Refer: https://gist.github.com/Coopeh/4637216

	set $posting 0; # Make sure to declare it first to stop any warnings

	if ($request_method = POST) { # Check if request method is POST
	  set $posting N; # Initially set the $posting variable as N
	}

	if ($geoip_country_code ~ (BR|CN|KR|RU|UA) ) { # Here we're using the Nginx GeoIP module to block some spammy countries
	  set $posting "${posting}O"; # Set the $posting variable to itself plus the letter O
	}

	if ($posting = NO) { # We're looking if both of the above rules are set to spell NO
	  return 403; # If it is then let's block them!
	}

#### return

	Syntax:	return code [text];
	return code URL;
	return URL;
	Default:	—
	Context:	server, location, if

Stops processing and returns the specified code to a client. The non-standard code 444 closes a connection without sending a response header.

#### rewrite
Matches a `request URI`
如果rewrite 与location 同级，无论rewrite 是否在location 前后，rewrite 都优先执行. location 会对rewrite 后的地址做路由

	Syntax:	rewrite regex replacement [flag];
	Default:	—
	Context:	server, location, if

`rewrite` is used to modify `request URI` which is matched against specified Regular Expression(only the PATH part), it is changed as specified in `replacement` string.

- Old `QUERY_STRING` will be appended with new query in new `request URI`.
- The ` $request_uri REQUEST_URI` self will be keeped unchanged. We generally coustom `SCRIPT_URL` to store old `request_uri`
- While others is changed, such as

	`$fastcgi_script_name`
	`$script_name`
	`$document_uri`
	`$uri`
	`PHP_SELF`

> Many people set `SCRIPT_URL` with new value of `SCRIPT_NAME`
> Like `rewrite`, `try_files` has the same behaves.

    try_files $uri $uri/ /index.php?$query_string;
		先检查$uri 再检查$uri/目录 如果都不存在，则rewrite 到 /index.php?$query_string last; (Notice: internal redirection cycle)

A option 'flag' parameter can be one of:

- `last`
		stops processing the current set `ngx_http_rewrite_module` directives and *restarts*  `all locations matching with the changed URI`
- `break`
		stops processing the current set `ngx_http_rewrite_module` directives as with break directive.

- `redirect`
	returns a temporary redirect with the 302 code; Usually used *if a replacement string does not start with "http://" or "https://"*
- `permanent`
	returns a permanent redirect with the 301 code.

If query URI is '/XX.html',

Example 1: The final URI is '/mac/index.html'

	 location ~ "^/XX" {
		 rewrite "(?i)^/xx" /mac/index.html break;
	 }
	 location ~ "^/mac" {
		 rewrite "(?i)^/mac" /last.html break;
	 }

Example 2: The final URI is 'last.html'


	 location ~ "^/XX" {
		 rewrite "(?i)^/xx" /mac/index.html last;
	 }
	 location ~ "^/mac" {
		 rewrite "(?i)^/mac" /last.html break;
	 }

Example 3: The final URI is 'XX.html' (第一个location 生效, 除非里面有 rewrite last)


	 location ~ "^/XX" {
	 }
	 location ~* "^/XX" {
		 rewrite "(?i)^/XX" /last.html last;
	 }

Example 4: Ignore case

	# rewrite 忽略大小写则需要这么写
	"(?i)^/p/$"

Example 5: Preg and sub pattern 正则与子模式

	rewrite "^/(\w+)/(\w+)$" /$2/$1 last;

Example 6: the last will cause rematch all locations, so you get `final.php` to be excuted.

	 location ~ "^/a.php" {
		rewrite "^/a.php" /final.php break;
		fastcgi_pass   unix:/var/run/fpm.sock;
		fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
		include        fastcgi_params;
	 }
	 location ~* "^/XX" {
		 rewrite "^/XX" /a.php last;
	 }

第二句不可少！！

	rewrite "^/(.*)" /index.php/$1 break;
	fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;# 不能少!!!! 否则是空的200 OK. 不会执行Php


##### 500 Internal Server Error
其中一个原因是location 中的rewrite 路径一样， 在以下配置下，如查访问'/same_path', 就会报500.

因为rewrite last 会重新匹配所有的location，这就导致了`cycle location matching`:

	location / {
		rewrite /(.*) /same_path last;
	}

此时，可以通过rewrite break 避免:

	location / {
		rewrite /(.*) /same_path break;
	}

If a regular expression includes the “}” or “;” characters, the whole expressions should be enclosed in single or double quotes.

#### rewrite_log

	Syntax:	rewrite_log on | off;
	Default:
	rewrite_log off;
	Context:	http, server, location, if

Logging of `ngx_http_rewrite_module` module diretives processing result into the error_log at Notice level.