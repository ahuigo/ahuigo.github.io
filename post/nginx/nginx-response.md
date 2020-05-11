---
title: nginx response
date: 2020-05-10
private: true
---
# nginx response

## header
### conntent-type

    location /lua_content {
        # MIME type determined by default_type:
        default_type 'text/plainx';

        content_by_lua_block {
            ngx.say('Hello,world!')
        }
    }