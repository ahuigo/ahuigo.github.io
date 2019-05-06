---
title: go http
private:
date: 2019-05-06
---
# go http

    resp, err := http.Get("http://example.com/")
    ...
    resp, err := http.Post("http://example.com/upload", "image/jpeg", &buf)
    ...
    resp, err := http.PostForm("http://example.com/form", url.Values{"key": {"Value"}, "id": {"123"}})

close body

    resp, err := http.Get("http://example.com/")
    if err != nil {
        // handle error
    }
    defer resp.Body.Close()
    body, err := ioutil.ReadAll(resp.Body)

header:

    client := &http.Client{
        CheckRedirect: redirectPolicyFunc,
    }

    resp, err := client.Get("http://example.com")
    // ...

    req, err := http.NewRequest("GET", "http://example.com", nil)
    // ...
    req.Header.Add("If-None-Match", `W/"wyzzy"`)
    resp, err := client.Do(req)
    // ...