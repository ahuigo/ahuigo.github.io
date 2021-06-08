---
title: Gonic router
date: 2019-09-18
private:
---
# Gonic router

## NewSingleHostReverseProxy

	ketoHandler := func(c *gin.Context) {
        ketoURL, _ := url.Parse("http://keto.com/base")
		c.Request.Host = ketoURL.Host
        proxy:= httputil.NewSingleHostReverseProxy(ketoURL)
		proxy.ServeHTTP(c.Writer, c.Request)
	}
    // 转发的地址是：http://keto.com/base/engines/acp/ory/xxx/xxx
	e.Any("engines/acp/ory/:flavor/:resouces", ketoHandler)


## ReverseProxy

    router.POST("/api/v1/endpoint1", func(c *gin.Context) {
        director := func(req *http.Request) {
            r := c.Request
            req = r
            req.URL.Scheme = "http"
            req.URL.Host = "localhost:3000"
            req.Header["my-header"] = []string{r.Header.Get("my-header")}
            // Golang camelcases headers
            delete(req.Header, "My-Header")
        }
        proxy := &httputil.ReverseProxy{Director: director}
        proxy.ServeHTTP(c.Writer, c.Request)
    })
