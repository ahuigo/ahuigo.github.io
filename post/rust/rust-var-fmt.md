---
title: rust fmt
date: 2023-03-03
private: true
---
# rust fmt
源码： rustlib/str/fmt/ {format,println}.rs

# format
源码： rustlib/str/fmt/format.rs

    println!("{}",format!("hello2"));
    format!("{} {}", 1, 2);           // => "1 2"
    format!("{:?}", (3, 4));          // => "(3, 4)"
    format!("{value}", value=4);      // => "4"
    let people = "Rustaceans";
    format!("Hello {people}!");       // => "Hello Rustaceans!"
    format!("{:04}", 42);             // => "0042" with leading zeros
    format!("{:#?}", (100, 200));     // => "(
                                      //       100,
                                      //       200,
                                      //     )"


# println 
## raw print`:?`
`{:?}`和`{:#?}` 区别是, 后者是带格式化缩进的

    let a: u8 = 255;
    let b = a.checked_add(20); // Option<u8>
    println!("b:{:?}, b:{:#?}", b, b);
    // b:None, b:None

## hex print
    let xyz: (f64, f64, f64) = (0.1, 0.2, 0.3);
    println!("   0.1 + 0.2= {:x}", (xyz.0 + xyz.1).to_bits());
    //   0.1 + 0.2= 3fd3333333333334