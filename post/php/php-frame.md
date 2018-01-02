---
layout: page
title:	php kiss
category: blog
description: 
---
# Preface
以前我做了一个关于KISS 的分享，但是太过抽象了。 本文将通过展示具体的问题，来表达我的观点。这些问题包括：

- 接口参数太多
- smarty

# 接口的参数太多怎么办？
我们在定义一个curl 请求方法时，往往会加太多的参数，比如：

	class api{
		function request($url, $method = 'GET', $parameters = [], $multi = false, $useTauthHeader = true, $is_json = false, $curlopt = []) {
			....
		}
	}

后来有人发现还需要加*更多的*参数，于是又定义了一个新的函数

	function request2($url, $method = 'GET', $parameters = [], $multi = false, $useTauthHeader = true, $is_json = false, $paramsCallback = null) {
			....
	}

这样做一点都不KISS, 这会导致产生大量重复的代码！怎么办呢？很多人想到了很多方法，但是大部分方法都将问题复杂化了

## 尽量不要对接口进行再包装
为了在调用request 时传递更多参数, 比如这两参数`skipCheck`, `async`, 又不想修改调用原型，我们可以在Api 之上包装一层ApiProxy:

	class ApiProxy{
		function skipCheck(){
			self::$skipCheck = true;
		}
		function async(){
			self::$async = true;
		}
		function __call($method, $args){
			$res = call_user_func($api, $args)
			$this->_clean();
			return $res;
		}
		function _clean(){
			self::$skipCheck = null;
			self::$async = null;
		}
	}

这样，request 就可以不用支持太多的参数了. 

	$apiProxy->async()->request(...);

可是这存在问题：

1. 对接口不断的包装，会让调用变得更加复杂，还会影响性能. 这是过度设计的一种体现

## 统一销毁参数的方法
加一个统一销毁参数的方法`clean` 不失为一个好方法. 但是根本不需要再包装一层`apiProxy`.

如果api 没有使用单例模式， 我会把`self::$async` 改成`$this->async`. 请求结束后，这个对象以及其内的成员属性`$this->async` 就随着`$api` 被弃用而被释放了

如果api 使用了单例呢？我们可以 将这些在调用后`要销毁的参数` 统一放到一个数组里面. 然后利用`finally` 去统一销毁(限php >= 5.5)

	function request(....){
		list($async, $skipCheck) = $this->_requestConfig;
		try{
			//do request here	
			return $res;
		}finally{
			$this->clearRequestConfig();
		}
	}
	protected function chearRequestConfig{
		$this->_requestConfig = ['async'=> false, 'skipCheck'=> false];
	}

# 应该使用smarty 吗？
