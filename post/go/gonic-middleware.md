---
title: gonic middleware
date: 2020-04-26
private: true
---
# gonic middleware
## Use MiddleWare for router/group
https://gin-gonic.com/docs/examples/using-middleware/

    func main() {
        // Creates a router without any middleware by default
        r := gin.New()

        // Global middleware
        // Logger middleware will write the logs to gin.DefaultWriter even if you set with GIN_MODE=release.
        // By default gin.DefaultWriter = os.Stdout
        r.Use(gin.Logger())

        // Recovery middleware recovers from any panics and writes a 500 if there was one.
        r.Use(gin.Recovery())

        // Per route middleware, you can add as many as you desire. MyBenchLogger() is middleWare
        r.GET("/benchmark", MyBenchLogger(), benchEndpoint)

        // Authorization group
        // authorized := r.Group("/", AuthRequired())
        // exactly the same as:
        authorized := r.Group("/")
        // per group middleware! in this case we use the custom created
        // AuthRequired() middleware just in the "authorized" group.
        authorized.Use(AuthRequired())
        {
            authorized.POST("/login", loginEndpoint)
            authorized.POST("/submit", submitEndpoint)
            authorized.POST("/read", readEndpoint)

            // nested group
            testing := authorized.Group("testing")
            testing.GET("/analytics", analyticsEndpoint)
        }

        // Listen and serve on 0.0.0.0:8080
        r.Run(":8080")
    }

## custom abort middleWare
    func Logger() gin.HandlerFunc {
        return func(c *gin.Context) {
            t := time.Now()

            // Set example variable
            c.Set("example", "12345")

            if true {
                c.JSON(http.StatusUnauthorized, gin.H{"message": "hey", "status": http.StatusOK})
                c.Abort()
                return //没有return 的话，gonic 会继续执行after request
            }

            // next  middleware
            c.Next()

            // after request
            latency := time.Since(t)
            log.Print(latency)

            // access the status we are sending
            status := c.Writer.Status()
            log.Println(status)
        }
    }

    func main() {
        r := gin.New()
        r.Use(Logger())
    }

Abort+JSON

    AbortWithStatusJSON(code int, jsonObj interface{})

## inside a middleware
you **SHOULD NOT** use the original context inside it, 因为context 会变（无锁）

    func main() {
        r := gin.Default()

        r.GET("/long_async", func(c *gin.Context) {
            // create copy to be used inside the goroutine
            cCp := c.Copy()
            go func() {
                // simulate a long task with time.Sleep(). 5 seconds
                time.Sleep(5 * time.Second)

                // note that you are using the copied context "cCp", IMPORTANT
                log.Println("Done! in path " + cCp.Request.URL.Path)
            }()
        })

        r.GET("/long_sync", func(c *gin.Context) {
            // simulate a long task with time.Sleep(). 5 seconds
            time.Sleep(5 * time.Second)

            // since we are NOT using a goroutine, we do not have to copy the context
            log.Println("Done! in path " + c.Request.URL.Path)
        })

        // Listen and serve on 0.0.0.0:8080
        r.Run(":8080")
    }