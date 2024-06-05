---
title: ssl ca multiple
date: 2023-03-24
private: true
---
# ssl ca multiple(todo)
> refer: post/net/ssl-ca-view.md, SNI 同一域名多个证书
https://serverfault.com/questions/412432/how-to-specify-multiple-root-certificates-for-nginx-client-certificate-verificat

Nginx supports multiple root certificates. Just put multiple root CA certificates into a file specified in the `ssl_client_certificate` directive.

