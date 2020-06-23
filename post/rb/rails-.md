---
title: rails router
date: 2020-06-02
private: true
---
# rails router
    get 'welcome/index'

# controller
    class ArticlesController < ApplicationController
        def new
            render plain: "sabc"
        end
        def show
            @article = Article.find(params[:id])
        end
    end

## request
### request url
    "#{request.protocol}#{request.host_with_port}#{request.fullpath}"
    request.original_url # => "http://www.example.com/articles?page=2"
    request.fullpath    #=> /path?a=1
    request.method

### get and  post

    params[:name]

### cookie
get cookie

    token = cookies[:token]

set cookie

    cookies[:key] = "a yummy cookie"
    cookies[:key] = {
       :value => 'a yummy cookie',
       :expires => 1.year.from_now,
       :domain => 'domain.com'
     }

delete cookie

     cookies.delete(:key)
     cookies.delete :key,domain:'.ahuigo.com'

### session
get/set session:

    session[:referrer] = request.referrer
    referrer  = session.delete(:referrer)

### header
    request.headers["referer"]
    request.referrer

### host/port
    @hostname = request.host || "www.mydomain.com"
    request.protocol 
        https://
    request.host_with_port

## response
      response.headers["WWW-Authenticate"] = "Basic realm=\"#{realm}\""
      render :plain => errormessage, :status => :unauthorized  #401
      render :plain => errormessage, :status => 401   #401

json

    render :json => data, :status=>202

tmpl:

    render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)

### redirect
redirect

    redirect_to @post
    redirect_to "http://www.rubyonrails.org"
    redirect_to "/images/screenshot.jpg"
    redirect_to posts_url
    redirect_to proc { edit_post_url(@post) }

with status/msg

    redirect_to post_url(@post), status: :found
    redirect_to post_url(@post), status: 301
    redirect_to action: 'atom', status: 302

    redirect_to post_url(@post), alert: "Watch it, mister!"
    redirect_to post_url(@post), status: :found, notice: "Pay attention to the road"


基于routes 的redirect

    // params[:referer]
    redirect_to :controller => "user", :action => "login", :referer => request.fullpath
    redirect_to action: "show", id: 5

# config
https://blog.arkency.com/custom-application-configuration-variables-in-rails-4-and-5/

    // config/application.rb
    config.my_custom_setting = "WOW"
    config.x.external_api.timeout = 5

在controller 中使用


    Rails.configuration.x.external_api
    # => {:timeout=>5, :url=>"https://example.org/api/path"}

    Rails.configuration.x.external_api.timeout
    # => 5



# debug
> https://guides.rubyonrails.org/debugging_rails_applications.html

hot reload code, 如果想修改代码时让请求生效，那么修改下面的配置

    //vi config/environment/production.rb
    config.cache_classes = false
    config.eager_load = false
    config.file_watcher = ActiveSupport::FileUpdateChecker

## passenger
    passenger start -e development
    bundle exec passenger start -e development
    bundle exec passenger-config restart-app

## logger format
如果修改自定义format ，修改config/environment/production.rb

    # config.log_formatter = ::Logger::Formatter.new
    config.log_formatter = proc do | severity, time, progname, msg | 
        call_details = Kernel.caller[5].gsub(/#{Rails.root}/, '')
        msg = msg[38..-1]
        call_details.match /(.+):(.+):/
        filename = $1
        line = $2
        length = 40
        filename = "#{filename[-length, filename.length]}" if filename.length >= length
        filename = filename.rjust(length + 2, '.')
        "[#{severity} #{time.strftime('%m%dT%H:%M:%S')} #{filename}:#{line}] #{msg}\n"
    end


## log object

    logger.info obj.inspect