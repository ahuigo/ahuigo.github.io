---
title: git ignore
date: 2019-12-26
private: true
---
# git ignore

    # 根目录
    /node_modules

    # * 是一级子目录
    /proj/*/src

    # ** 是多级子目录
    /**/src

    # 没有`/`也是多级子目录
    node_modules
    node_modules/
