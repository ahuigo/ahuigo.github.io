---
title: rust num
date: 2023-03-03
private: true
---
# num type
## int type
默认使用 i32

    8 位	i8	u8
    16 位	i16	u16
    32 位	i32	u32
    64 位	i64	u64
    128 位	i128	u128
    视架构而定	isize	usize

整形字面量可以用下表的形式书写：

    十进制	98_222
    十六进制	0xff
    八进制	0o77
    二进制	0b1111_0000
    字节 (仅限于 u8)	b'A'

### 整数溢出
在当使用 --release 参数进行 release 模式构建时，Rust 不检测溢出

    let a : u8 = 257; //1, (默认按照补码循环溢出规则处理）

要显式处理可能的溢出，可以使用标准库针对原始数字类型提供的这些方法：

    使用 wrapping_* 方法在所有模式下都按照补码循环溢出规则处理，例如 wrapping_add(默认)
    如果使用 checked_* 方法时发生溢出，则返回 None 值
    使用 overflowing_* 方法返回该值和一个指示是否存在溢出的布尔值
    使用 saturating_* 方法使值达到最小值或最大值

e.g.

    let a : u8 = 255;
    let b = a.wrapping_add(20);//19
    let b = a.checked_add(20);//None


## float type
default f64

    let x = 2.0; // f64
    let y: f32 = 3.0; // f32

### 无法compare
因为float没有实现std::cmp::Eq ,而是 std::cmp::PartialEq. f64比较的精度更高一点

      assert!(0.1_f32 + 0.2_f32 == 0.3_f32);//ok
      assert!(0.1 + 0.2 == 0.3);//assert panic

16进制打印

    let xyz: (f64, f64, f64) = (0.1, 0.2, 0.3);
    println!("   0.1 + 0.2: {:x}", (xyz.0 + xyz.1).to_bits());

## NaN
    let x = (-42.0_f32).sqrt();
    if x.is_nan() {
        println!("未定义的数学行为")
    }
    assert_eq!(x, x); //assert panic: not equal

## 类型推导

    // 定义一个f32数组，其中42.0会自动被推导为f32类型
    let forty_twos = [42.0, 42f32, 42.0_f32];

    // 打印数组中第一个值，并控制小数位为2位
    println!("{:.2}", forty_twos[0]);

# 运算
## bits clac
### 与或非运算符

    & | ^ !
    // 注意这些计算符除了!之外都可以加上=进行赋值 (因为!=要用来判断不等于)


### 移位运算

    << <<= (无视符号位)
    >> >>= (符号位补1)

    println!("bits:{:b}", 127i8 << 3); //-8: 1111 1000
    println!("bits:{:b}", (-1i8 >> 3)); //-1:1111 1111

## range num
`1..5`则不包含5, `1..=5`则包含5, 

    for i in 1..=5 {
        println!("{}",i); //1,2,3,4,5
    }

char 也可以 (序列只允许用于数字或字符类型)

    for i in 'a'..='z' {
        println!("{}",i); //'a',...,'z'
    }

## 有理数和复数
Rust 的标准库相比其它语言，准入门槛较高，因此有理数和复数并未包含在标准库中：

    有理数和复数
    任意大小的整数和任意精度的浮点数
    固定精度的十进制小数，常用于货币相关的场景

导入num包
1. 在 Cargo.toml 中的 `[dependencies]` 下添加一行 `num = "0.4.0"`
2. 将 src/main.rs 文件中的 main 函数替换为下面的代码

e.g.


    fn main() {
        use num::complex::Complex;
      let a = Complex { re: 2.1, im: -1.2 };
      let b = Complex::new(11.1, 22.2);
      let result = a + b; 

      println!("{} + {}i", result.re, result.im) //13.2 + 21i
    }