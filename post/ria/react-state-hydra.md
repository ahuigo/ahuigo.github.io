---
title: react hydra state
date: 2022-08-16
private: true
---
# react hydra state

## Missing getServerSnapshot, 
which is required for server-rendered content. Will revert to client rendering

solutions: refer: https://github.com/reactwg/react-18/discussions/121

The new useSyncExternalStore hook has a third argument, called getServerSnapshot

        return useSyncExternalStore(
          store[key].subscribe,
          store[key].getSnapshot,
          store[key].getSnapshot
        );