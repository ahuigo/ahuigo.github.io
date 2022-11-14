---
title: react hydra state
date: 2022-08-16
private: true
---
# react hydra state

## Missing getServerSnapshot
which is required for server-rendered content. Will revert to client rendering

solutions: refer: https://github.com/reactwg/react-18/discussions/121

The new useSyncExternalStore hook has a third argument, called getServerSnapshot

        return useSyncExternalStore(
          store[key].subscribe,
          store[key].getSnapshot,
          store[key].getSnapshot
        );

## useSyncExternalStore 是 useReduce 替代
参考: app/routes/state.tsx

    // resso.ts
    // import { useSyncExternalStore } from 'use-sync-external-store/shim';
    // import { useSyncExternalStore } from 'https://esm.sh/v91/use-sync-external-store@1.2.0/es2022/shim.bundle.js';
    import {useSyncExternalStore} from 'react';
    type Callback = () => void;
    type State = Record<string, unknown>;
    type Store<T> = {
        [K in keyof T]: {
            subscribe: (listener: Callback) => Callback;
            getSnapshot: () => T[K];
            useSnapshot: () => T[K];
            setSnapshot: (val: T[K]) => void;
        };
        };

    const resso = <T extends State>(state: T): Store<T> => {
        if (Object.prototype.toString.call(state) !== '[object Object]') {
            throw new Error('object required');
        }

        const store: Store<T> = {} as Store<T>;

        Object.keys(state).forEach((key: keyof T) => {
            if (typeof state[key] === 'function') return;

            const listeners = new Set<Callback>();

            store[key] = {
                subscribe: (listener) => {
                    console.log({addLis:listener})
                    listeners.add(listener);
                    return () => listeners.delete(listener);
                },
                getSnapshot: () => state[key],
                setSnapshot: (val) => {
                    if (val === state[key]) return;
                    state[key] = val;
                    listeners.forEach((listener) => listener());
                },
                useSnapshot: () => {
                    console.log({useSnapshot:"change..."})
                    return useSyncExternalStore(
                        store[key].subscribe,
                        store[key].getSnapshot,
                    );
                },
            };
        });
        return store
    };

    export default resso;

use state:

    const rstore = resso({ count: 0 });
    function Count() {
      const count = rstore.count.useSnapshot();
      console.log({ "render:count": count });
      return <div>{count}</div>;
    }

    function Button() {
        const n = rstore.count.useSnapshot();
        const onClick = () => rstore.count.setSnapshot(n + 1)
        return (
            <button onClick={onClick } > +1 </button>
        );
    }