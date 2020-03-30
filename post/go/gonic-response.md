---
title: Golang response
date: 2019-10-03
private:
---
# Response
## JSON
    // gin.H is a shortcut for map[string]interface{}
    c.JSON(http.StatusOK, gin.H{"user": user, "value": value})
    c.JSON(http.StatusOK, structA{"user": user, "value": value})

### PureJSON
避免将 `<` 转成`\u003c`:

    c.PureJSON(200, gin.H{ "html": "<b>Hello, world!</b>", })

## XML
    c.XML(http.StatusOK, gin.H{"message": "hey", "status": http.StatusOK})

## YAML

    c.YAML(http.StatusOK, gin.H{"message": "hey", "status": http.StatusOK})

## ProtoBuf
https://gin-gonic.com/docs/examples/rendering/

    reps := []int64{int64(1), int64(2)}
    label := "test"
    // The specific definition of protobuf is written in the testdata/protoexample file.
    data := &protoexample.Test{
        Label: &label,
        Reps:  reps,
    }
    // Note that data becomes binary data in the response
    // Will output protoexample.Test protobuf serialized data
    c.ProtoBuf(http.StatusOK, data)

## string
    c.String(http.StatusOK, name)

## Redirect
	c.Redirect(http.StatusMovedPermanently, "http://www.google.com/")

Issuing a Router redirect, use `HandleContext` like below.

    r.GET("/test", func(c *gin.Context) {
        c.Request.URL.Path = "/test2"
        r.HandleContext(c)
    })
    r.GET("/test2", func(c *gin.Context) {
        c.JSON(200, gin.H{"hello": "world"})
    })

## reader and header
    router.GET("/someDataFromReader", func(c *gin.Context) {
		response, err := http.Get("https://raw.githubusercontent.com/gin-gonic/logo/master/color.png")
		if err != nil || response.StatusCode != http.StatusOK {
			c.Status(http.StatusServiceUnavailable)
			return
		}

		reader := response.Body
		contentLength := response.ContentLength
		contentType := response.Header.Get("Content-Type")

		extraHeaders := map[string]string{
			"Content-Disposition": `attachment; filename="gopher.png"`,
		}

		c.DataFromReader(http.StatusOK, contentLength, contentType, reader, extraHeaders)
	})

## Html

### LoadHTMLGlob
    func main() {
        router := gin.Default()
        router.LoadHTMLGlob("templates/**/*")
        router.GET("/posts/index", func(c *gin.Context) {
            c.HTML(http.StatusOK, "posts/index.tmpl", gin.H{
                "title": "Posts",
            })
        })
        router.GET("/users/index", func(c *gin.Context) {
            c.HTML(http.StatusOK, "users/index.tmpl", gin.H{
                "title": "Users",
            })
        })
        router.Run(":8080")
    }

templates/posts/index.tmpl， `define-end`不是必须的，只是方便引入?

    {{ define "posts/index.tmpl" }}
    <html><h1>
        {{ .title }}
    </h1>
    </html>
    {{ end }}

### Static
    // access local:8080/assets/a.js
    r.Static("/assets", "./assets")

    // static dir
	r.StaticFS("/more_static", http.Dir("my_file_system"))

    // static file
	r.StaticFile("/favicon.ico", "./resources/favicon.ico")

### Custom Template renderer
    import "html/template"

    func main() {
        router := gin.Default()
        html := template.Must(template.ParseFiles("file1", "file2"))
        router.SetHTMLTemplate(html)
        router.GET("/raw", func(c *gin.Context) {
            c.HTML(http.StatusOK, "file1")
        })
        router.Run(":8080")
    }

also:

    var html = template.Must(template.New("file1").Parse(` <html> </html> `))

### LoadHTMLFiles

    // store raw.tmpl
    router.LoadHTMLFiles("./testdata/raw.tmpl")

    router.GET("/raw", func(c *gin.Context) {
        c.HTML(http.StatusOK, "raw.tmpl", map[string]interface{}{
            "now": time.Date(2017, 07, 01, 0, 0, 0, 0, time.UTC),
        })
    })

### Dlimiter
	r := gin.Default()
	r.Delims("{[{", "}]}")
	r.LoadHTMLGlob("/path/to/templates")

### Pipe Func
	import "html/template"

    func formatAsDate(t time.Time) string {
        year, month, day := t.Date()
        return fmt.Sprintf("%d%02d/%02d", year, month, day)
    }

    func main() {
        router := gin.Default()
        router.Delims("{[{", "}]}")
        router.SetFuncMap(template.FuncMap{
            "formatAsDate": formatAsDate,
        })
        router.LoadHTMLFiles("./testdata/raw.tmpl")

        router.GET("/raw", func(c *gin.Context) {
            c.HTML(http.StatusOK, "raw.tmpl", map[string]interface{}{
                "now": time.Date(2017, 07, 01, 0, 0, 0, 0, time.UTC),
            })
        })

raw.tmpl

    Date: {[{.now | formatAsDate}]}

# MiddleWare
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
# http2 and push
https://gin-gonic.com/docs/examples/http2-server-push/
> pem 生成见ssl-tool.md

    r := gin.Default()
	r.Static("/assets", "./assets")
	r.SetHTMLTemplate(html)

	r.GET("/", func(c *gin.Context) {
		if pusher := c.Writer.Pusher(); pusher != nil {
			// use pusher.Push() to do server push
			if err := pusher.Push("/assets/app.js", nil); err != nil {
				log.Printf("Failed to push: %v", err)
			}
		}
		c.HTML(200, "https", gin.H{
			"status": "success",
		})
	})

	// Listen and Server in https://127.0.0.1:8080
	r.RunTLS(":8080", "./testdata/server.pem", "./testdata/server.key")

# LetsEncrypt
example for 1-line LetsEncrypt HTTPS servers.

    package main

    import (
        "log"

        "github.com/gin-gonic/autotls"
        "github.com/gin-gonic/gin"
    )

    func main() {
        r := gin.Default()

        // Ping handler
        r.GET("/ping", func(c *gin.Context) {
            c.String(200, "pong")
        })

        log.Fatal(autotls.Run(r, "example1.com", "example2.com"))
    }

example for custom autocert manager.

    package main

    import (
        "log"

        "github.com/gin-gonic/autotls"
        "github.com/gin-gonic/gin"
        "golang.org/x/crypto/acme/autocert"
    )

    func main() {
        r := gin.Default()

        // Ping handler
        r.GET("/ping", func(c *gin.Context) {
            c.String(200, "pong")
        })

        m := autocert.Manager{
            Prompt:     autocert.AcceptTOS,
            HostPolicy: autocert.HostWhitelist("example1.com", "example2.com"),
            Cache:      autocert.DirCache("/var/www/.cache"),
        }

        log.Fatal(autotls.RunWithManager(r, &m))
    }