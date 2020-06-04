---
title: ruby http
date: 2020-06-04
private: true
---
# ruby url
## escape
URI 默认内置, cgi/erb 不是内置的

    require "cgi"
    require "erb"

    URI.escape # alias to URI.encode
    URI.unescape # alias to URI.decode
    URI.encode_www_form_component
    URI.decode_www_form_component
    ERB::Util.url_encode
    CGI.escape
    CGI.unescape

# cookie
    h = {'cookie1' => 'val1', 'cookie2' => 'val2'}
    req['Cookie'] = h.map { |k,v| "#{k}=#{URI.escape v}" } .join('; ')

# net/http
    require "net/https"
    require "uri"

    uri = URI.parse("https://www.secure.com/")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(uri.request_uri)
    res = http.request(request)

    res.code #=> "200"

## get
    uri = URI('https://bearer.sh')
    response = Net::HTTP.get_response(uri)

## post
### form
    uri = URI('https://bearer.sh')
    response = Net::HTTP.post_form(uri, 'q' => 'Bearer')
    puts response.code, response.body

# Faraday
    response = Faraday.post("https://bearer.sh", '{"title": "Bearer Rocks!"}', "Content-Type" => "application/json")
    puts response.status, response.body