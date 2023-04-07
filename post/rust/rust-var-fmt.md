---
title: rust fmt
date: 2023-03-03
private: true
---
# rust fmt
rustlib/str/fmt

## raw print`:?`
    let a: u8 = 255;
    let b = a.checked_add(20);
    println!("{:?}, {:#?}", b, b);

## hex print
    let xyz: (f64, f64, f64) = (0.1, 0.2, 0.3);
    println!("   0.1 + 0.2= {:x}", (xyz.0 + xyz.1).to_bits());
    //   0.1 + 0.2= 3fd3333333333334