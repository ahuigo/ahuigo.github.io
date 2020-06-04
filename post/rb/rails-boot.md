---
title: rails boot sequence
date: 2020-06-04
private: true
---
# rails boot sequence
启动代码顺序

大家知道 Rails 项目启动的时候会由 puma 之类的服务器调用 config.ru 文件:

## config.ru
    // config.ru
    require_relative 'config/environment'
    run Rails.application

## config/environment.rb
    require_relative 'application'
    Rails.application.initialize!

## initialize
initialize 会执行middleware

    # railties-5.1.6/lib/rails/application/finisher.rb#Line44
    initializer :build_middleware_stack do
        build_middleware_stack
    end

build_middleware_stack 是 app的别名. 它会生成实例`@app`

    # railties-5.1.6/lib/rails/engine.rb#Line503
    def app
      @app || @app_build_lock.synchronize {
        @app ||= begin
          stack = default_middleware_stack
          config.middleware = build_middleware.merge_into(stack)
          config.middleware.build(endpoint)
        end
      }
    end

它里面做了什么生成@app 呢？下面继续说
### config.middleware
其中调用 config.middleware.build 构建中间件， 
这个build 最后会返回 YourProject::Application.routes，也就是 rails middleware 这个指令输出的最后一个所谓的中间件