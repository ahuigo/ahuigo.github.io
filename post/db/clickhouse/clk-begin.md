---
title: clickhouse beign
date: 2024-03-28
private: true
---
# clickhouse intro
It's column database's pros and cons:
1. Scalability
    1. Scales well both vertically and horizontally
    2. Can be scaled by adding extra replicas and extra shards to process queries in a distributed way.
2. Weakness:
    4. Lack of full-fledged UPDATE/DELETE implementation(缺乏成熟的修改、删除机制)
    1. OLAP（Online Analytical Processing）, 不适合OLTP（Online Transaction Processing）
3. Rivals and Alternatives:
   1. Snowflake
   2. elastic

# install
    curl https://clickhouse.com/ | sh

    ./clickhouse server
    ./clickhouse client

clockhosue-local(standalone 独立版，不需要full server)

    ./clickhouse -q "SELECT * FROM 'reviews.tsv'"
    ./clickhouse -q "show databases"





