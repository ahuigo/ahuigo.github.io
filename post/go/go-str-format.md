---
title: go str html
date: 2020-03-31
private: true
---
# fmt
## .Sprint any type
    i := 23
    s := fmt.Sprint("[age:", i, "]") 
        // s will be "[age:23]"

    s := fmt.Sprint("[age:",true, i,[]int{4,5},  "]") 
        [age:true 23 [4 5]]


## Print string
> see go-fmt
1. `printf` is equivalent to writing `fprintf(stdout, ...)` and writes formatted text to `standard output stream`
2. `sprintf` writes formatted text to an `array of char`, as opposed to a stream.

A string is in effect a read-only slice of bytes.

    "3132" == fmt.Sprintf("%x", "12")
    "3132" == fmt.Sprintf("%x", 0x3132)

quoted string as go syntax

    fmt.Printf("%q\n", "中\x00sample")
    // "中\x00sample"
    fmt.Printf("%+q\n", "中\x00sample")
    //"\u4e2d\x00sample"

#  text/template and html/template. 
html/template is for generating HTML output safe against code injection. 

template + data:

    const emailTmpl = `Hi {{.Name}}!
    Your account is ready, your user name is: {{.UserName}}

    You have the following roles assigned:
    {{range $i, $r := .Roles}}{{if $i}}, {{end}}{{.}}{{end}}
    `

    data := map[string]interface{}{
        "Name":     "Bob",
        "UserName": "bob92",
        "Roles":    []string{"dbteam", "uiteam", "tester"},
    }

 Executing the template and getting the result as string:

    t := template.Must(template.New("email").Parse(emailTmpl))
    buf := &bytes.Buffer{}
    if err := t.Execute(buf, data); err != nil {
        panic(err)
    }
    s := buf.String()

write to `os.Stdout`

    t := template.Must(template.New("email").Parse(emailTmpl))
    if err := t.Execute(os.Stdout, data); err != nil {
        panic(err)
    }

full example: go-lib/str/format.go