---
layout: page
title: php-session
category: blog
description: 
date: 2018-10-04
---
# Preface

# config

in php.ini

	//path
	session.save_handler=file|mm|sqlite|user
	;seesion 默认位于/tmp 或者 mac的 /var/tmp/sess_*
	session.save_path 

	//start
	session.auto_start = 0|1 ; //session_start()

	//name
	session.name= string; //PHPSESSID

	//use cookies
	session.user_cookies = 1; //default 1,(1: 使用cookie 中的sid,  0, 使用url 中的sid)
	session.use_trans_sid = 0; //1: url 附加SID

	//life
	session.cookie_lifetime = int ;//seconds
	session.gc_maxlifetime = int

	//cache
	session.cache_limiter = string
		None 禁止任何页面缓存控制首部
		Nocache default
		private_no_expire 不向浏览器发送任何文档过期时间, 其它同private
		Private 页面是私有的，禁止代理商缓存
		public 可缓存
	session.cache_expire = int  nocache 时，此条失效

# Session & Cookie
如果一个cookie 的expires 是Session， 那么会话结束时（浏览器关闭），session 就会失效。你可以为其指定expires

## set session_id

	session_start();
	setcookie(session_name(),session_id(),time()+$lifetime);

## delete session

	session_unset();//相当于unset($_SESSION)	Free all session variables
	session_destroy();//相当于rm session_file, 但不会unset($_SESSION)	Destroys all data registered to a session

通常session 存储用`session.save_path` 设定

	session_save_path()
	php -i |grep 'session.save_path'

如果`save_path` 为空，通常存储于:

	/var/tmp/sess_*
	/var/folders/73/*/T/sess_*

## encode session

	$_SESSION['username']='hilojack';
	$sessionStr = session_encode();//username:s:5:"hilojack";
	$_SESSION = session_decode($sessionStr);

## session_id and session_name
在session start 前获取或者生成session name

	string session_name ([ string $name ] );//session.name 配置项。 因此，要想设置会话名称,都需要在 调用 session_start() 或者之前调用 session_name() 函数, 在start 后再设置名字就来不及了

在session_start 后获取或者设置SID:

	string session_id($sid=null);//get/set

重新生成会话SID

	bool session_regenerate_id ([ bool $delete_old_session = false ] )

> 在COOKIE 中得到`$_COOKIE[session_name]=>session_id`：

## example

	session_start();
	setcookie($name = session_name(),$id = session_id(),$time = time()+3600);
	$_SESSION['count'] = isset($_SESSION['count']) ? $_SESSION['count']+1: 1;
	setcookie('c_count', $_COOKIE['c_count']+1);
	var_dump([
		'sess'=>[
			'sess_name'=>$name, 
			'sess_id'=>$id,
			'expire_time'=>$time,
			'count' => $_SESSION['count'],
			'sess_path' => session_save_path(),
		],
		'cookie'=>$_COOKIE,
	]);
	curl -b a.cookie -c a.cookie http://127.0.0.1:8080/a.php


# session handler
Refer to : http://jp2.php.net/manual/zh/function.session-set-save-handler.php

	class MySessionHandler implements SessionHandlerInterface {
		private $savePath;

		public function open($savePath, $sessionName) {
			$this->savePath = $savePath."/$sessionName";
			return true;
		}

		public function read($id) {
			return (string)@file_get_contents("$this->savePath/sess_$id");
		}

		public function write($id, $data) {
			return file_put_contents("$this->savePath/sess_$id", $data) === false ? false : true;
		}

		public function destroy($id) {
			$file = "$this->savePath/sess_$id";
			unlink($file);
			return true;
		}

		public function gc($maxlifetime) {
			foreach (glob("$this->savePath/sess_*") as $file) {
				if (filemtime($file) + $maxlifetime < time() && file_exists($file)) {
					unlink($file);
				}
			}
			return true;
		}
	}
	$handler = new MySessionHandler();
	session_set_save_handler($handler, true);
	session_start();