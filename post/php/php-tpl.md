---
layout: page
title:
category: blog
description:
---
# Preface

除了smarty，可以考虑[php-tpl](/p/php-tpl)

- yaf-simple-view 扩展性和性能都很强，原生的php 语法
- handlebarsjs(还不支持if else)
	http://handlebarsjs.com
	相应的PHP 实现： 通用模板
	https://github.com/zordius/lightncandy
- blade
- 自制tpl render

三者比较：
http://vschart.com/compare/blade-template-engine/vs/smarty-template-engine/vs/handlebars-js

# Write Render

	function render($tpl, $data){
		extract($data);
		include "$tpl";
	}

tpl:

	<?="{$uid}_".trim($uid)?>

## extends

	<!--hello_layout.tpl-->
	<!doctype html>
	<html>
    	<?=View::bufGet('hello')?>
		<body></body>
	</html>


	<!--main.tpl-->
	<?View::bufBegin();?>
		<head></head>
	<?View::bufEnd('head');?>
	<?/*继承父模板 hello_layout.tpl*/?>
	<?=$_view_obj->fetch('layout/hello_layout.tpl');?>
