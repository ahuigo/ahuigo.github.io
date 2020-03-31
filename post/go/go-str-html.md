---
title: go str html
date: 2020-03-31
private: true
---
# go str html
    package main

    import (
        "fmt"
    )

    func main() {
        
        const emailTmpl = `Hi {{.Name}}!

    Your account is ready, your user name is: {{.UserName}}

    You have the following roles assigned:
    {{range $i, $r := .Roles}}{{if $i}}, {{end}}{{.}}{{end}}
    `
        fmt.Println("Hello, playground", emailTmpl)
        
        
            var s2 string
        s1:="h1llo"
        s2="hello"
        s2="a"
        fmt.Printf("%p,%p\n", &s1, &s2)

    }
