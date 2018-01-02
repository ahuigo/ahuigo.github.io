---
layout: page
title:	squid
category: blog
description: 
---
# Preface

# headers

## request
request_header_access X_Forwarded_For deny all

# ip
acl our_networks1 src 192.209.0.213
http_access allow our_networks1


# host
visible_hostname proxy.example.tst  
# port
http_port 3128 transparent  
