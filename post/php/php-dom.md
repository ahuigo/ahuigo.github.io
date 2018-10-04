---
layout: page
title: php-dom
category: blog
description: 
date: 2018-10-04
---
# Preface

# php jquery
Operation html string like jquery

https://code.google.com/p/phpquery/

use QL\QueryList;

//采集某页面所有的图片
$data = QueryList::Query('http://cms.querylist.cc/bizhi/453.html',array(
    //采集规则库
    //'规则名' => array('jQuery选择器','要采集的属性'),
    'image' => array('img','src')
    ))->data;
//打印结果
print_r($data);


# tidy

	$str = tidy_parse_string($str, ['indent'=>true, 'wrap'=>0], 'UTF8');
	$str->cleanRepair();
	$str = (string) $str;