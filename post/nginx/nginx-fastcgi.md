# fastcgi

	location = / {
		fastcgi_index index.php; # default file for SCRIPT_FILENAME that ends with '/'

		fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;

		fastcgi_param QUERY_STRING    $query_string;
		fastcgi_param REQUEST_METHOD  $request_method;
		fastcgi_param CONTENT_TYPE    $content_type;
		fastcgi_param CONTENT_LENGTH  $content_length;
		include fastcgi_params;

		#fastcgi_pass  localhost:9000;
		fastcgi_pass   unix:/var/run/fpm.sock;//可以在后面, 也可以在前面
	}

## fastcgi_pass

	Context:	location, if in location
	fastcgi_pass localhost:9000;

or as a UNIX-domain socket path:

	fastcgi_pass unix:/tmp/fastcgi.socket;
	fastcgi_param   SCRIPT_FILENAME    "${document_root}/public/index.php";
	include other_fastcgi_params;

## timeout
Context:	http, server, location

	fastcgi_connect_timeout  60s
	fastcgi_response_timeout 60s
	fastcgi_send_timeout 60s;
	fastcgi_read_timeout 60s;

## fastcgi_cache
Defines a shared memory zone used for caching.(这时是cache, 不是缓冲buffering)
1. inherited from parent: http-server-location

	server {
		set $skip_cache 1;
	  if ($request_uri ~* "/wp-admin/") {
		  set $skip_cache 0;
		}
		fastcgi_cache_bypass $skip_cache;
		fastcgi_cache_key $scheme$host$request_uri$request_method;
		fastcgi_cache microcache;
		fastcgi_cache_valid any 8m;
		fastcgi_cache_use_stale updating;
		fastcgi_cache_use_stale updating error timeout invalid_header http_500;

### fastcgi_max_temp_file_size
Buffering of responses from the FastCGI 
1. Context:	http, server, location

	fastcgi_buffering on | off;
	fastcgi_buffers 8 4k|8k;
		# Syntax:	fastcgi_buffers number size;
			# number= numer of memory page
			# size = one memory page(depend on os: either 4K or 8K) 
	fastcgi_buffer_size 4k|8k;
		# override fastcgi_buffers 4k/8k
	fastcgi_max_temp_file_size 1024m; 
		# when whole response does not fit into the buffers set by the fastcgi_buffer_size and fastcgi_buffers directives

### fastcgi params

#### pathino
Context:	location

	location ~ ^(.+\.php)(.*)$ {
		fastcgi_split_path_info       ^(.+\.php)(.*)$;
		fastcgi_param SCRIPT_FILENAME /path/to/php$fastcgi_script_name;
		fastcgi_param PATH_INFO       $fastcgi_path_info;

For the “/show.php/article/0001” request, 
1. the first becomes a value of the `$fastcgi_script_name` variable: “/path/to/php/show.php”
2. the second becomes a value of the `$fastcgi_path_info variable`:  “/article/0001”.

#### fastcgi_param
	fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
	fastcgi_param QUERY_STRING    $query_string;
	fastcgi_param REQUEST_METHOD  $request_method;
	fastcgi_param CONTENT_TYPE    $content_type;
	fastcgi_param CONTENT_LENGTH  $content_length;

	fastcgi_param HTTPS           $https if_not_empty;
		# If a directive is specified with if_not_empty (1.1.11) then such a parameter will not be passed to the server until its value is not empty:

## http

### header
1. By default, nginx does not pass the header fields “Status” and “X-Accel-...” from the response of a FastCGI server to a client. 
2. The `fastcgi_hide_header` directive sets *additional fields* that will not be passed.

	fastcgi_hide_header field;

If, on the contrary, the passing of fields needs to be permitted, the fastcgi_pass_header directive can be used.

	fastcgi_pass_header field

### ignore client abort
when a client closes the connection without waiting for a response: 
1. Determines whether the connection with a FastCGI server should be closed 

	Default:
	fastcgi_ignore_client_abort off;

### keepalive for fastcgi
for keepalive connections to FastCGI servers to function.

	Default:
	fastcgi_keep_conn off;