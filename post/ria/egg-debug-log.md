# logger

    // app logger 记录启动阶段的一些数据信
    app.logger.warn(msg)

    // 当前请求相关的信息（如 [$userId/$ip/$traceId/${cost}ms $method $url]
    ctx.logger 

    //controller/service logger 本质上就是一个 Context Logger，不过在打印日志的时候还会额外的加上文件路径
    this.logger

## 日志路径
online 所有的日志都会打印到 $HOME/logs 文件夹下（例如 /home/admin/logs）
dev: ${baseDir}/logs

## 日志级别

    // config/config.${env}.js
    exports.logger = {
        consoleLevel: 'INFO', //默认
        consoleLevel: 'NONE',

        level: 'DEBUG', //文件日式级别
        allowDebugAtProd: false, //默认
    };
