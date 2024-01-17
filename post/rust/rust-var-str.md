---
title: rust var str
date: 2023-03-03
private: true
---
# Define string/char/unit

## Define `&str` literal string
字符串是 UTF-8 编码，也就是字符串中的字符所占的字节数是变化的(1 - 4)
字面类型, 不可变引用：

    let s:&str = "hello world\n new line"

### 转义

   // 通过 \x + 字符的十六进制表示，转义输出一个字符
    let byte_escape = "I'm writing \x52\x75\x73\x74!";
    println!("What are you doing\x3F (\\x3F means ?) {}", byte_escape);

    // \u 可以输出一个 unicode 字符
    let unicode_codepoint = "\u{211D}";
    let character_name = "\"DOUBLE-STRUCK CAPITAL R\"";

    println!(
        "Unicode character {} (U+211D) is called {}",
        unicode_codepoint, character_name
    );

    // 换行了也会保持之前的字符串格式
    let long_string = "String literals
                        can span multiple lines.
                        The linebreak and indentation here ->\
                        <- can be escaped too!";
    println!("{}", long_string);

### raw不转义
    let raw_str = r"Escapes don't work here: \x3F \u{211D}";
    println!("{}", raw_str);

    // 如果字符串包含双引号，可以在开头和结尾加 #
    let quotes = r#"And then I said: "There is no escape!""#;
    println!("{}", quotes);

    // 如果还是有歧义，可以继续增加，没有限制
    let longer_delimiter = r###"A string with "# in it. And even "##!"###;
    println!("{}", longer_delimiter);

## Define `String`
`String`不是引用, 如果没有加mut 就是不可变字符串

    let s1 = String::from("hello");
    let s1 = "hello".to_string();

### str vs String
两者都是utf8存储, Rust提到的字符串主要是这两种
1. str 类型是硬编码进可执行文件，也无法被修改
2. String 则是一个`可增长`、`可改变`且具有`所有权`(位于内存heap)
3. `&str` 是对两者的引用切片

Rust之所以这样设计String，是因为变量在离开作用域后，就自动释放其占用的内存:
1. Rust 提供了一个释放内存的函数： drop(相当于c的free), 在变量离开作用域时，自动调用 drop 函数
2. 在 C++ 中也有这种概念: Resource Acquisition Is Initialization (RAII)

Rust 的标准库还提供了其他类型的字符串，例如 OsString， OsStr， CsString 和 CsStr 等

### &str与String　互转
`&str`to String:

    String::from("hello,world")
    "hello,world".to_string()

String to `&str`:

    let s = String::from("hello,world!");
    s[..] // str
    &s[..] // &str
    say_hello(&s);
    say_hello(&s[..]);
    say_hello(s.as_str());


这种灵活用法是因为 `deref` 隐式强制转换

## define `char`
由于 Unicode 都是 4 个字节编码，因此字符类型都是占用 4 个字节：

    let x = '中';
    let y = 'A'
    println!("'中'占用{}字节",std::mem::size_of_val(&x));
    println!("'A'占用了{}字节",std::mem::size_of_val(&y));

# 字符串操作
refer　to：　rustlib/src/str/str_func.rs
