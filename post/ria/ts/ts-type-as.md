---
title: ts type satisfies
date: 2024-04-10
private: true
---
# ts type satisfies
只检查类型，不转换类型

    interface Conf{
        api: string;
    }
    const a = {} satisfies Conf
    const a = {} as Conf