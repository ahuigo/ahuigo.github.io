---
layout: page
title:
category: blog
description:
---
# Preface
不是一个包管理器, 而是一个依赖管理器.
尽管它处理的是包库(packages and libraries), 但是这些是基于Project(安装到vendor) 的，因为它默认不是全局安装的. 如果你愿意, 也可以使用global 全局安装。

它主要用于：

1. 项目要使用大量的库
1. 这些库又依赖其它的库, 而且你想定义依赖关系

# install composer

	curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer

	brew install composer

	# or
	rm -rf ~/.composer /usr/local/bin/composer
	#wget https://getcomposer.org/composer.phar -O  /usr/local/bin/composer
	wget http://packagist.cn/composer/composer.phar -O  /usr/local/bin/composer
	#composer config -g repositories.packagist composer http://packagist.phpcomposer.com
	sudo chmod a+x /usr/local/bin/composer

升级composer 本身(它会将老的composer 备份到~/.composer)：

	composer self-update

## Create Project

	composer create-project laravel/laravel learnlaravel5 5.0.22

## pkg source in China
http://pkg.phpcomposer.com/
http://packagist.cn/

# composer.json
内容解释：

	config 用于指定vendor 目录等
	require 用于指定依赖
	name
	autoload 用于自动加载类
	script
		批定install/update 时需要执行的脚本

## composer install

    composer update --no-dev
    composer install --no-dev

## https
global file `config.json`

    $ cat ~/.composer/config.json
    {
        "config": {
            "secure-http":false
        },
        "repositories": {
            "packagist": {
                "type": "composer",
                "url": "http://packagist.phpcomposer.com"
            }
        }
    }


## 为项目安装依赖
进入项目的根目录后, 可以直接编辑composer 的依赖文件`composer.json`, 也可通过命令行`composer init` 引导你配置依赖

直接在命令行添加包规则到`composer.json`, 并安装包 `vendors/monolog/monolog:`

	composer require <usernam>/<pkg_name>:"version_wildcard"
	composer require monolog/monolog:"1.0.*"

	# Platform packages
	# show local avaliable platform packages
	composer show --platform
	composer search ext-
	# 只检查 不安装
	composer install ext-gd

关于version: `~1.2` 相当于 `>=1.2,<2.0` `1.*` 相当于`>=1.0, <2.0`. 示例中的monolog 位于[](https://packagist.org/packages/monolog/monolog)

或者通过以下`composer install` 会下载依赖到`./vendors/monolog/monolog`, 它会读取`composer.lock`, 如果没有，就读取`composer.json`

	composer install

> 第一次执行`install`/`update` 时，它会在项目根目录创建一个`composer.lock`, 它存储了每个安装包的版本信息, 通过这个lock 文件确保大家的依赖包是一致的. 而`composer require` 却不会。

可以通过以下命令升级依赖包的版本(忽略`composer.lock`)

	composer update

可以通过global 做系统级的安装，请将 PATH 设置到 `~/.composer/vendor/bin/`

	composer global require "phpunit/phpunit=4.5.*"
		~/.composer/vendor/bin

# 自动加载
PHP官方社区创建了PSR-0标准。Composer里面自带PSR-0自动加载机制，在项目里面加入下面一行代码：

	include_once './vendor/autoload.php';
	实际加载的是:
		./vendor/composer/autoload_real.php: ComposerAutoloaderInit88319fb295ad94fa91688abe3d00d933

> 其实自带的 spl_autoload_register(array('Doctrine', 'autoload')); 就足够

它分为:

	autoload_namespaces.php
	autoload_psr4.php
	autoload_classmap.php
	autoload_files.php(load at begin)

## 添加PSR4

	$loader->addPsr4('Mail\\', LIB . 'Mail/Mail/');

## autoload_namespaces
psr0

	$map = require __DIR__ . '/autoload_namespaces.php';
	foreach ($map as $namespace => $path) {
		$loader->set($namespace, $path);
	}

Example:

	'Symfony\\Component\\VarDumper\\' => array($vendorDir . '/symfony/var-dumper'),
	Symfony\Component\VarDumper\Dumper\A ->
		vendor/symfony/var-dumper/	Symfony/Component/VarDumper/Dumper/A.php

	$classMap = require __DIR__ . '/autoload_classmap.php';
	if ($classMap) {
		$loader->addClassMap($classMap);
	}

## autoload_psr4.php

    League\Flysystem => $vendorDir . '/league/flysystem/src',

## autoload_classmap.php
map class to file:

	'PHPUnit_Exception' => $vendorDir . '/phpunit/phpunit/src/Exception.php'
