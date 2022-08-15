---
title: react awesom
date: 2022-08-15
private: true
---
# state management
awesome preact 看到的 state management
1. Teaful - Tiny (800B), easy and powerful (P)React state management.
    https://github.com/teafuljs/teaful
    基于proxy(隐式) + useReduce 实现的, 支持原子化，不过不支持ts
2. Nano Stores - A tiny (199 bytes) state manager with many atomic tree-shakable stores.
    https://github.com/nanostores/nanostores
    原子化的状态管理, 风格类似jotai, 基于use-sync-external-store/shim, 支持ts/esm, 支持react/vue/.. 各种框架
3. https://github.com/nanxiaobei/resso
    基于 proxy(隐式) + use-sync-external-store/shim, ts写的
    https://github.com/reactwg/react-18/discussions/86
    https://www.zhihu.com/question/502917860

# 数据管理 useSWR

    import useSWR from 'swr'

    function Profile () {
      const { data, error } = useSWR('/api/user/123', fetcher)

      if (error) return <div>failed to load</div>
      if (!data) return <div>loading...</div>

      // render data
      return <div>hello {data.name}!</div>
    }

# react 测试
参考：https://github.dev/ahuigo/resso/blob/main/src/index.ts

    // vitest run --coverage --environment jsdom
    import { render, fireEvent } from '@testing-library/react';
    test('resso', () => {
        const { getByText } = render(<App />);
        expect(getByText('0')).toBeInTheDocument();
        fireEvent.click(getByText('btn1'));
        expect(getByText('1')).toBeInTheDocument();
    }
