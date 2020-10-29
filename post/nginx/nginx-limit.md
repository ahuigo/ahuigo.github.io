---
title: nginx limit
date: 2020-05-10
private: true
---
# nginx limit

    location = /request_body {
        client_max_body_size 50k;
        client_body_buffer_size 50k;
    }