---
title:  gonic debug/log
private:
date: 2019-04-22
---
# gonic log

## debug mode
 - using env:	export GIN_MODE=release
 - using code:	gin.SetMode(gin.ReleaseMode)

## router log formate

    [GIN-debug] POST   /foo                      --> main.main.func1 (3 handlers)

custom it:

	gin.DebugPrintRouteFunc = func(httpMethod, absolutePath, handlerName string, nuHandlers int) {
		log.Printf("endpoint %v %v %v %v\n", httpMethod, absolutePath, handlerName, nuHandlers)
    }

## middleware log format
https://gin-gonic.com/docs/examples/custom-log-format/

	router := gin.New()
	// LoggerWithFormatter middleware will write the logs to gin.DefaultWriter
	// By default gin.DefaultWriter = os.Stdout
	router.Use(gin.LoggerWithFormatter(func(param gin.LogFormatterParams) string {
		// your custom format
		return fmt.Sprintf("%s - [%s] \"%s %s %s %d %s \"%s\" %s\"\n",
				param.ClientIP,
				param.TimeStamp.Format(time.RFC1123),
				param.Method,
				param.Path,
				param.Request.Proto,
				param.StatusCode,
				param.Latency,
				param.Request.UserAgent(),
				param.ErrorMessage,
		)
	}))
	router.Use(gin.Recovery())

see go-router.md for logger as middleWare

## log color

    // Force log's color
    gin.ForceConsoleColor()

    // Disable log's color
    gin.DisableConsoleColor()

## log file
https://gin-gonic.com/docs/examples/write-log/

    // Disable Console Color, you don't need console color when writing the logs to file.
    gin.DisableConsoleColor()

    // Logging to a file.
    f, _ := os.Create("gin.log")
    gin.DefaultWriter = io.MultiWriter(f)

    // Use the following code if you need to write the logs to file and console at the same time.
    // gin.DefaultWriter = io.MultiWriter(f, os.Stdout)

    router := gin.Default()
    router.GET("/ping", func(c *gin.Context) {
        c.String(200, "pong")
    })
