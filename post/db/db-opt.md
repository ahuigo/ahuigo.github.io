---
title: Cpu 优化
date: 2018-09-27
---
# Cpu 优化
https://help.aliyun.com/knowledge_detail/43562.html

如果这些SQL确实是业务上必需的，则需要对他们做优化。这方面有“三板斧”：

1. 对查询涉及的表，执行ANALYZE <table>或VACUUM ANZLYZE <table>，更新表的统计信息，使查询计划更准确。注意，为避免对业务影响，最好在业务低峰执行。

2. 执行explain <query text>或explain (buffers true, analyze true, verbose true) <query text>命令，查看SQL的执行计划（注意，前者不会实际执行SQL，后者会实际执行而且能得到详细的执行信息），对其中的Table Scan涉及的表，建立索引。

3. 重新编写SQL，去除掉不必要的子查询、改写UNION ALL、使用JOIN CLAUSE固定连接顺序等到，都是进一步深度优化SQL的手段，这里不再深入说明。