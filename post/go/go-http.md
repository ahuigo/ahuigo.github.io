---
title: go http
private:
date: 2019-05-06
---
# go http request

## 注意close body
如果body既没有被完全读取，也没有被关闭，那么这次http事务就没有完成，除非连接因超时终止了，否则相关资源无法被回收。

    defer resp.Body.Close()
    body, err := ioutil.ReadAll(resp.Body)

## get

    resp, err := http.Get("http://example.com/")


    StatusOK                   = 200 // RFC 7231, 6.3.1
    StatusCreated              = 201 // RFC 7231, 6.3.2
    StatusAccepted             = 202 // RFC 7231, 6.3.3
    StatusNonAuthoritativeInfo = 203 // RFC 7231, 6.3.4
    StatusNoContent            = 204 // RFC 7231, 6.3.5
    StatusResetContent         = 205 // RFC 7231, 6.3.6
    StatusPartialContent       = 206 // RFC 7233, 4.1
    StatusMultiStatus          = 207 // RFC 4918, 11.1
    StatusAlreadyReported      = 208 // RFC 5842, 7.1
    StatusIMUsed               = 226 // RFC 3229, 10.4.1
     StatusMovedPermanently = 301 // RFC 7231, 6.4.2
    StatusFound            = 302 // RFC 7231, 6.4.3
    StatusUnauthorized                 = 401 // RFC 7235, 3.1

## post

### post form
    resp, _ := http.PostForm("https://httpbin.org/post",
	url.Values{"key": {"Value"}, "id": {"123"}})
    pn := fmt.Println
    body, _:= ioutil.ReadAll(resp.Body)
    pn(string(body))

e.g.:

    values := make(url.Values)
    values.Set("user", user)

    // Submit form
    resp, err := http.PostForm(postUrl, values)

### post file
    resp, err := http.Post("http://example.com/upload", "image/jpeg", &buf)

## client
For control over HTTP client headers, redirect policy, and other settings, create a Client:

    client := &http.Client{
        CheckRedirect: redirectPolicyFunc,
    }

    resp, err := client.Get("http://example.com")
    // ...

### add header to client

    req, err := http.NewRequest("GET", "http://example.com", nil)
    // ...
    req.Header.Add("If-None-Match", `W/"wyzzy"`)
    resp, err := client.Do(req)

### timeout
    client := http.Client{
        Timeout: 5 * time.Second,
    }
    client.Get(url)

### store cookieJar
会在整个会话期间保持cookie

    import (
        "net/http"
        "net/http/cookiejar"
    )

    cookieJar, _ := cookiejar.New(nil)

    client := &http.Client{
        Jar: cookieJar,
    }

初始化 指定url:cookie

    type CookieJar interface {
        SetCookies(u *url.URL, cookies []*Cookie)
        Cookies(u *url.URL) []*Cookie
    }

### skip redirect

    client: &http.Client{
        CheckRedirect: func(req *http.Request, via []*http.Request) error {
            return http.ErrUseLastResponse
        },
    }

## auth
    req, err := http.NewRequest("GET", BASE_URL+"/tenants/current", nil)
    req.SetBasicAuth(STORMPATH_API_KEY_ID, STORMPATH_API_KEY_SECRET)

## Transport:proxies
For control over proxies, TLS configuration, keep-alives, compression, and other settings, create a Transport:

    tr := &http.Transport{
        MaxIdleConns:       10,
        IdleConnTimeout:    30 * time.Second,
        DisableCompression: true,
    }
    client := &http.Client{Transport: tr}
    resp, err := client.Get("https://example.com")

# response
## get location
    location, _ :=resp.Location() //*url.URL

## header:

    for k, v := range resp.Header{
		fmt.Printf("k=%v, v=%v\n", k, v)
	}
    for i, cookie := range resp.Cookies() {
        fmt.Println("cookie:",i, cookie.Name,'=', cookie.Value)
    }

## body
    buf := bytes.Buffer{}
	length, _ := buf.ReadFrom(resp.Body)

或

    buf, _:= ioutil.ReadAll(resp.Body)

# server
ListenAndServe starts an HTTP server with a given address and handler. The handler is usually nil, which means to use DefaultServeMux. Handle and HandleFunc add handlers to DefaultServeMux:

    http.Handle("/foo", fooHandler)

    http.HandleFunc("/bar", func(w http.ResponseWriter, r *http.Request) {
        fmt.Fprintf(w, "Hello, %q", html.EscapeString(r.URL.Path))
    })

    log.Fatal(http.ListenAndServe(":8080", nil))

More control over the server's behavior is available by creating a custom Server:

    s := &http.Server{
        Addr:           ":8080",
        Handler:        myHandler,
        ReadTimeout:    10 * time.Second,
        WriteTimeout:   10 * time.Second,
        MaxHeaderBytes: 1 << 20,
    }
    log.Fatal(s.ListenAndServe())

# cookie
## send cookie(http)

    expiration := time.Now().Add(5 * time.Minute)
    cookie := http.Cookie{Name: "myCookie", Value: "Hello World", Expires: expiration}
    http.SetCookie(w, &cookie)

## send cookie(client)

    //save cookie
    cookie = resp.Cookies() //save cookies

    // resend cookie
    req, _ := http.NewRequest("POST", url, nil)   
    for i := range cookie {
        req.AddCookie(cookie[i])
    }