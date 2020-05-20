---
title: lua http
date: 2020-05-09
private: true
---
# luasocket
	$ luarocks install luasocket

## request
    http = require("socket.http")
    http.request(url [, body])
    http.request{
        url = string,
        [sink = LTN12 sink,]
        [method = string,]
        [headers = header-table,]
        [source = LTN12 source],
        [step = LTN12 pump step,]
        [proxy = string,]
        [redirect = boolean,]
        [create = function]
    }

### headers
MIME headers are represented as a Lua table in the form:

    headers = {
        field-1-name = field-1-value,
    }

### auth
    http = require("socket.http")
    mime = require("mime")

    b, c, h = http.request("http://fulano:silva@www.example.com/private/index.html")

    -- Alternatively, one could fill the appropriate header and authenticate
    -- the request directly.
    b, c, h = http.request {
        url = "http://www.example.com/private/index.html",
        headers = { authentication = "Basic " .. (mime.b64("fulano:silva")) }
    }

### method

    http = require("socket.http")

    -- Requests information about a document, without downloading it.
    r, c, h = http.request {
        method = "HEAD", url = "http://www.tecgraf.puc-rio.br/~diego"
    }

## response

# openresty http
https://github.com/ledgetech/lua-resty-http#request_uri

    syntax: res, err = httpc:request(params)

The params table accepts the following fields:

    version 
        The HTTP version number, currently supporting 1.0 or 1.1.
    method 
        The HTTP method string.
    path 
        The path string.
    query 
        The query string, presented as either a literal string or Lua table..
    headers 
        A table of request headers.
    body 
        The request body as a string, or an iterator function (see get_client_body_reader).
    ssl_verify 
        Verify SSL cert matches hostname

## post
post 必须加 content-type

    local http = require "resty.http"
      local httpc = http.new()
      local res, err = httpc:request_uri("http://example.com/helloworld", {
        method = "POST",
        body = "a=1&b=2",
        headers = {
          ["Content-Type"] = "application/x-www-form-urlencoded",
          ["x"] = "d",
        },
        keepalive_timeout = 60000,
        keepalive_pool = 10
      })