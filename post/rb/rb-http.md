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

## url info
    uri = URI("http://www.example.com:80/something?param1=value1&param2=value2&param3=value3")
    uri.query
    uri.path

### query:
    Rack::Utils.parse_query URI("http://example.com?par=hello&par2=bye").query
    { "par" => "hello", "par2" => "bye" } 

    Rack::Utils.build_query URI("http://example.com?par=hello&par2=bye").query

parse query

    require 'cgi'
    CGI::parse('param1=value1&param2=value2&param3=value3')
    // {"param1"=>["value1"], "param2"=>["value2"], "param3"=>["value3"]}
    URI::decode_www_form(uri.query).to_h # if you are in 2.1 or later version of Ruby
    # => {"param1"=>"value1", "param2"=>"value2", "param3"=>"value3"}




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