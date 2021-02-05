---
title: gonic unittest
date: 2020-05-25
private: true
---
# gonic unittest
The net/http/httptest package is preferable way for HTTP testing.

    package main

    func setupRouter() *gin.Engine {
        r := gin.Default()
        r.GET("/ping", func(c *gin.Context) {
            c.String(200, "pong")
        })
        return r
    }

    func main() {
        r := setupRouter()
        r.Run(":8080")
    }

Test for code example above:

    package main

    import (
        "net/http"
        "net/http/httptest"
        "testing"

        "github.com/stretchr/testify/assert"
    )

    func TestPingRoute(t *testing.T) {
        router := setupRouter()

        w := httptest.NewRecorder()
        req, _ := http.NewRequest("GET", "/ping", nil)
        router.ServeHTTP(w, req)

        assert.Equal(t, 200, w.Code)
        assert.Equal(t, "pong", w.Body.String())
    }

# mock context

    w := httptest.NewRecorder()
    context,engine := gin.CreateTestContext(w)

## mock test context
gin.CreateTestContext

    func CreateTestContext(w http.ResponseWriter) (c *Context, r *Engine) {
        r = New()
        c = r.allocateContext()
        c.reset()
        c.writermem.reset(w)
        return
    }


## mock request

    w := httptest.NewRecorder()
    context, _ := gin.CreateTestContext(w)

    // init request
    req, _ := http.NewRequest("GET", "/ping", nil)

    // Cookie
    cookie := http.Cookie{Name: "token", Value: "xxx"}
    req.AddCookie(&cookie)

    // add request
    context.Request = req

    // 请求controller
    router.Controller.GetIndex(context)


    // test response
    assert.Equal(t, "pong", w.Body.String())
