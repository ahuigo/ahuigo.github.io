---
title: Umi msg
date: 2019-11-20
private: true
---
# Umi msg

    import { message } from 'antd';
    message.success('提交成功');

## notification
    import { notification } from 'antd';
    notification.error({
        description: '您的网络发生异常，无法连接服务器',
        message: '网络异常',
    });

# tooltip

    <Tooltip placement="topLeft" title={text}>
        <Button>TL</Button>
      </Tooltip>