---
title: Gonic router
date: 2019-09-18
private:
---
# Gonic router
	router := gin.Default()
	router.Run(":8080")

## listen
    func main() {
        router := gin.Default()
        http.ListenAndServe(":8080", router)
    }
    or

    func main() {
        router := gin.Default()

        //net/http
        s := &http.Server{
            Addr:           ":8080",
            Handler:        router,
            ReadTimeout:    10 * time.Second,
            WriteTimeout:   10 * time.Second,
            MaxHeaderBytes: 1 << 20,
        }
        //s.ListenAndServe()
        f err := s.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("listen: %s\n", err)
		}
    }

## static
    //./public/index.html
	router.Static("/", "./public")

## router map
	// Simple group: v2
	v2 := router.Group("/v2")
	{
		v2.POST("/login", loginEndpoint)
		v2.POST("/submit", submitEndpoint)
		v2.POST("/read", readEndpoint)
	}

## shutdown & stop
https://gin-gonic.com/docs/examples/graceful-restart-or-stop/

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	if err := srv.Shutdown(ctx); err != nil {
		log.Fatal("Server Shutdown:", err)
	}
	// catching ctx.Done(). timeout of 5 seconds.
	select {
	case <-ctx.Done():
		log.Println("timeout of 5 seconds.")
        log.Println("Server exiting")
	}

# MiddleWare
    func Logger() gin.HandlerFunc {
        return func(c *gin.Context) {
            t := time.Now()

            // Set example variable
            c.Set("example", "12345")

            // before request

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