---
title: ruby erb 语法
date: 2023-08-23
private: true
---
# ruby erb 语法

## foreach

  <% [57, 60, 72, 76, 114, 120, 144, 152, 180].each do |size| -%>
    <%= favicon_link_tag "apple-touch-icon-#{size}x#{size}.png", :rel => "apple-touch-icon", :sizes => "#{size}x#{size}", :type => "image/png" %>
  <% end -%>