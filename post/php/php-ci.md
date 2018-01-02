---
layout: page
title:
category: blog
description:
---
# Preface

CI Framework 改造计划

# autoload

vim src/config/config.php

	/*
	|--------------------------------------------------------------------------
	| Autoload Custom Controllers
	|--------------------------------------------------------------------------
	*/
	function __autoload($class) {
		if (substr($class,0,3) !== 'CI_') {
			if (file_exists($file = APPPATH . 'core/' . $class . EXT)) {
				include $file;
			}
		}
	}

# xss
http://ponderwell.net/2010/08/codeigniter-xss-protection-is-good-but-not-enough-by-itself/

	Input: fdsa” onload=”alert(1);” />, Output: fdsa” onload=”alert(1);” />
	Input: fdsa<script>alert(1)</script>, Output: fdsa[removed]alert(1)[removed]
	Input: fafa<script src=”http://ha.ckers.org/xss.html”>alert(1)</script>, Output: fdsa[removed]alert(1)[removed]
	Input: fdsa<img src=”…” onload=”alert(1);” />, Output: fdsa<img  />

So, from the above tests, we can see that

	(1) CodeIgniter misses Javascript events when not within a HTML tag,
	(2) does not always strip the actual Javascript code, and
	(3) it only strips the attributes from normal HTML tags (i.e. IMG) it finds.
