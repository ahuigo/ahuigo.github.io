---
title: Golang response
date: 2019-10-03
private:
---
# Response
## error

    // 给Error 中间件 传 c.Errors.Errors() 
    c.AbortWithError(http.StatusBadRequest, errors.New("no task_id"))

默认不输出errors, 不过middleware 可以冒泡得到errors

    messages := c.Errors.Errors()

## string
    c.String(http.StatusOK, name)
    c.String(http.StatusBadRequest, "no task_id")
    c.String(http.StatusBadRequest, err.Error())

## JSON
    // gin.H is a shortcut for map[string]interface{}
    c.JSON(http.StatusOK, gin.H{"user": user, "value": value})
    c.JSON(http.StatusOK, structA{"user": user, "value": value})
    ctx.JSON(http.StatusOK, map[string]string{"message": "state"})

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

# header
## header
    func (c *Context) Header(key, value string) {
        if value == "" {
            c.Writer.Header().Del(key)
            return
        }
        c.Writer.Header().Set(key, value)
    }

## cookie

	ctx.SetSameSite(http.SameSiteLaxMode)
	ctx.SetCookie("key", "value", 86400, "ahuigo.com", "", false, false)

### custom cookie
	idTokenCookieStr := fmt.Sprintf("id_token=%s; Domain=%s; Max-Age=%d; SameSite=None", url.QueryEscape(res["id_token"].(string)), cookieDomain, timeout)
	ctx.Writer.Header().Add("Set-Cookie", idTokenCookieStr)

或

	ctx.Writer.Header().Add("Set-Cookie", (&http.Cookie{
		Name:     "id_token2",
		Value:    url.QueryEscape(res["id_token"].(string)),
		MaxAge:   timeout,
		Path:     "",
		Domain:   cookieDomain,
		SameSite: 3,
		Secure:   true,
		HttpOnly: false,
	}).String())

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
设定模板变量的分割符

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

# 高级
## shell pipe to response
    func (c *gin.Context){
        // var stdout bytes.Buffer
        var stderr bytes.Buffer
        command = exec.Command("sh", "-c", "echo begin && sleep 3 && cmd-not-existed||echo ok")
        command.Stdout = c.Writer
        command.Stderr = &stderr
        err := command.Run()
        if err != nil {
            c.AbortWithError(http.StatusBadRequest, err)
            return
        }
    }