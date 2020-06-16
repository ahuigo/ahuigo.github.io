---
title: umi mock
date: 2020-06-10
private: true
---
# umi mock
> https://umijs.org/docs/mock
比如我们有以下请求

    // src/services/user.ts
    import request from '@/utils/request';

    export async function query(): Promise<any> {
        return request('/api/users');
    }

我们mock 这个请求, umi会自动读`mock/`目录:

    // /mock/user.ts
    import { Request, Response } from 'express';

    export default {
      // 支持值为 Object 和 Array
      'POST /api/users': (req: Request, res: Response) => {
        const { password, userName, type } = req.body;
        if (password === 'ant.design' && userName === 'admin') {
          res.send({
            status: 'ok',
            type,
            currentAuthority: 'admin',
          });
          return;
        }
    
