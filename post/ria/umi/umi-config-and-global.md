---
title: umi config
date: 2019-11-24
private: true
---
# umi config 
umi 引入本包的根目录，可以用`@`

    import request from '@/utils/request';
    import config from '@/../config/defaultSettings';

上面那个config 是用于编译的，app本身的conf 可自定义:

    import config from '@/conf';