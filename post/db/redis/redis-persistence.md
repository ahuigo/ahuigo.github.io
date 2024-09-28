---
title: redis persistence tactic
date: 2024-09-23
private: true
---
# redis persistence
redis has 4 persistence methods:
1. RDB
RDB 持久化会在指定的时间间隔内生成数据集的时间点快照。这是一个非常紧凑的文件，代表了 Redis 在某个时间点上的数据集。这种方式适合大规模数据恢复，且对性能影响小，但可能会丢失最后一次快照后的所有修改。
2. AOF(Append only file)
AOF 持久化记录服务器接收到的所有写操作命令。在服务器启动时，会通过重新执行这些命令来还原数据集。AOF 文件的更新操作采取追加的方式，因此对于同一条记录的多次修改，AOF 文件中可能会有多条记录。
2. RDB+AOF

## View Tactic
可以使用 redis-cli view tactic:

    执行 CONFIG GET save 命令。这个命令会返回一个列表，表示 Redis 在多长时间内，有多少次更新操作时，会自动触发 RDB 持久化。
    执行 CONFIG GET appendonly 命令。如果返回的值是 "yes"，那么表示 Redis 启用了 AOF 持久化。

默认启用了 AOB：

    redis:6379> CONFIG GET save
    > "save"
    > "3600 1 300 100 60 10000"
        在 3600 秒（1小时）内，如果有 1 次或更多次的写操作，Redis 就会触发 RDB 持久化。
        在 300 秒（5分钟）内，如果有 100 次或更多次的写操作，Redis 也会触发 RDB 持久化。
        在 60 秒（1分钟）内，如果有 10000 次或更多次的写操作，Redis 同样会触发 RDB 持久化


如果启用了 AOF 持久化，你还可以执行 CONFIG GET appendfsync 命令，来查看 AOF 持久化的策略。这个命令的返回值可以是 "always"，"everysec" 或者 "no"，