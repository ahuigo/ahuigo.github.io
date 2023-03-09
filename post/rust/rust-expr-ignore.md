---
title: Rust expr ignore
date: 2023-03-07
private: true
---
# ignore warning
allow 注释是告诉rust 忽略相关的warning

    #![allow(unused_variables)]
    type File = String;


    #[allow(dead_code)]
    fn read(f: &mut File, save_to: &mut Vec<u8>) -> ! {
        unimplemented!()
    }
