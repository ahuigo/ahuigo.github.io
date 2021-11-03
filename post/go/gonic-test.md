---
title: gonic unittest
date: 2020-05-25
private: true
---
# test with router.ServeHTTP
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
        router := createRouter()

        resp := httptest.NewRecorder()
        // req, _ := http.NewRequest("POST", "/ping", bytes.NewReader(jsonByte))
        req := requests.BuildRequest("GET", "http://localhost:8080/api/v1/method", requests.Params{
            "abc": "cc",
        })
        router.ServeHTTP(resp, req)

        assert.Equal(t, 200, resp.Code)
        assert.Equal(t, "pong", resp.Body.String())
    }

# mock context
不用构建testRouter, 只构建context

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
    cookie := http.Cookie{Name: "token", Value: "xxx"}
    req.AddCookie(&cookie)

    // add request
    context.Request = req

    // 请求controller
    router.Controller.GetIndex(context)

    // test response
    assert.Equal(t, "pong", w.Body.String())
    println(context.Errors)

实际项目的代码

    func creaetCtx(req)(*http.ResponseWriter, *gonic.Context){
        w := httptest.NewRecorder()
        context, _ := gin.CreateTestContext(w)
        context.Request = req
        return w,context
    }

    var data interface{} = map[string]interface{}{"id":1}
    body, err := json.Marshal(data)
    req, _ := http.NewRequest("GET", "/api/v1/queue", bytes.NewBuffer(body))
    w, ctx := createCtx(req)
	r.monitorAPISrv.StartMonitorSrv(ctx)
