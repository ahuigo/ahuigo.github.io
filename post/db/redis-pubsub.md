---
layout: page
title:
category: blog
description:
---
# Preface

# pubsub

	redis> subscribe channel1 channel2 channel3
	redis> subscribe channel1 channel2 channel3
	redis> PUBLISH channel1 msg

- 一个client 可以订阅多个channel
- 多个client 可以订阅同一个channel, 也会同时收到消息
- client 收消息是实时的, 消息不会通过队列存储。后启动的client 是不能收到之前的消息

# example

	➜ > test cat pub.php
	<?php
	$redis = new Redis();
	$redis->connect('127.0.0.1',6379);
	$channel = $argv[1];  // channel
	$redis->subscribe(array('channel'.$channel), 'callback');
	function callback($instance, $channelName, $message) {
	  echo $channelName, "==>", $message,PHP_EOL;
	}

	➜ > test cat pub.php
	<?php
	$redis = new Redis();
	$redis->connect('127.0.0.1',6379);
	$channel = $argv[1];  // channel
	$msg = $argv[2];     // msg
	$redis->publish('channel'.$channel, $msg);

exec:

	$ php sub.php 1
	$ php sub.php 1
	$ php pub.php 1 msg
