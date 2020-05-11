---
title: lua http
date: 2020-05-09
private: true
---
# lua http
## install 
	$ luarocks install luasocket

usage:

    text, status_code, headers = 
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

## request
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

## headers
MIME headers are represented as a Lua table in the form:

    headers = {
        field-1-name = field-1-value,
    }

## auth
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
