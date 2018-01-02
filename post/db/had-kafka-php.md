 # consumer

 ## consumerStart
 consumerStart:

     $topic = $rk->newTopic("logsget_qos_live_web", $topicConf);
     // Start consuming partition 0
     $topic->consumeStart(0, RD_KAFKA_OFFSET_STORED);

    // consume from the end
    $topic->consumeStart($partition, RD_KAFKA_OFFSET_END);

    // consume from the stored offset
    $topic->consumeStart($partition, RD_KAFKA_OFFSET_STORED);

    // consume 200 messages from the end
    $topic->consumeStart($partition, rd_kafka_offset_tail(200));

    RD_KAFKA_OFFSET_BEGINNING
    RD_KAFKA_OFFSET_END
    RD_KAFKA_OFFSET_STORED
