---
title: robustness
date: 2018-09-28
---
# robustness
鲁棒性（robustness）就是系统的健壮性

# 统一配置
1. 统一城市
1. 经维度lbs: 统一的坐标转换

# 统一的日志服务
重要的日志，需要消息id 便于后期追踪，比如：push 消息。

1. 消息id
2. 系统类型：ios, android
3. 统一的用户身份验证

项目规则一定要收敛

# 统一的城市id
一级城市编码 二级

# 统一的坐标变换

# 统一的error(errno, error)

## http.code
    200 
    400 ajax请求无效 (Bad request)

## app error:
1. 使用错误码errno, 比如weibo
2. 使用错误代码命名规范为: `大类:子类`

错误代码命名规范

    ctx.response.status = 400;
    ctx.rest({
        code: 'auth:user_not_found',
        message: 'user not found'
    });

e.g.

    mysql
    mysql:net
    mysql:data_err

    user:no_login