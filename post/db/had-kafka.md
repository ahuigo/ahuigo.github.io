# Debug
ZookeeperConsumerConnector can create message streams at most once

    consumerConnector = kafka.consumer.Consumer.createJavaConsumerConnector(config);
    consumerConnector.createMessageStreams(topicCountMap, keyDecoder, valueDecoder);// 调用多次

会出现

    kafka.common.MessageStreamsExistException: ZookeeperConsumerConnector can create message streams at most once

# Kafka 介绍
Kafka是一种分布式，基于发布/订阅的消息系统。

## todo
Kafka设计解析（二）- Kafka High Availability （上）
http://www.jasongj.com/2015/04/24/KafkaColumn2/

## 为何使用消息系统

1. 为程序或组件提供异步的通信机制
3. 解耦: 消息队列、发送者、接收者
  1. 发送者和接收者不必同时在线
  2. 发送接收不必了解对方
4. 冗余: 删除消息时，需要确认该消息已经被处理；
5. 扩展性: 消息队列解耦了处理过程, 所以增大消息入队和处理的频率是很容易的，只要另外增加处理过程即可。
6. 可恢复性: 数据持久化是可恢复的，只有当消息被完全处理才删除数据
7. 顺序保证: Kafka保证一个Partition内的消息的有序性, 且同一条消息只能被 Consumer Group 中某一个Consumer 消费

两种模型：

1. 点对点：Point to Point
2. 订阅：Publish/Subscribe


# 常用Message Queue对比
> http://queues.io/

## RabbitMQ
Language: Erlang
Protocol: AMQP，XMPP, SMTP, STOMP, 所以非常重量级
同时实现了Broker构架，这意味着消息在发送给客户端时先在中心队列排队。对路由，负载均衡或者数据持久化都有很好的支持。

## Redis
它本身支持MQ功能，所以完全可以当做一个轻量级的队列服务来使用。
对于RabbitMQ和Redis的入队和出队操作, 实验表明：

  入队时，当数据比较小时Redis的性能要高于RabbitMQ，而如果数据大小超过了10K，Redis则慢的无法忍受；
  出队时，无论数据大小，Redis都表现出非常好的性能，而RabbitMQ的出队性能则远低于Redis。

## ZeroMQ
1. ZeroMQ号称`最快的消息队列系统`，尤其针对大吞吐量的需求场景。
2. ZeroMQ仅提供非持久性的队列，也就是说如果宕机，数据将会丢失。
2. ZeroMQ能够实现RabbitMQ不擅长的高级/复杂的队列，但是开发人员需要自己组合多种技术框架，技术上的复杂度是对这MQ能够应用成功的挑战。
3. ZeroMQ具有一个独特的非中间件的模式，你不需要安装和运行一个消息服务器或中间件，因为你的应用程序将扮演这个服务器角色。

> Twitter的Storm 0.9.0以前的版本中默认使用ZeroMQ作为数据流的传输（Storm从0.9版本开始同时支持ZeroMQ和Netty作为传输模块）。

## ActiveMQ
ActiveMQ是Apache下的一个子项目。 类似于ZeroMQ，它能够以代理人和点对点的技术实现队列。同时类似于RabbitMQ，它少量代码就可以高效地实现高级应用场景。

## Kafka/Jafka
Kafka是Apache下的一个子项目，是一个高性能跨语言分布式发布/订阅消息队列系统，
而Jafka是在Kafka之上孵化而来的，即Kafka的一个升级版。具有以下特性：

1. 快速持久化，可以在O(1)的系统开销下进行消息持久化；
2. 高吞吐，在一台普通的服务器上既可以达到10W/s的吞吐速率；
3. 完全的分布式系统，Broker、Producer、Consumer都原生自动支持分布式，自动实现负载均衡；
6. Apache Kafka相对于ActiveMQ是一个非常轻量级的消息系统，除了性能非常好之外，还是一个工作良好的分布式系统。
3. 支持Kafka Server间的`消息分区`，及`分布式消费`，同时保证每个Partition内的`消息顺序传输`。
4. 同时支持离线数据处理和实时数据处理:
  Kafka通过支持Hadoop的并行加载机制统一了在线和离线的消息处理。
  对于像Hadoop的一样的日志数据和离线分析系统，但又要求实时处理的限制，这是一个可行的解决方案。
5. Scale out：支持在线水平扩展

# Kafka架构

## Terminology

  Broker
  Kafka集群包含一个或多个服务器，这种服务器被称为broker

  Topic
  每条发布到Kafka集群的消息都有一个类别，这个类别被称为Topic。
  物理上不同Topic的消息分开存储，逻辑上一个Topic的消息虽然保存于一个或多个broker上但用户只需指定消息的Topic即可生产或消费数据而不必关心数据存于何处）

  Partition
  Parition是物理上的概念，每个Topic包含一个或多个Partition.

  Producer
  负责发布消息到Kafka broker

  Consumer
  消息消费者，向Kafka broker读取消息的客户端。

  Consumer Group
  每个Consumer属于一个特定的Consumer Group（可为每个Consumer指定group name，若不指定group name则属于默认的group）。

## Kafka拓扑结构
![had-kafka-1.png](/img/had-kafka-1.png)

一个典型的Kafka集群中包含:

1. 若干Producer（可以是web前端产生的Page View，或者是服务器日志，系统CPU、Memory等），
2. 若干broker（Kafka支持水平扩展，一般broker数量越多，集群吞吐率越高），
3. 若干Consumer Group，
4. 以及一个Zookeeper集群。

Kafka通过Zookeeper管理集群配置，选举broker leader，以及在Consumer Group发生变化时进行rebalance。
Producer使用push模式将消息发布到broker，Consumer使用pull模式从broker订阅并消费消息。

## Topic & Partition
Topic在逻辑上可以被认为是一个queue，每条消费都必须指定它的Topic，可以简单理解为必须指明把这条消息放进哪个queue里。
为了使得Kafka的吞吐率可以线性提高，物理上把Topic分成一个或多个Partition，每个Partition在物理上对应一个文件夹，该文件夹下存储这个Partition的所有消息和索引文件。

若创建topic1和topic2两个topic，且分别有13个和19个分区，则整个集群上会相应会生成共32个文件夹（本文所用集群共8个节点，此处topic1和topic2 replication-factor均为1），如下图所示。
![had-kafka-2.png](/img/had-kafka-2.png)

每个日志文件都是一个log entrie序列，每个log entrie包含一个4字节整型数值（值为N+5），1个字节的"magic value"，4个字节的CRC校验码，其后跟N个字节的消息体。每条消息都有一个当前Partition下唯一的64字节的offset，它指明了这条消息的起始位置。磁盘上存储的消息格式如下：

  message length ： 4 bytes (value: 1+4+n)
  "magic" value ： 1 byte
  crc ： 4 bytes
  payload ： n bytes

这个log entries并非由一个文件构成，而是分成多个segment files，每个segment以该segment第一条消息的offset命名并以“.kafka”为后缀。
另外会有一个索引文件(Active Segment List)，它标明了每个segment下包含的log entry的offset范围，如下图所示。

![had-kafka-3.png](/img/had-kafka-3.png)

因为每条消息都被append到该Partition中，属于顺序写磁盘，因此效率非常高（经验证，顺序写磁盘效率比随机写内存还要高，这是Kafka高吞吐率的一个很重要的保证）

![had-kafka-4.png](/img/had-kafka-4.png)

## 清理
对于传统的message queue而言，一般会删除已经被消费的消息，而Kafka集群会保留所有的消息，无论其被消费与否。
当然，因为磁盘限制，不可能永久保留所有数据（实际上也没必要），因此Kafka提供两种策略删除旧数据。

1. 一是基于时间，
2. 二是基于Partition文件大小。

例如可以通过配置$KAFKA_HOME/config/server.properties，让Kafka删除一周前的数据，也可在Partition文件超过1GB时删除旧数据，配置如下所示。

  # The minimum age of a log file to be eligible for deletion
  log.retention.hours=168
  # The maximum size of a log segment file. When this size is reached a new log segment will be created.
  log.segment.bytes=1073741824
  # The interval at which log segments are checked to see if they can be deleted according to the retention policies
  log.retention.check.interval.ms=300000
  # If log.cleaner.enable=true is set the cleaner will be enabled and individual logs can then be marked for log compaction.
  log.cleaner.enable=false

要注意，因为Kafka读取特定消息的时间复杂度为O(1)，即与文件大小无关，所以这里删除过期文件与提高Kafka性能无关。
选择怎样的删除策略只与磁盘以及具体的需求有关。

### 消费
另外，Kafka会为每一个Consumer Group保留一些metadata信息: 当前消费的消息的position，也即: offset。 这个offset由Consumer控制。
正常情况下Consumer会在消费完一条消息后递增该offset。当然，Consumer也可将offset设成一个较小的值，重新消费一些消息。
因为offet由Consumer控制，所以Kafka broker是无状态的，它不需要标记哪些消息被哪些消费过，也不需要通过broker去保证同一个Consumer Group只有一个Consumer能消费某一条消息，因此也就不需要锁机制，这也为Kafka的高吞吐率提供了有力保障。

## Producer消息路由
> 如果一个Topic对应一个文件，那这个文件所在的机器I/O将会成为这个Topic的性能瓶颈，而有了Partition后，就可以并行写入不同broker的不同Partition

Producer发送消息到broker时，会根据Paritition机制选择将其存储到哪一个Partition( 需要考虑负载均衡。)

分区数: 可以在$KAFKA_HOME/config/server.properties中通过配置项:

  # 指定新建Topic的默认Partition数量，也可在创建Topic时通过参数指定，同时也可以在Topic创建之后通过Kafka提供的工具修改。
  num.partitions

在发送一条消息时:

1. 可以指定这条消息的key，Producer根据这个key和Partition机制来判断应该将这条消息发送到哪个Parition。
2. Paritition机制可以通过指定Producer的`paritition.class`这一参数来指定，该class必须实现`kafka.producer.Partitioner`接口。

本例中如果key可以被解析为整数则将对应的整数与Partition总数取余，该消息会被发送到该数对应的Partition。（每个Parition都会有个序号,序号从0开始）

  import kafka.producer.Partitioner;
  import kafka.utils.VerifiableProperties;
  public class JasonPartitioner<T> implements Partitioner {
      public JasonPartitioner(VerifiableProperties verifiableProperties) {}
      @Override
      public int partition(Object key, int numPartitions) {
          try {
              int partitionNum = Integer.parseInt((String) key);
              return Math.abs(Integer.parseInt((String) key) % numPartitions);
          } catch (Exception e) {
              return Math.abs(key.hashCode() % numPartitions);
          }
      }
  }

如果将上例中的类作为`partition.class`，并通过如下代码发送20条消息（key分别为0，1，2，3）至topic3（包含4个Partition）:

  public void sendMessage() throws InterruptedException{
  　　for(int i = 1; i <= 5; i++){
  　　      List messageList = new ArrayList<KeyedMessage<String, String>>();
  　　      for(int j = 0; j < 4; j++）{
  　　          messageList.add(new KeyedMessage<String, String>("topic2", j+"", "The " + i + " message for key " + j));
  　　      }
  　　      producer.send(messageList);
      }
  　　producer.close();
  }

则key相同的消息会被发送并存储到同一个partition里，而且key的序号正好和Partition序号相同。（Partition序号从0开始，本例中的key也从0开始）。
下图所示是通过Java程序调用Consumer后打印出的消息列表。

	![had-kafka-5.png](/img/had-kafka-5.png)

## Consumer Group
（本节所有描述都是基于Consumer hight level API而非low level API）。
使用Consumer high level API时，同一Topic的一条消息只能被同一个Consumer Group内的一个Consumer消费(内Consumer 间的互锁机制)，但多个Consumer Group可同时消费这一消息。

![had-kafka-6.png](/img/had-kafka-6.png)

这是Kafka用来实现一个Topic消息的广播（发给所有的Consumer）和单播（发给某一个Consumer）的手段。一个Topic可以对应多个Consumer Group。

1. 如果需要实现广播，只要每个Consumer有一个独立的Group就可以了。
2. 要实现单播只要所有的Consumer在同一个Group里。

用Consumer Group还可以将Consumer进行自由的分组而不需要多次发送消息到不同的Topic。

实际上，Kafka的设计理念之一就是同时提供离线处理和实时处理。 根据这一特性，

1. 可以使用Storm这种实时流处理系统对消息进行实时在线处理，
2. 同时使用Hadoop这种批处理系统进行离线处理，
3. 还可以同时将数据实时备份到另一个数据中心，只需要保证这三个操作所使用的Consumer属于不同的Consumer Group即可。

下图是Kafka在Linkedin的一种简化部署示意图

![had-kafka-7.png](/img/had-kafka-7.png)

下面这个例子更清晰地展示了Kafka Consumer Group的特性。

1. 首先创建一个Topic (名为topic1，包含3个Partition)，
2. 然后创建一个属于group1的Consumer实例，并创建三个属于group2的Consumer实例，
3. 最后通过Producer向topic1发送key分别为1，2，3的消息。
4. 结果发现属于group1的Consumer收到了所有的这三条消息，同时group2中的3个Consumer分别收到了key为1，2，3的消息。如下图所示。

![had-kafka-8.png](/img/had-kafka-8.png)

## Push vs. Pull
作为一个消息系统，Kafka遵循了传统的方式: 选择由Producer向broker push消息并由Consumer从broker pull消息。
一些logging-centric system，比如Facebook的Scribe和Cloudera的Flume，采用push模式。

事实上，push模式和pull模式各有优劣。

1. push模式很难适应消费速率不同的消费者，因为消息发送速率是由broker决定的。
2. push模式的目标是尽可能以最快速度传递消息，但是这样很容易造成Consumer来不及处理消息，典型的表现就是拒绝服务以及网络拥塞。
3. 而pull模式则可以根据Consumer的消费能力以适当的速率消费消息。
4. 对于Kafka而言，pull模式更合适。

pull模式可简化broker的设计，Consumer可自主控制消费消息的速率，同时Consumer可以自己控制消费方式——即可批量消费也可逐条消费，同时还能选择不同的提交方式从而实现不同的传输语义。

## Kafka delivery guarantee
有这么几种可能的delivery guarantee：

1. At most once 消息可能会丢，但绝不会重复传输(like UDP)
2. At least one 消息绝不会丢，但可能会重复传输(like TCP)
3. Exactly once 每条消息肯定会被传输一次且仅传输一次，很多时候这是用户所想要的。

Exactly once in kafka:

1. 当Producer向broker发送消息时，一旦这条消息被commit，因数replication的存在，它就不会丢。
2. 但是如果Producer发送数据给broker后，遇到网络问题而造成通信中断，那Producer就无法判断该条消息是否已经commit。
3. 虽然Kafka无法确定网络故障期间发生了什么，但是Producer可以生成一种类似于主键的东西，发生故障时幂等性的重试多次，这样就做到了Exactly once。

截止到目前(Kafka 0.8.2版本，2015-03-04)，这一Feature还并未实现，有希望在Kafka未来的版本中实现。（所以目前默认情况下一条消息从Producer到broker是确保了At least once，可通过设置Producer异步发送实现At most once）。

接下来讨论的是消息从broker到Consumer的delivery guarantee语义。（仅针对Kafka consumer high level API）。

### 消费

#### At least once
1. Consumer在从broker读取消息后，可以选择commit，该操作会在Zookeeper中保存该Consumer在该Partition中读取的消息的offset。
2. 该Consumer下一次再读该Partition时会从下一条开始读取。
3. 如未commit，下一次读取的开始位置会跟上一次commit之后的开始位置相同。
这就对应于At least once。

#### At most once
1. 可以将Consumer设置为autocommit，
读完消息先commit再处理消息。这种模式下，如果Consumer在commit后还没来得及处理消息就crash了，下次重新开始工作后就无法读到刚刚已提交而未处理的消息，这就对应于At most once

#### Exactly once
在很多使用场景下，消息都有一个主键，所以消息的处理往往具有幂等性，即多次处理这一条消息跟只处理一次是等效的，那就可以认为是Exactly once。

如果一定要做到Exactly once，就需要协调offset和实际操作的输出。精典的做法是引入两阶段提交。

1. 如果能让offset和操作输入存在同一个地方，会更简洁和通用。
2. 这种方式可能更好，因为许多输出系统可能不支持两阶段提交。
3. 比如，Consumer拿到数据后可能把数据放到HDFS，如果把最新的offset和数据本身一起写到HDFS，那就可以保证数据的输出和offset的更新要么都完成，要么都不完成，间接实现Exactly once。（目前就high level API而言，offset是存于Zookeeper中的，无法存于HDFS，而low level API的offset是由自己去维护的，可以将之存于HDFS中）

总之，Kafka默认保证At least once，并且允许通过设置Producer异步提交来实现At most once。而Exactly once要求与外部存储系统协作，幸运的是Kafka提供的offset可以非常直接非常容易得使用这种方式。

# Kafka提供了两种Consumer API
1. High Level Consumer API
2. Low Level Consumer API

## High Level Consumer API概述
High Level Consumer API围绕着Consumer Group这个逻辑概念展开，

1. 它屏蔽了每个Topic的每个Partition的Offset管理（自动读取zookeeper中该Consumer group的last offset ）、
2. Broker失败转移以及增减Partition、Consumer时的负载均衡(当Partition和Consumer增减时，Kafka自动进行负载均衡）

对于多个Partition，多个Consumer

1. 如果consumer比partition多，是浪费，因为kafka的设计是在一个partition上是不允许并发的，所以consumer数不要大于partition数
2. 如果consumer比partition少，一个consumer会对应于多个partitions，这里主要合理分配consumer数和partition数，否则会导致partition里面的数据被取的不均匀。最好partiton数目是consumer数目的整数倍，所以partition数目很重要，比如取24，就很容易设定consumer数目
3. 如果consumer从多个partition读到数据，不保证数据间的顺序性，kafka只保证在一个partition上数据是有序的，但多个partition，根据你读的顺序会有不同
4. 增减consumer，broker，partition会导致rebalance，所以rebalance后consumer对应的partition会发生变化
5. High-level接口中获取不到数据的时候是会block的

### 关于Offset初始值的问题：

  #先produce一些数据，然后再用consumer读的话，需要加上一句offset读取设置
  props.put("auto.offset.reset", "smallest"); //必须要加，如果要读旧数据

因为初始的offset默认是非法的，然后这个设置的意思 是，当offset非法时，如何修正offset，默认是largest，即最新，所以不加这个配置，你是读不到你之前produce的数据的，而且这个时候你再加上smallest配置也没用了，因为此时offset是合法的，不会再被修正了，需要手工或用工具改重置offset

## Low Level Consumer API概述

### Low Level Consumer API控制灵活性
Low Level Consumer API，作为底层的Consumer API，提供了消费Kafka Message更大的控制，如：
>参考，https://cwiki.apache.org/confluence/display/KAFKA/0.8.0+SimpleConsumer+Example

### 什么时候用这个接口?

1. Read a message multiple times
2. Consume only a subset of the partitions in a topic in a process(随机读)
3. Manage transactions to make sure a message is processed once and only once(Exactly Once)

### 复杂性
当然用这个接口是有代价的，即partition,broker,offset对你不再透明，需要自己去管理这些，并且还要handle broker leader的切换，很麻烦

1. You must keep track of the offsets in your application to know where you left off consuming.(自己维护offset)
2. You must figure out which Broker is the lead Broker for a topic and partition
(如果一个Partition有多个副本，那么Lead Partition所在的Broker就称为这个Partition的Lead Broker)
3. You must handle Broker leader changes

### 使用SimpleConsumer的步骤：
1. Find an `active Broker` and find out which Broker is the `leader for your topic and partition`
2. Determine who the `replica Brokers` are for your topic and partition
3. Build the `request` defining what data you are interested in
4. `Fetch` the data
5. `Identify and recover` from `leader changes`

首先，你必须知道读哪个topic的哪个partition
然后，找到负责该partition的broker leader，从而找到存有该partition副本的那个broker
再者，自己去写request并fetch数据
最终，还要注意需要识别和处理broker leader的改变

Finding the Lead Broker for a Topic and Partition  方法:

1. 遍历每个broker，取出该topic的metadata，
2. 然后再遍历其中的每个partition metadata，如果找到我们要找的partition就返回

# Kafka Client

## kafkacat
Generic command line non-JVM Apache Kafka producer and consumer
https://github.com/edenhill/kafkacat

  brew install kafkacat

# 参考
Kafka剖析（一）：Kafka背景及架构介绍
http://www.infoq.com/cn/articles/kafka-analysis-part-1

Kafka Consumer接口
http://www.cnblogs.com/fxjwind/p/3794255.html

https://segmentfault.com/a/1190000003912925
