---
title: debug rust-gdb
date: 2024-01-02
private: true
---
# debug rust-gdb
https://www.reddit.com/r/rust/comments/15180ij/how_to_debug_seg_fault/

> 启用核心转储将是一个运行 `ulimit -S -c unlimited`; ubuntu 一般在`/var/lib/apport/coredump/`

## rust-gdb example

# rust-gdb target/debug/foo
bad case:

     unsafe {
        let x = std::ptr::null();
        println!("{}", std::mem::transmute::<*const (), &i32>(x));
    }

    $ rust-gdb core-file /path/to/the/file 
    [...]
    (gdb) core-file /var/lib/apport/coredump/core._tmp_...
    (gdb) bt
    ...
    (gdb) f 9
    #9  0x000055c9c0e8fb8a in foo::crashme () at src/main.rs:3
    3               println!("{}", std::mem::transmute::<*const (), &i32>(x));
    (gdb) p x
    $1 = (*mut ()) 0x0
