---
title: 股票交易的数据
date: 2018-09-26
private:
---
# 数据获取
通用数据
    https://www.dydata.io/
    歪枣网: http://www.waizaowang.com/
    tushare
更专业的数据：
    choice 和 wind 
自定义量化图：
    乌龟量化\乐咕乐咕\理杏仁这些网站
多策略提醒：
    https://v2ex.com/t/1031232
        策引 - 我的 AI 投资助手 网址： https://www.myinvestpilot.com/


查询PE/PB等：
    http://www.licaidashiye.com/tools/value/ad_to_stock_page.php
    http://www.51shiyinglv.com/dist/index.html#/main/index
    通联数据：https://app.datayes.com/cloud-portal/#/portal
PE TTM:
    https://api.wmcloud.com/docs/pages/viewpage.action?pageId=1867813
vs:
    https://guorn.com/stock/history?his=1&index=801780,0.M.%E6%8C%87%E6%95%B0%E6%97%A5%E8%A1%8C%E6%83%85_%E5%8A%A0%E6%9D%83%E5%B9%B3%E5%9D%87%E5%B8%82%E7%9B%88%E7%8E%87.0,1&ticker=601166,0.M.%E8%82%A1%E7%A5%A8%E6%AF%8F%E6%97%A5%E6%8C%87%E6%A0%87_%E5%B8%82%E7%9B%88%E7%8E%87.0,1
CSMAR，国泰安数据库，有详细的上市公司数据，包括你要的市盈率。(查询后会直接发个excel到你的邮箱，那可是个十几万数据量的excel啊…)
另外就是wind万得资讯的数据库
东方财富choice金融终端，有免费试用版，30天
都是付费的，舍不得掏钱就去附近的学校，混进图书馆连接内网，学校都会采购的有的

#### 价值预测
正点财经
http://stock.zdcj.net/jiazhi/600000.html

### 量化交易
0. 讨论与学习:
    https://www.jisilu.cn/question/36609
    https://www.zhihu.com/question/22211032
1. 开通Wind交易通道, 如在国信FIX直通业务
2. 量化交易框架python3:
    https://uqer.io/community/share/56893b69228e5b67159beb37
    https://github.com/ahuigo/easytrader
    https://github.com/shidenggui/easyquant
3. 量化分析师的Python日记:
    https://uqer.io/community/share/54c89443f9f06c276f651a52
4. 量化实时数据:
    https://www.jisilu.cn/data/sfnew/#tlink_3
    Wind机构版量化接口支持的券商清单及开户要求
    http://www.dajiangzhang.com/q?bfa267fd-0cba-409f-a604-5ea4e12eb88b
    http://www.dajiangzhang.com/document
    知乎问题
    https://www.zhihu.com/question/29648560

5. 选股:
    https://www.zhihu.com/question/38113586

### 策略
决定其价格升或降的大概就是两股力量：
1. 均值回归: KDJ等指标
2. 趋势继续: 著名的macd金叉死叉理论
3. 基本面财报分析: 市盈率+净利润毛利润+利润增长率

如何理解KDJ+MACD : https://www.zhihu.com/question/26729743/answer/33877577

各种量化策略:
1. https://guorn.com
2. https://www.joinquant.com/

#### 财报分析
https://www.zhihu.com/question/19645090
a. 盈利性和成长性：
    盈利性：主营毛利润率（去掉cost）、经营利润率（去掉cost、expense）和净利润率（去掉cost、expense和tax），归属母公司利润，ROA，ROE，ROIC
    成长性：以上各数值的同比增长率，销售收入、成本结构与上年相比的变化率。
b. 经营指标: 一般就是MAU（月活跃账户数）、ACU（平均同时在线账户数）、PCU（最高同时在线账户数）、APA（付费账户数）和ARPU（平均每账户营收贡献）
b. 资金流动性
    库存周转率，资金周转率，EBIT/支付利息，自由现金流的变化与公司扩张资金需求，应收、应付的同比变化率。
c. 财务健康性
    资产负债率，总负债/EBIT，大订单对象的变化，前5-10名交易对象占总交易额比。
d. 其他关注点
    大股东和创投背景，高管层背景及变化，人员变更，机构持股数，税率变化，国家补贴等等

![img](/a/img/my-stock-0.jpg)

##### 主力成本
掌握庄家成本，成本的确定方法基本有定增，庄家不直接从二级市场买。
1. 定增有定增价，你都可以查到。
2. 第二种，二级市场直接买筹码，通过股价，成交量确定主力平均成本，
3. 最后一种，股份转让价, 涨30%可能


#### 我的
开盘价=(前日收盘价+开盘价)/2
选股: 近几年利润增长率top50%, 成本持续增长, 行业排名top50%, 市盈率<行业市盈率/2
卖(只执行其中一个)
    1.1 连续两天上涨, 且3/5天买入价高于卖出价(买入价大于卖出价格)则收盘价则不卖
    1.2 9:30 卖出价格>开盘价2%, 这个2% 是近1个月的开盘价涨幅的波动率
    1.3 10:30 max(卖出价格>开盘价1% 这个1% 是近1个月的开盘价涨幅的波动率除以2, 前一个小时的最高价(减去与开盘价的差的0.1))

买(只执行其中一个)
    2.1 连续两天下跌, 且3/5天买入价低于卖出价则不买
    2.2 9:30 买入价格< -2%, 这个2% 是近1个月的开盘价降幅的波动率
    2.3 10:30 min(买入价格< -1%, 这个1% 是近1个月的开盘价降幅的波动率, 前一个小时的最低价(加上与开盘价的差的0.1))
    2.4 2:40 如果有卖出且没有买入, 立即买入


### 接口

### 数据
下载股票历史数据
https://www.zhihu.com/question/22145919

#### r15 股票池
http://data.51xianjinliu.com/stock/pool?pool=r15

#### choice数据
choice数据: 有3年的分钟线数据
http://choice.eastmoney.com/Product/download_center.html

#### 量化交易网
https://www.ricequant.com/data
https://www.joinquant.com/help/data/stock

#### 每日价格
深交所:
http://table.finance.yahoo.com/table.csv?s=000001.sz
上交所:
http://table.finance.yahoo.com/table.csv?s=600000.ss
