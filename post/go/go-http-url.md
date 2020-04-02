---
title: go http url
date: 2020-03-29
private: true
---
# go net/url

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

    url.RawQuery = q.Encode()
    fmt.Println(url)

### parse query
    query, _:= url.ParseQuery(`x=1&y=2&y=3;z`)
    //map[x:[1] y:[2 3] z:[]]

## urlInfo
    u, _:= url.Parse("http://bing.com/search?q1=dotnet")
	u.Scheme = "https"
	u.Host = "google.com"
	q := u.Query()
	q.Set("q", "golang")
	u.RawQuery = q.Encode()

    fmt.Println(u)

build url

    fmt.Println(u.String())

