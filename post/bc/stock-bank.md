---
title: bank
date: 2018-09-26
---
# bank

## Non-performing Loan, 不良贷款
1. 不良贷款拨备，对可能损失的贷款计提的损失准备，当期新增不良贷款拨备以费用形式支出，扣减当期利润。其中关注类贷款计提少量损失准备，不良贷款（次级、可疑、损失）计提较多的损失准备；除了对应贷款的专项损失准备，还会计提组合损失准备，这个组合损失准备可超额计提，作为对未来预期风险的对冲，同时也是银行调节利润最主要的方式。
2. 关注类贷款，包括*逾期1-90天贷款*和因为其他因素可能影响贷款偿还被化至关注类的贷款。向上可以转化为正常类贷款，向下可以变成不良贷款。
3. 不良贷款，包括*逾期90天以上的贷款*和因为其他因素影响贷款偿还的贷款。不良贷款需要计提较大比例的拨备。

## 拨备覆盖率（Provision coverage）
即不良贷款拨备覆盖率（NPL Provision coverage） = 贷款损失准备金计提余额/不良贷款余款

# 清算与结算
清分=记账 
清算=算账 
结算=转账

国内各银行间的清算与结算均依赖于中国人民银行的大小额支付系统。
1. 小额批量支付系统：
除系统维护外，全年7X24小时工作。A行向B行汇款，单笔金额小于5W走小额支付系统。A行将向B行单笔小于5W的汇款逐一记录（清分），依次凑够5W为一个单位（清算），根据清算结果每5W一笔人民币批量转给B行（结算）。小额支付系统每日清算时间为8:30-17:00。在清算与结算未完成时B行会用自己在人行的备付金先为客户进行垫付，所以B行的客户收款是实时的。
2. 大额实时支付系统:
单笔交易金额大于5W的一律走该系统。比如:6月1号15:00 A行要付给B行2亿，B行要付给A行1亿，人民银行处理中心先记下这两笔交易（清分），然后轧差账目二者相抵A行付给B行1亿（清算），最后A行根据账目核对结果实时将1亿人民币转给B行（结算）。

银联这类清算企业负责的是将POS与ATM跨行转账、跨行取款的交易接入人行的大小额支付系统进行清算与结算。银行的柜台业务是直接接入大小额系统的，所以不归银联管。

作者：美国大香蕉
链接：https://www.zhihu.com/question/19892912/answer/31354339

# swift
> http://www.eygle.com/digest/2011/04/swift_codebicbranch_code.html

国际汇款汇款需要的信息主要有以下几项：
Beneficiary name.
Beneficiary address.
Beneficiary Bank Identifier Code (BIC) or Routing Code.
Beneficiary International Bank Account Number (IBAN) or Account Number.
其中，name和IBAN大家都是知道的，address并不重要，填自己的地址或者开户行地址都行，只有BIC（或者叫SWIFT）大家需要咨询 开户行，每家银行的每个分行都有一个11位的编码。
全球所有银行的BIC（SWIFT）自己都可以查到的：
使用方法如下：
首先进入：http://www.swift.com/bsl/index.faces

输入 BKCHCNBJ 查询中国银行BIC
输入 ICBKCNBJ 查询中国工商银行BIC
输入 ABOCCNBJ 查询中国农业银行BIC
输入 PCBCCNBJ 查询中国建设银行BIC
输入 CMBCCNBS 查询招商银行BIC
Institution name：不用输入
City：输入城市名（拼音）或者省名，一般省会城市的名字
Country name：选择CHINA
然后点"Search"，然后点击出来的结果，就可以看到BIC了。