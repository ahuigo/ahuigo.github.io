---
title: rails boot sequence
date: 2020-06-04
private: true
---
# rails boot sequence
rails 启动代码顺序: https://ruby-china.github.io/rails-guides/initialization.html#loading-rails

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

它里面做了什么生成@app 呢？包括了：
1. 加中间件
2. ...
## config.middleware
其中调用 config.middleware.build 构建中间件， 
这个build 最后会返回 YourProject::Application.routes，也就是 rails middleware 这个指令输出的最后一个所谓的中间件

# 中间件
1. 写中间件
https://ieftimov.com/post/writing-rails-middleware/
2. 参考openstreetmap config/initializers/cors.rb

可以通过下述任意一种方法向中间件栈里添加中间件： https://ruby-china.github.io/rails-guides/rails_on_rack.html

    config.middleware.use(new_middleware, args)：在中间件栈的末尾添加一个中间件。
    config.middleware.insert_before(existing_middleware, new_middleware, args)：在中间件栈里指定现有中间件的前面添加一个中间件。
    config.middleware.insert_after(existing_middleware, new_middleware, args)：在中间件栈里指定现有中间件的后面添加一个中间件。

rails用的Rack 中间件
https://www.cnblogs.com/lidaobing/archive/2010/10/19/1855958.html

openstreetmap 中的加载的中间件

    $ ag middleware config
    config/initializers/uri_sanitizer.rb
    2:Rails.configuration.middleware.insert_before Rack::Runtime, Rack::URISanitizer

    config/initializers/cors.rb
    23:Rails.configuration.middleware.use OpenStreetMap::Cors 
