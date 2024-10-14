---
title: vegeta
date: 2021-07-08
private: true
---
# vegeta
vegeta 是golang 写的压测工具

    go get  github.com/tsenart/vegeta

## 压测报告
    $ jq -ncM 'while(true; .+1) | {method:"GET", header:{"Content-Type": ["application/json"]}, url:"http://m:4500/sleep/3", body: {} | @base64 }'| vegeta attack -format=json -rate=4 -lazy -duration=10s | vegeta report
    Requests      [total, rate, throughput]         40, 4.10, 3.14
        throughput(qps): 40/12.75=3.14
    Duration      [total, attack, wait]             12.753s, 9.75s, 3.003s
            attack: 发完所有的请求花了接近10s;
            total: 所有的请求完成接近13s
            wait: 所有请求发送完毕后，等待所有响应返回的时间 (并不是平均响应时间)
    Latencies     [min, mean, 50, 90, 95, 99, max]  3.001s, 3.002s, 3.002s, 3.003s, 3.003s, 3.011s, 3.011s
    Bytes In      [total, mean]                     680, 17.00
    Bytes Out     [total, mean]                     80, 2.00
    Success       [ratio]                           100.00%
    Status Codes  [code:count]                      200:40 
## 构建请求
### 构造get/post 请求

    $ echo "GET http://host.com/api/v1/tasks" | vegeta attack  -rate=10000  -duration=10s |vegeta report
    $ echo "GET http://host.com/api/v1/tasks" | vegeta attack  -rate=10000  -duration=10s > result.bin



#### header(要加json):

    jq -ncM '{method: "POST", url: "http://m:8099", header: {"Content-Type": ["text/plain"]}}' | vegeta attack -format=json -rate=100 | vegeta report


也可以能过　`-header`加：


#### 构造body json
必须通过base64传body json

    jq -ncM '{method: "POST", url: "http://m:8099", body: {a:{b:[1,2]}} | @base64, header: {"Content-Type": ["application/json"]}}' | vegeta attack -format=json -rate=10 -duration=10s | vegeta report

以上jq脚本的解释：

    -n 没有stdin input
    -c 压缩到一行
    -M 去掉高亮彩色

    while(true; .+1) 生成自增ID
    ("stress-test-"+(.|tostring)) 将整数ID转为string并加上前缀

## vegeta attack
vegeta attack 参数：

    -format 接收请求信息的格式，如上例用这里使用json 请求格式
    -rate 每秒请求数
    -duration 压测持续时间。0代表一直执行。
    > 输出文件是二进制格式。

    jq -ncM '{method: "GET", url: "http://goku", body: "Punch!" | @base64, header: {"Content-Type": ["text/plain"]}}' |
    vegeta attack -format=json -rate=100 | vegeta report

### 变化请求

    jq -ncM 'while(true; .+1) | {method: "POST", url: "http://m:8099/api/gps", body: {"id":("id-"+(.|tostring)),"status":"IDLE"} | @base64 }' | vegeta attack -format=json -rate=6000 -lazy -duration=60s > result.data-collection.6000qps.60s.gen.bin;

    vegeta report result.data-collection.6000qps.60s.gen.bin | head -n 10;


Note: 
1. 没有`-lazy`
    1. 如果stdin的请求数不够的话. 会重复请求. `cat a.txt| vegeta ....`
    2. 会因为read stdin buffer阻塞。（jq -ncM while(true; .+1) 是无限的，就会阻塞）
    $ jq -ncM 'while(true; .+1) | {method: "GET", header: {"Content-Type": ["application/json"]}, url: "http://0:4500/sleep/3", body: {"name":"wf_yxh1","input":{}} | @base64 }'  | vegeta attack -format=json -rate=2  -duration=5s | vegeta report
1. 有`-lazy`表示
    1. 如果stdin的请求数不够的话，不会重复请求. 有多少就请求多少: `cat a.txt| vegeta ....`

vegeta report： 分析attack的二进制输出，生成报告。

    vegeta report result.data-collection.6000qps.60s.gen.bin | head -n 10;

vegeta plot： 生成 html 格式的折线图，使用浏览器打开文件。

    vegeta plot result.key.200qps.60s.bin > result.key.200qps.60s.html

横轴是压测时刻，从0到duration。纵轴是滑窗内的平均响应时间，滑窗大小可以在左下角的小输入框里修改。


## debug

### show error body
如果想查看400 error 返回的body

    echo "GET http://host.com/api/v1/tasks" | vegeta attack  -rate=10000  -duration=10s > output.log
    grep 400 -A 10 output.log

## 指标说明
    Requests      [total, rate, throughput]  10, 2.22, 1.33
    Duration      [total, attack, wait]      7.503169051s, 4.502392958s, 3.000776093s
    Latencies     [mean, 50, 95, 99, max]    3.004404443s, 3.00297599s, 3.016054975s, 3.016054975s, 3.016054975s
    Bytes In      [total, mean]              170, 17.00
    Bytes Out     [total, mean]              290, 29.00
    Success       [ratio]                    100.00%
    Status Codes  [code:count]               200:10
    Error Set:

# config
## common config
    -workers 10
        initial number of workers

## httpClient 
### Timeout
    -timeout 30s
        httpClient.Timeout(connect + response time)
### -keepalive
Specifies whether to reuse TCP connections between HTTP requests.

