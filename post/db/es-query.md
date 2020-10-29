---
title: elastic query
date: 2020-10-29
private: true
---
# elastic query
查询示例

    /weather/beijing/_search?q=
    q: NOT startTime:"1970-01-01T00:00:00Z" AND NOT endTime:"1970-01-01T00:00:00Z" AND startTime:[2020-10-18T00:00:00Z TO 2020-10-28T00:00:00Z] AND NOT taskDefName:FORK AND NOT taskDefName:DECISION AND NOT taskDefName:JOIN AND executionTime:[0 TO *] AND queueWaitTime:[0 TO *] AND status:COMPLETED