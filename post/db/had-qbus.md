# QBus消息如何入HDFS？
http://chuansong.me/n/867540

# Use QBus in php

  require 'q/php/kafka_client/lib/kafka_client.php';
  $zkCluster = self::CLUSTER; //zookeeper cluster
  $topic = self::TOPIC;
  $consumer = new \Kafka_Consumer($zkCluster, $topic, array($this, 'myfunc'));//回调
