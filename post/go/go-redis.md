---
title: go redis
date: 2020-04-17
private: true
---
# go redis
> go-lib/redis
https://godoc.org/github.com/go-redis/redis#pkg-examples

    func ExampleClient() {
        client := redis.NewClient(&redis.Options{
            Addr:     "localhost:6379",
            Password: "", // no password set
            DB:       0,  // use default DB
        })
        pong, err := client.Ping().Result()
        fmt.Println(pong, err)

        err := client.Set("key", "value", 100).Err()
        if err != nil {
            panic(err)
        }

        val, err := client.Get("key").Result()
        if err != nil {
            panic(err)
        }
        fmt.Println("key", val)

        val2, err := client.Get("key2").Result()
        if err == redis.Nil {
            fmt.Println("key2 does not exist")
        } else if err != nil {
            panic(err)
        } else {
            fmt.Println("key2", val2)
        }
        // Output: key value
        // key2 does not exist
    }

## HSet
    // hset k1 v1 k2 v2 ....
	_, err = client.HSet("auth", "resource", true).Result()
	val2, err = client.HGet("auth", "resource").Result()
	if err == redis.Nil {
		fmt.Printf("%#v, %v", err, err) 
	} else if err != nil {
		panic(err)
	} else {
		fmt.Printf("%#v, %v", err, err) //string, 1
	}
