---
title: ruby str serial
date: 2020-06-04
private: true
---
# ruby str serial
## json
    ActiveSupport::JSON.decode("{\"team\":\"rails\",\"players\":\"36\"}")
    => {"team" => "rails", "players" => "36"}

    ActiveSupport::JSON.encode({ team: 'rails', players: '36' })

异常处理(参考 ruby/rb-debug-except.md)

    begin
        obj = ActiveSupport::JSON.decode(some_string)
    rescue ActiveSupport::JSON.parse_error
        Rails.logger.warn("Attempted to decode invalid JSON: #{some_string}")
    end