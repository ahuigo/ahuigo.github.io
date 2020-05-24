---
title: Go log
date: 2019-09-21
---
# zap log
Refer: https://studygolang.com/articles/17394

## Sugar Logger
sugar log 支持任意的类型(基于reflect实现类型检测)
### Info/Error
    loggerS:= zap.NewExample().Sugar()
    loggerS.Info(obj1, obj2, ...) //中间无空格
    loggerS.Error(obj1, obj2,...) //

### Infow/Infof

    sugar := zap.NewExample().Sugar()
    defer sugar.Sync()
    sugar.Infow("failed to fetch URL",
        "url", "http://example.com",
        "attempt", 3,
        "backoff", time.Second,
    )

sugar log 提供了 formatter 接口(基于reflect实现类型检测)

    sugar.Infof("failed to fetch URL: %s", "http://example.com")

### Debugw

    loggerS := logger.Named("service").Sugar()
    loggerS.Debugw("msg", "k1", 123, "k2", "v2")

	logger.Debugw("msg", "msg2", map[string]interface{"k":1})
    loggerS.Debugw("msg", "k1", map[string]interface{}{"k":1})



## logger

### logger Sugar vs Field
有两种logger，sugarLogger接受任意类型，更慢; 普通的logger 只接受类型field

    logger := zap.NewExample()
    defer logger.Sync()
    sugar := logger.Sugar()
    plain := sugar.Desugar()

#### field logger(dev-prod)
go-lib/log/zip-dev-prod.go

    package main

    import (
        "go.uber.org/zap"
        "time"
    )

    func main() {
        logger, _ := zap.NewDevelopment()
        defer logger.Sync()
        logger.Info("无法获取网址",
            zap.String("url", "http://www.baidu.com"), //必须指定类型
            zap.Int("attempt", 3),
            zap.Duration("backoff", time.Second),
        )
    }

dev logger 结果:

    2020-04-20T23:54:46.601+0800	INFO	log/zap1.go:12	无法获取网址	{"url": "http://www.baidu.com", "attempt": 3, "backoff": "1s"}


### logger Names
    logger, _ := zap.NewProduction()
    logger = logger.Named("service")

### logger format
    logger := zap.NewExample()

    // zap.NewProduction json序列化输出
    logger, _ := zap.NewProduction()
    // zap.NewDevelopment
    logger, _ := zap.NewDevelopment()

#### developement format

    // 开启开发模式，堆栈跟踪
	caller := zap.AddCaller()
	// 开启文件及行号
	development := zap.Development()
	// 设置初始化字段
	filed := zap.Fields(zap.String("serviceName", "serviceName"))
	// 构造日志
	logger := zap.New(core, caller, development, filed)

## config key/date/level/path
log/zap-config.go

    config := zap.Config{
        Level:            atom,                                                // 日志级别
        Development:      true,                                                // 开发模式，堆栈跟踪
        Encoding:         "console",                                              // 输出格式 console 或 json
        EncoderConfig:    encoderConfig,                                       // 编码器配置
        InitialFields:    map[string]interface{}{"serviceName": "spikeProxy"}, // 初始化字段，如：添加一个服务器名称
        OutputPaths:      []string{"stdout", "./logs/spikeProxy.log"},         // 输出到指定文件 stdout（标准输出，正常颜色） stderr（错误输出，红色）
        ErrorOutputPaths: []string{"stderr"},
    }



## logger file: roll
归档日志：

    log/zap-rolling.go

## logger工具

### logger utils 类
zap 还在 logger 这层提供了丰富的工具包，这让整个 zap 库更加的易用:

1. grpc logger：grpc 提供了 SetLogger 的接口。 zap 提供了对这个接口的封装。
2. hook：使用方实现 hook 然后注册到 logger，zap在合适的时机将日志进行后续的处理，例如写 kafka，统计日志错误率 等等。
3. std Logger: zap 提供了将标准库提供的 logger 对象重定向到 zap logger 中的能力，也提供了封装 zap 作为标准库 logger 输出的能力。 整体上十分易用。
4. sublog: 通过创建 绑定了 field 的子logger，实现了更加易用的功能。

### levelHandler
zap 为http 提供了level 处理. 简单几行代码就能实现 http 请求控制日志级别的能力。 通过 GET获取当前级别，PUT 设置新的级别。

    http.HandleFunc("/handle/level", zapLevelHandler)
    if err := http.ListenAndServe(addr, nil); err != nil {
        panic(err)
    }

## 高级(高性能zap)
https://studygolang.com/articles/14220

zap 高性能原因：

1. 写实复制，避免加锁
2. 对象内存池，避免频繁创建销毁对象
3. 内建的 Encoder: 避免反射
    1. 避免使用 fmt json/encode 使用字符编码方式对日志信息编码，适用byte slice 的形式对日志内容进行拼接编码操作

### sync.Pool 提供的对象池
zap 通过 sync.Pool 提供的对象池，复用了大量可以复用的对象，避开了 gc 这个大麻烦。
1. zap 使用了`sync.Pool` 提供的标准对象池。
   1. 其提供的 `runtime`级别绑定到 `P(Processor)` 的处理逻辑，每个 `P` 都有自己的池在调度时不会发生竞争。 这个比起代码中的软实现更加高效，是用户代码做不到的逻辑。
2. 而 channel 实现的对象池在多个 Processor 之间会有强烈的并发


