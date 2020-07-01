---
title: Golang 命名
date: 2019-09-09
private:
---
# Gofmt 命名
https://zhuanlan.zhihu.com/p/63250689
1. 使用可搜索的名称：单字母名称和数字常量很难从一大堆文字中搜索出来。单字母名称仅适用于短方法中的本地变量，名称长短应与其作用域相对应。若变量或常量可能在代码中多处使用，则应赋其以便于搜索的名称。
2. 做有意义的区分：Product和ProductInfo和ProductData没有区别，NameString和Name没有区别，要区分名称，就要以读者能鉴别不同之处的方式来区分 。
3. 函数命名规则：
   1. 驼峰式命名，名字可以长但是得把功能，必要的参数描述清楚，函数名名应当是动词或动词短语，如postPayment、deletePage、save。并依Javabean标准加上get、set、is前缀。例如：xxx + With + 需要的参数名 + And + 需要的参数名 + …..
4. 结构体命名规则：结构体名应该是名词或名词短语，如Custome、WikiPage、Account、AddressParser，
5. 包名命名规则：包名应该为小写单词，不要使用下划线或者混合大小写`net/util`


## 包名
包名应该为小写单词，不要使用下划线或者混合大小写。

    package "net/url"

## 接口名
单个函数的接口名以"er"作为后缀，如

    type Reader interface {
            Read(p []byte) (n int, err error)

    }

两个函数的接口名综合两个函数名

    type WriteFlusher interface {
        Write([]byte) (int, error)
        Flush() error
    }

## 变量
1. 全局变量：驼峰式，结合是否可导出确定首字母大小写
2. 参数传递：驼峰式，小写字母开头
3. 局部变量：同上，不要用下划线形式(golint 规定)

变量命名: 驼峰式，小写字母开头

    如果变量为私有，且特有名词为首个单词，则使用小写，如 apiClient
    其它情况都应当使用该名词原有的写法，如 APIClient、repoID、UserID
    错误示例：UrlArray，应该写成 urlArray 或者 URLArray
    若变量类型为 bool 类型，则名称应以 Has, Is, Can 或 Allow 开头

e.g.

    user 可以简写为 u
    userID 可以简写 uid
    若变量类型为 bool 类型，则名称应以 Has, Is, Can 或 Allow 开头：

### 特有名词
遇到特有名词时，需要遵循以下规则：

1. 如果变量为私有，且特有名词为首个单词，则使用小写，如 apiClient
1. 其它情况都应当使用该名词原有的写法，如 APIClient、repoID、UserID
1. 错误示例：UrlArray，应该写成urlArray或者URLArray

下面列举了一些常见的特有名词：

    // A GonicMapper that contains a list of common initialisms taken from golang/lint
    var LintGonicMapper = GonicMapper{
        "API":   true,
        "ASCII": true,
        "CPU":   true,
        "CSS":   true,
        "DNS":   true,
        "EOF":   true,
        "GUID":  true,
        "HTML":  true,
        "HTTP":  true,
        "HTTPS": true,
        "ID":    true,
        "IP":    true,
        "JSON":  true,
        "LHS":   true,
        "QPS":   true,
        "RAM":   true,
        "RHS":   true,
        "RPC":   true,
        "SLA":   true,
        "SMTP":  true,
        "SSH":   true,
        "TLS":   true,
        "TTL":   true,
        "UI":    true,
        "UID":   true,
        "UUID":  true,
        "URI":   true,
        "URL":   true,
        "UTF8":  true,
        "VM":    true,
        "XML":   true,
        "XSRF":  true,
        "XSS":   true,
    }

### 采用短声明建立局部变量

    sum := 0
    for i := 0; i < 10; i++ {
        sum += i
    }
    range

## return error
尽早return：一旦有错误发生，马上返回

    if err != nil {
        return err
    }

## 函数（必须）
函数采用命名的多值返回, 传入变量和返回变量以小写字母开头

    func nextInt(b []byte, pos int) (value, nextPos int) {


## panic
尽量不要使用panic，除非你知道你在做什么

# Refer
版权声明：本文为CSDN博主「CRMO」的原创文章，遵循 CC 4.0 BY-SA 版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/myzlhh/article/details/52269591