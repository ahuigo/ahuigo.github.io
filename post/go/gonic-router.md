---
title: Gonic router
date: 2019-09-18
private:
---
# Gonic router

## run router
### router.run
	router := gin.New() 
	router := gin.Default() // Default With the Logger and Recovery middleware already attached
	router.Run(":8080")

### router with http wrap
    func main() {
        router := gin.Default()
        http.ListenAndServe(":8080", router)
    }

router with http.server config: 

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

可以有多个server, 参考：https://gin-gonic.com/docs/examples/run-multiple-service/

	var g errgroup.Group
    g.Go(func() error {
		return server01.ListenAndServe()
	})

	g.Go(func() error {
		return server02.ListenAndServe()
	})

	if err := g.Wait(); err != nil {
		log.Fatal(err)
	}

## static
    //./public/index.html
	router.Static("/", "./public")

## router group
	// Simple group: v2
	v2 := router.Group("/v2")
	{
		v2.POST("/login", loginEndpoint)
		v2.POST("/submit", submitEndpoint)
		v2.POST("/read", readEndpoint)
	}

### group with BasicAuth

	authorized := r.Group("/", gin.BasicAuth(gin.Accounts{
		"foo":  "bar", // user:foo password:bar
		"manu": "123", // user:manu password:123
	}))

	authorized.POST("admin", func(c *gin.Context) {
		user := c.MustGet(gin.AuthUserKey).(string)

		// Parse JSON
		var json struct {
			Value string `json:"value" binding:"required"`
		}

		if c.Bind(&json) == nil {
			db[user] = json.Value
			c.JSON(http.StatusOK, gin.H{"status": "ok"})
		}
	})

try:

    curl -H 'Content-type:application/json' http://foo:bar@localhost:8080/admin -d '{"value":"abc"}'

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
