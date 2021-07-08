---
title: vegeta
date: 2021-07-08
private: true
---
# vegeta
vegeta 是golang 写的压测工具

    go get  github.com/tsenart/vegeta

### 构造get/post 请求

    echo "GET http://host.com/api/v1/tasks" | vegeta attack  -rate=10000  -duration=10s |vegeta report
    echo "GET http://host.com/api/v1/tasks" | vegeta attack  -rate=10000  -duration=10s > result.bin

header(要加json):

    jq -ncM '{method: "GET", url: "http://m:8099", header: {"Content-Type": ["text/plain"]}}' |
    vegeta attack -format=json -rate=100 | vegeta encode

必须通过base64传body json

    jq -ncM '{method: "GET", url: "http://m:8099", body: {a:{b:[1,2]}} | @base64, header: {"Content-Type": ["application/json"]}}' | vegeta attack -format=json -rate=100 | vegeta encode

以上jq脚本的解释：

    -n 没有stdin input
    -c 压缩到一行
    -M 去掉高亮彩色

    while(true; .+1) 生成自增ID
    ("stress-test-"+(.|tostring)) 将整数ID转为string并加上前缀

### vegeta attack
vegeta attack 参数：

    -format 接收请求信息的格式，如上例用这里使用json 请求格式
    -rate 每秒请求数
    -duration 压测持续时间。0代表一直执行。
    > 输出文件是二进制格式。

    jq -ncM '{method: "GET", url: "http://goku", body: "Punch!" | @base64, header: {"Content-Type": ["text/plain"]}}' |
    vegeta attack -format=json -rate=100 | vegeta encode

### 变化请求

    jq -ncM 'while(true; .+1) | {method: "POST", url: "http://m:8099/api/gps", body: {"id":("id-"+(.|tostring)),"status":"IDLE"} | @base64 }' | vegeta attack -format=json -rate=6000 -lazy -duration=60s > result.data-collection.6000qps.60s.gen.bin;

    vegeta report result.data-collection.6000qps.60s.gen.bin | head -n 10;

vegeta report： 分析attack的二进制输出，生成报告。

    vegeta report result.data-collection.6000qps.60s.gen.bin | head -n 10;

vegeta plot： 生成 html 格式的折线图，使用浏览器打开文件。

    vegeta plot result.key.200qps.60s.bin > result.key.200qps.60s.html

横轴是压测时刻，从0到duration。纵轴是滑窗内的平均响应时间，滑窗大小可以在左下角的小输入框里修改。
