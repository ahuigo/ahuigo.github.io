---
title: Golang response
date: 2019-10-03
private:
---

# Response HTML

## data

    // ctx.String(http.StatusOK, html)
    ctx.Render(http.StatusOK, render.Data{
        ContentType: "text/html",
        Data:        []byte(html),
    })

## html

    ctx.HTML(http.StatusOK, "raw.tmpl", map[string]interface{}{
		"url": url,
		"data":1,
	})

# html/template 语法
参考：

    https://pkg.go.dev/text/template#hdr-Variables
    gonic/template/maing.go

## range

    {{ range $key, $value := . }}
        <li><strong>{{ $key }}</strong>: {{ $value }}</li>
    {{ end }}

# variable
    {{"\"output\""}}
        A string constant.
    {{`"output"`}}
        A raw string constant.
    {{printf "%q" "output"}}
        A function call.
    {{"output" | printf "%q"}}
        A function call whose final argument comes from the previous
        command.
    {{printf "%q" (print "out" "put")}}
        A parenthesized argument.
    {{"put" | printf "%s%s" "out" | printf "%q"}}
        A more elaborate call.
    {{"output" | printf "%s" | printf "%q"}}
        A longer chain.
    {{with "output"}}{{printf "%q" .}}{{end}}
        A with action using dot.
    {{with $x := "output" | printf "%q"}}{{$x}}{{end}}
        A with action that creates and uses a variable.
    {{with $x := "output"}}{{printf "%q" $x}}{{end}}
        A with action that uses the variable in another action.
    {{with $x := "output"}}{{$x | printf "%q"}}{{end}}
        The same, but pipelined.

## map

    {{index .Amap "key1"}}
    {{.Amap.key1}}

Amap

    {{index .Amap 1 2 3}}

