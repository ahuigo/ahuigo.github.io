---
title: shell set
date: 2021-03-09
private: true
---
# shell set
    $ set a b c
    $ echo $1
    a
    $ echo $2
    b
    $ echo $3
    c

The -- is the standard "don't treat anything following this as an option"

    $ echo $1,$2,$3
    a,b,c
    $ set -- haproxy "$@"
    $ echo $1,$2,$3,$4   
    haproxy,a,b,c