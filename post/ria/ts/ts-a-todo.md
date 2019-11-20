---
title: ts todo
date: 2019-11-11
private: 
---
# ts todo
    function f({ pretty: boolean })
    function f({ pretty }: { pretty: boolean })
    function f({ pretty = true }: { pretty?: boolean }){}
    function f({ pretty = true }: { pretty?: boolean } = {}){}