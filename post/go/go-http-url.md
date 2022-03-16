---
title: go http url
date: 2020-03-29
private: true
---
# go net/url

## encode
    net/url
    fmt.Println("http://example.com/say?message="+url.QueryEscape(s))

## query: url.values
	v := url.Values{}
	v.Set("name", "Ava")
	v.Add("friend", "Jess")
	v.Add("friend", "Sarah")
	v.Add("friend", "Zoe")
	// v.Encode() == "name=Ava&friend=Jess&friend=Sarah&friend=Zoe"
	v.Get("name"))
	v.Get("friend"))
	v["friend"])

build url:

    url.RawQuery = query.Encode()
    fmt.Println(url)
    fmt.Println(url.String())

### parse query
    query, _:= url.ParseQuery(`x=1&y=2&y=3;z;q=a+b;c`)
    //map[x:[1] y:[2 3] z:[] q:[a b]]

## parseURL & addQuery

    u, _:= url.Parse("http://bing.com/search:8080?q1=dotnet")
    u.Scheme = "https"
    u.Host = "google.com" //Hostname()+Port()
    q := u.Query()
    q.Set("q", "golang")
    q.Add("name", "ahui")
    u.RawQuery = q.Encode()

    fmt.Println(u)

build url

    fmt.Println(u.String())