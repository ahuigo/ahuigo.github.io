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

# debug
hot reload code, 如果想修改代码时让请求生效，那么修改下面的配置

    //vi config/environment/production.rb
    config.cache_classes = false
    config.eager_load = false
    config.file_watcher = ActiveSupport::FileUpdateChecker

## passenger
    passenger start -e development

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