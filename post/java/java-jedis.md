# single thread

# multiple threads
http://commons.apache.org/proper/commons-pool/apidocs/org/apache/commons/pool2/impl/GenericObjectPoolConfig.html

You shouldn't use the same instance from different threads because you'll have strange errors.
you should use *JedisPool*, which is a *threadsafe pool* of network connections.


    JedisPoolConfig config = new JedisPoolConfig();
		config.setMaxActive(100);
		config.setMaxIdle(20);
		config.setMaxWait(1000l);

    JedisPool pool = new JedisPool(new JedisPoolConfig(), "localhost");

    /// Jedis implements Closable. Hence, the jedis instance will be auto-closed after the last statement.
    try (Jedis jedis = pool.getResource()) {
      /// ... do stuff here ... for example
      jedis.set("foo", "bar");
      String foobar = jedis.get("foo");
      jedis.zadd("sose", 0, "car");
      Set<String> sose = jedis.zrange("sose", 0, -1);
    }
    /// ... when closing your application:
    pool.destroy();

If Jedis was borrowed from pool, it will be returned to pool with proper method since it already determines there was JedisConnectionException occurred. If Jedis wasn't borrowed from pool, it will be disconnected and closed.

# Setting up master/slave distribution

## ennable replication
Here are two ways to tell a slave it will be "slaveOf" a given master:

- Specify it in the *respective section in the Redis Config file* of the redis server
- on a given jedis instance, call the slaveOf method:

    jedis.slaveOf("localhost", 6379);  //  if the master is on the same PC which runs your code
    jedis.slaveOf("192.168.1.35", 6379);

## disable replication / upon failing master, promote a slave
You may want to promote a slave to be the new master.
You should:

1. first (try to) disable replication of the offline master first,
2. then, in case you have several slaves, enable replication of the remaining slaves to the new master:

    slave1jedis.slaveofNoOne();
    slave2jedis.slaveof("192.168.1.36", 6379);
