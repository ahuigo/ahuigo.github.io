---
layout: page
title:	php smarty
category: blog
description:
---
# Preface
在smarty 中, 为了模仿一些语言的语法糖，比如 `date_format:"%H:%M:%S" 与修饰符模仿了shell管道, $arr.key 模仿了其它对象语言的关键字`, 不得不增加一套巨大的编译系统, 产生了如下的缺点：

	效率低: 作为编译型语言效率低是事实:
	扩展性低: 为了判断子模板是否存在，我必须修源码
	语法糖复杂: 学习复杂的smarty,blade 语法. 比如繁琐的foreach 语法
	易用性低：不方便在里面写php(用户组件); 因为smarty 一等，php 是二等公民、js是三等公民、html/css 是四等公民（这种复杂的关系导致编译系统巨大）我不能方便写
	不支持继承

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

# extends

	# layout.tpl
	{block name=head}default{/block}

	# main.tpl
	{extends file='layout.tpl'}
	{block name=head}
	  <link href="/css/mypage.css" rel="stylesheet" type="text/css"/>
	  <script src="/js/mypage.js"></script>
	{/block}

# use

	$smarty->setTemplateDir('./templates')
		   ->setCompileDir('./templates_c')
		   ->setCacheDir('./cache');
	$smarty -> auto_literal = false;
	$smarty -> left_delimiter = "{{";
	$smarty -> right_delimiter = "}}";

# foreach

	{if ! isset($var)} {/if}
	{foreach $columns as $k=>$v}
		$('<td>').text(item.{$k}){if ! $v@last},{/if}
	{/foreach}

# display

# var

## assign var

	{assign "i" "0"}
	{assign "i" $i+1}
	{assign var=running_total value=$running_total+$some_array[$row].some_value}

	{assign var="var" value="$Name suffix"}

	 $_smarty_tpl->tpl_vars["var"] = new Smarty_variable(((string)$_smarty_tpl->tpl_vars['Name']->value . " suffix"), null, 0);?>
	<?php echo $_smarty_tpl->tpl_vars['var']->value;?>

	{assign var="alias" value=$arr}

# include

	{include file="header.tpl" title=foo var=hilojack}
	echo $_smarty_tpl->getSubTemplate ("header.tpl", $_smarty_tpl->cache_id, $_smarty_tpl->compile_id, 9999, null,
		array('title'=>'foo','var'=>'hilojack'), 0);

其中title var 是assign 变量名

	echo $_smarty_tpl->tpl_vars['varname']->value;?>

## include hook

	Smarty_Internal_Compile_Include:: in lib/smarty/sysplugins/smarty_internal_compile_include.php
		compile()
			$hook_code = Smarty_Include_Compile_hook($include_file);

Example in `smarty.func.php`

	function Smarty_Include_Compile_hook($include_file_name){
		$out = '';
		if($include_file_name === 'xxx'){
			$out = 'xxx';
		}
		return $out;
	}

## output

	__construct
	//添加换行过滤
	$view->registerFilter('smartyTrim');

# Plugin

## Plugin Function

	$smarty->registerPlugin(Smarty::PLUGIN_FUNCTION, 'keepParams', [$className, 'smartyKeepParams']);
	{keepParams var1=val1 var2="val2"}

compile:

	smarty/sysplugins/smarty_internal_register.php
	function registerPlugin($type, $tag, $callback, $cacheable = true, $cache_attr = null){
		if (!isset($this->smarty->registered_plugins[$type][$tag])) {
       		$this->smarty->registered_plugins[$type][$tag] = array($callback, (bool) $cacheable, (array) $cache_attr);
		}
	}

compile_c:

	echo $className::smartyKeepParams(['var1'=>val1, 'var2'=>val2]);

## modifier and function modifier
Define plugin modifier in `libs/plugins`

	libs/plugins/modifier.date_format.php

Use

	{$smarty.now|date_format:"%Y-%m-%d %H:%M:%S"|func:"hilo_params": "val2"}

Compile

	echo func(smarty_modifier_date_format(time(),"%Y-%m-%d %H:%M:%S"),"hilo_params", "val2", $_smarty_tpl);?>

### register plugin

	//./smarty/sysplugins/smarty_internal_compile_private_registered_function.php
	$smarty->registerPlugin(Smarty::PLUGIN_MODIFIER, 'func', $callback = [$className, 'func']);

compile code

	if (!is_array($function)) {
		$output = "<?php echo {$function}({$_params},\$_smarty_tpl);?>\n";
	} else if (is_object($function[0])) {
		$output = "<?php echo \$_smarty_tpl->smarty->registered_plugins[Smarty::PLUGIN_FUNCTION]['{$tag}'][0][0]->{$function[1]}({$_params},\$_smarty_tpl);?>\n";
	} else {
		$output = "<?php echo {$function[0]}::{$function[1]}({$_params},\$_smarty_tpl);?>\n";
	}


# Class methods

## config_load

data

	//my.conf
	#default
	[local]
	var2 = 2
	[foobar]
	var = 1

Assign file

	// load config variables and assign them
	$smarty->config_load('my.conf');

	// load a section
	$smarty->config_load('my.conf', 'foobar');
	{config_load file="test.conf" section="foobar"}

Use data

	{#var1#}{#var2#}

Compile_c

	$_config = new Smarty_Internal_Config("test.conf", $_smarty_tpl->smarty, $_smarty_tpl);
	$_config->loadConfigVars("foobar", 'local'); ?>
	echo $_smarty_tpl->getConfigVariable('var1');
	echo $_smarty_tpl->getConfigVariable('var2');

# parser
https://github.com/smarty-php/smarty-lexer
