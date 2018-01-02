# install kafka

  wget http://kafka.apache.org/downloads.html下载相应的版本，我使用的是kafka_2.9.1-0.8.2.2.tgz。
  unpack to /usr/local/kafka/kafka_2.9.1-0.8.2.2

  #启动Zookeeper server
  [root@localhost kafka_2.9.1-0.8.2.2]# sh bin/zookeeper-server-start.sh config/zookeeper.properties &

  #启动Kafka server
  sh bin/kafka-server-start.sh config/server.properties &

  #运行生产者producer
  sh bin/kafka-console-producer.sh --broker-list localhost:9092 --topic test

  #运行消费者consumer
  sh bin/kafka-console-consumer.sh --zookeeper localhost:2181 --topic test --from-beginning

  这样，在producer那边输入内容，consumer马上就能接收到。

当有跨机的producer或consumer连接时

  需要配置config/server.properties的host.name，要不然跨机的连不上。

# php go client
reference: http://www.cnblogs.com/imarno/p/5198940.html

## install libzookeeper

	cd
	wget http://mirror.bit.edu.cn/apache/zookeeper/zookeeper-3.4.8/zookeeper-3.4.8.tar.gz -O - | tar xzvf -
	cd zookeeper-3.4.8/src/c
	./configure && make && sudo make install
	cd

## install php-zookeeper

	cd ~
	git clone https://github.com/andreiz/php-zookeeper
	cd php-zookeeper
	phpize && ./configure && make && sudo make install
	echo 'extension=zookeeper.so' | sudo tee -a /etc/php.d/zookeeper.ini

## install librdkafka

	git clone https://github.com/edenhill/librdkafka/
	cd librdkafka
	./configure
	make
	sudo make install
	echo '/usr/local/lib/'| sudo tee -a /etc/ld.so.conf.d/usrlib.conf
	sudo ldconfig -v

## install php rdkafka

	git clone https://github.com/arnaud-lb/php-rdkafka.git
	cd php-rdkafka
	phpize
	./configure
	make
	sudo make install
	echo 'extension=rdkafka.so' | sudo tee -a /etc/php.d/rdkafka.ini

### usage : https://github.com/arnaud-lb/php-rdkafka

# todo
使用zookeeper获取brokers的信息
http://blog.csdn.net/csfreebird/article/details/51295550
