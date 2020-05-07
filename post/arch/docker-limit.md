---
title: docker limit
date: 2020-05-06
private: true
---
# docker limit
The latest docker supports setting ulimits through the command line and the API. For instance, docker run takes:

     --ulimit <type>=<soft>:<hard> 

So, for your nofile, an example would be:

     --ulimit nofile=262144:262144
