---
title: Gonic router
date: 2019-09-18
private:
---
# Gonic router

## NewSingleHostReverseProxy

	ketoURL, _ := url.Parse("http://keto.com/base")
	ketoProxy := httputil.NewSingleHostReverseProxy(ketoURL)
	ketoHandler := func(c *gin.Context) {
		c.Request.Host = ketoURL.Host
		ketoProxy.ServeHTTP(c.Writer, c.Request)
	}
    // 转发的地址是：http://keto.com/base/engines/acp/ory/xxx/xxx
	e.Any("engines/acp/ory/:flavor/:resouces", ketoHandler)
