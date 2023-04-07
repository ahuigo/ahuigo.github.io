---
title: docker user login
date: 2023-03-30
private: true
---
# multiple login
    docker --config ~/.project1 login registry.example.com -u <username> -p <deploy_token>
    docker --config ~/.project2 login registry.example.com -u <username> -p <deploy_token> 

Then you are able to call Docker commands by selecting your credential:

    docker --config ~/.project1 pull registry.example.com/project1
    docker --config ~/.project2 pull registry.example.com/project2

看起来已经支持multiple token?

    ~/.docker/.token_seed