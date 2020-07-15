---
title: go requests
date: 2020-07-14
private: true
---
# go requests

## get
    import "github.com/asmcos/requests"
    resp,err := requests.Get("http://go.xiulian.net.cn")
    println(resp.Text())

## Post

    data := requests.Datas{
        "name":"requests_post_test",
    }
    resp,_ := requests.Post("https://www.httpbin.org/post",data)
    println(resp.Text())

# set req
## Set header
### 全局与局部header
``` go
req := requests.Requests()
req.Header.Set("accept-encoding", "gzip, deflate, br")
resp,_ := req.Get("http://go.xiulian.net.cn",requests.Header{"Referer":"http://www.jeapedu.com"})
println(resp.Text())

```

### multiple header argv
``` go
h := requests.Header{
  "Referer":         "http://www.jeapedu.com",
  "Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8",
}
h2 := requests.Header{
  ...
  ...
}
h3,h4 ....
// two or more headers ...
resp,_ = req.Get("http://go.xiulian.net.cn",h,h2,h3,h4)
```


## Set params
    p := requests.Params{
    "title": "The blog",
    "name":  "file",
    }
    resp,_ := req.Get("http://www.cpython.org", p)



## Auth
    req := requests.Requests()
    resp,_ := req.Get("https://api.github.com/user",requests.Auth{"asmcos","password...."})

# Response
## JSON

    req := requests.Requests()
    req.Header.Set("Content-Type","application/json")
    resp,_ = req.Get("https://httpbin.org/json")

    var json map[string]interface{}
    _ := resp.Json(&json)

    for k,v := range json{
        fmt.Println(k,v)
    }


## SetTimeout

    req := Requests()
    req.Debug = 1

    // 20 Second
    req.SetTimeout(20)
    req.Get("http://golang.org")

## Get Cookies

    resp,_ = req.Get("https://www.httpbin.org")
    coo := resp.Cookies()
    // coo is [] *http.Cookies
    println("********cookies*******")
    for _, c:= range coo{
        fmt.Println(c.Name,c.Value)
    }
