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

## middleware order
由于middleware 在get后，所以只控制POST，不控制GET

    osmDomain.GET("/get", func1)
    osmDomain.Use(middleware.Auth())
    osmDomain.POST("/post", func2)

## custom abort middleWare
    func Logger() gin.HandlerFunc {
        return func(c *gin.Context) {
            t := time.Now()

            // Set example variable
            c.Set("example", "12345")

            if true {
                c.JSON(http.StatusUnauthorized, gin.H{"message": "hey", "status": http.StatusOK})
                c.Abort() //暂停冒泡
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

Abort(禁止冒泡)+JSON

    AbortWithStatusJSON(code int, jsonObj interface{})


注意：middleware 是洋葱模型
1. 如果middleware 没有c.Next() 它会隐式调用c.Next
2. 如果调用c.Abort() 会阻止捕获、不会阻止冒泡

## middleware catch exception
我们写一个自动捕获异常信息的中件件

    func Error() gin.HandlerFunc {
        return func(c *gin.Context) {
            defer func() {
                if r := recover(); r != nil {
                    c.String(
                        http.StatusInternalServerError,
                        fmt.Sprintf("%v", r)+"\n"+string(debug.Stack()),
                    )
                    c.Abort()
                }
            }()
            c.Next()

            if messages := c.Errors.Errors(); len(messages) > 0 && c.Writer.Size() == 0 {
                bodyError := struct {
                    Message string `json:"message"`
                }{Message: strings.Join(messages, "\n")}
                if body, err := json.Marshal(bodyError); err != nil {
                    logging.GetLogger("").Error(err.Error())
                } else {
                    c.Writer.Write(body)
                }
            }
        }
    }

## context inside a middleware
> https://gin-gonic.com/docs/examples/goroutines-inside-a-middleware/
you **SHOULD NOT** use the original context inside it, 因为context 会被copy（无锁）

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

## 跳过middleware
通过新的group 跳过middleware

	e := gin.New()
	r := e.Group("") //它跳过.CORS
    e.Use(middleware.CORS())

或者延后绑定router

    r.GET("/list", GetList)
    r.Use(middleware.Auth())
    r.POST("", AddItem)

# write response 
## response header and body
go-lib/gonic/middleware/resp-body.go (Refer to https://github.com/gin-gonic/gin/issues/1363)

    /********** responseBodyWriter ******************/
    type responseBodyWriter struct {
        gin.ResponseWriter
        body *bytes.Buffer //cache
    }

    func (r responseBodyWriter) Write(b []byte) (int, error) {
        r.body.Write(b)
        return r.ResponseWriter.Write(b)
    }

    func (r responseBodyWriter) WriteString(s string) (n int, err error)  {
        r.body.WriteString(s)
        return r.ResponseWriter.WriteString(s)
    }



    /********** replace responseBodyWriter ******************/
    func logResponseBody(c *gin.Context) {
        w := &responseBodyWriter{body: &bytes.Buffer{}, ResponseWriter: c.Writer}
        c.Writer = w
        c.Next()
        fmt.Println("Response body: " + w.body.String())
    }
