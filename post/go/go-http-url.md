---
title: go http url
date: 2020-03-29
private: true
---
# go net/url

## urlInfo
    u, _:= url.Parse("http://bing.com/search?q1=dotnet")
	u.Scheme = "https"
	u.Host = "google.com"
	q := u.Query()
	q.Set("q", "golang")
	u.RawQuery = q.Encode()

    fmt.Println(u)
    fmt.Println(u.String())

## query
    query, _:= url.ParseQuery(`x=1&y=2&y=3;z`)
    //map[x:[1] y:[2 3] z:[]]
