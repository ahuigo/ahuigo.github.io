---
layout: page
title:
category: blog
description:
---
# Preface

Thrift 与http 相比，有几个优点, 而不是速度的。

1. thrift生成的客户端和服务器代码完全包括要传递的数据结构.所以你不必编写客户端server 代码: 包括参数和返回都会自动验证并进行解析。
2. thrift比http更紧凑(没有head头),而且很容易被扩展为支持加密，压缩.非阻塞IO ,etc 。
3. thrift可以将其设置为使用http和JSon很容易。 (如果客户端需要通过防火墙或者不稳定的网络环境)
4. thrift支持持久连接， 避免了连续的TCP(http1.1/http2.0 也支持，不过受客户端限制)



# thrift
thrift 与protobuf 相比，不仅包括二进制数据格式部分，还包括网络部分: RPC、RMI、COM 等远程对象调用或远程方法调用。
Protobuf 自身不带RPC 框架，需要第三方的RPC 框架支持(最近google 出了gRPC 框架)。

> thrift 比protobuf 重，文档也没有protobuf 丰富，个人倾向于protobuf.

> google 开源了gRPC 框架，基于protobuf 数据打包协议和HTTP/2 协议. 提供了PHP/JAVA/PYTHON/GO 等多种实现

## install thrift

	brew install thrift
	git clone https://github.com/walkor/workerman-thrift

## 生成client
1. 写thrift

	thrift -gen php:server punish.thrift
	cat punish.thrift
		namespace php A.B.C

	autoload: Thrift
		spl_autoload_register(function($class){
            if(strpos($class, 'Thrift') === 0){
                $file = str_replace('\\', '/', $class);
                require dirname(__DIR__)."/{$file}.php";
            }
        });

2. copy 组件

	cp -r ./gen-php/Services/HelloWorld /yourdir/workerman/applications/ThriftRpc/Services/

3. handler 组件
在`Applications/ThriftRpc/Services/HelloWorld/`目录下创建 `HelloWorldHandler.php`如下

	<?php
	// 统一使用Services\服务名 做为命名空间
	namespace Services\HelloWorld;

	class HelloWorldHandler implements HelloWorldIf {
	  public function sayHello($name)
	  {
		  return "Hello $name";
	  }
	}

4. 初始化

在Applications/ThriftRpc/start.php 中初始化服务，包括进端口和程数

	require_once __DIR__ . '/ThriftWorker.php';

	// helloworld
	$hello_worker = new ThriftWorker('tcp://0.0.0.0:9090');
	$hello_worker->count = 16;
	$hello_worker->class = 'HelloWorld';

	// another worker

5. client

	// 引入客户端文件
    require_once 'applications/ThriftRpc/Clients/ThriftClient.php';
    use ThriftClient\ThriftClient;

    // 传入配置，一般在某统一入口文件中调用一次该配置接口即可
    ThriftClient::config(array(
		 'HelloWorld' => array(
		   'addresses' => array(
			   '127.0.0.1:9090',
			   //'127.0.0.2:9191',
			 ),
			 'thrift_protocol' => 'TBinaryProtocol',//不配置默认是TBinaryProtocol，对应服务端HelloWorld.conf配置中的thrift_protocol
			 'thrift_transport' => 'TBufferedTransport',//不配置默认是TBufferedTransport，对应服务端HelloWorld.conf配置中的thrift_transport
		   ),
		   'UserInfo' => array(
			 'addresses' => array(
			   '127.0.0.1:9393'
			 ),
		   ),
		 )
	   );

    // 初始化一个HelloWorld的实例
    $client = ThriftClient::instance('HelloWorld');

    // --------同步调用实例----------
    var_export($client->sayHello("TOM"));

# php thrift
autoload thrift

		spl_autoload_register(function($class){
            if(strpos($class, 'Thrift') === 0){
                $file = str_replace('\\', '/', $class);
                require dirname(__DIR__)."/{$file}.php";
            }
        });

use

        $socket = new Thrift\Transport\TSocket ($host, $port);
        $transport = new Thrift\Transport\TBufferedTransport ($socket);
        $protocol = new Thrift\Protocol\TBinaryProtocol($transport);

        // Create a  client
        $client = new NotifyCenterClient($protocol);
        $transport->open();

        $ret = $client->send_message($msg);
        $transport->close();
