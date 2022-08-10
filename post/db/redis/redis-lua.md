---
title: redis lua
date: 2022-08-07
private: true
---
# redis lua

    eval 'return "hello"' 0
    eval 'return redis.call("TIME")' 0
     eval 'local a=1;return  a' 0
    help @script
    help eval


multiple line script

    eval 'local key=KEYS[1]; redis.call("SET", key, ARGV[1]); local v = redis.call("GET", key); return v ' 1 k1 v1

for more: golang/redis_rate_limit