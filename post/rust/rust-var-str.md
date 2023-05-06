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
define `char` via single quotes, 它是4bytes Unicode

    'A'

由于 Unicode 都是 4 个字节编码，因此字符类型都是占用 4 个字节：

    let x = '中';
    let y = 'A'
    println!("'中'占用{}字节",std::mem::size_of_val(&x));
    println!("'A'占用了{}字节",std::mem::size_of_val(&y));

# 字符串操作
用切片操作字符串是危险的，正确的方法如下. Note:
1. inplace 方法仅适用于`String`

## push(inplace)

    let s= String::from("rust, rust!");
    s.push_str("rust"); //追加字符串
    s.push('!'); //追加字符char

## insert(inplace)
    s.insert_str(6, " I like");
    s.insert(5, ',');

## replace
    let s= "rust rust!"
    let new_str= s.replace("rust", "RUST"); //RUST, RUST!
    dbg!(new_str);

replacen 第三个参数则表示替换的个数

    s.replacen("rust", "RUST", 1);

repalce range该方法仅适用于 String 类型: 第一个参数表示替换的范围

    s.replace_range(7..8, "R");

## delete(String only)
与字符串删除相关的方法有 4 个，他们分别是 pop()，remove()，truncate()，clear()。这四个方法仅适用于 String 类型。

### pop —— 删除并返回字符串的最后一个字符
该方法是直接操作原来的字符串。但是存在返回值，其返回值是一个 `Option<char>` 类型，如果字符串为空，则返回 None。 示例代码如下：


    fn main() {
        let mut string_pop = String::from("rust pop 中文!");
        let p1 = string_pop.pop();
        let p2 = string_pop.pop();
        dbg!(p1);
        dbg!(p2);
        dbg!(string_pop);
    }

### remove —— 删除并返回字符串中指定位置的字符
该方法是直接操作原来的字符串。
1. 其返回值是删除位置的char，只接收一个参数，表示该字符起始索引位置。
2. remove() 方法是按照`字节`位置来处理字符串的，如果参数所给的位置不是合法的字符边界，则会发生错误。

示例代码如下：

    fn main() {
        let mut string_remove = String::from("测试remove方法");
        println!(
            "string_remove 占 {} 个字节",
            std::mem::size_of_val(string_remove.as_str())
        );
        // 直接删除第二个汉字
        string_remove.remove(3);
        dbg!(string_remove);
    }

### truncate —— 删除字符串中从指定位置开始到结尾的全部字符
该方法是直接操作原来的字符串。无返回值。也是按照`字节`来处理字符串的

    s.truncate(3);

### clear —— 清空字符串
相当于s.truncate(0)

## 连接 (Concatenate)
### 使用 + 或者 += 连接字符串
使用 + 或者 += 连接字符串，要求右边的参数必须为字符串的切片引用（Slice）类型。

    let string_append = String::from("hello ");
    let string_rust = String::from("rust");
    // &string_rust会自动编译器解引用为&str
    let result = string_append + &string_rust;
    let mut result = result + "!";

其实当调用 + 的操作符时，相当于调用了 std::string 标准库中的 add() 方法, 返回`String`

    fn add(self, s: &str) -> String

注意，self所有权被转移走了(可变引用), 然后返回新的String，self就会被释放

    let s1 = String::from("hello,");
    let s2 = String::from("world!");
    // 在下句中，s1的所有权被转移走了，因此后面不能再使用s1
    let s3 = s1 + &s2;
    assert_eq!(s3,"hello,world!");

### format! 连接字符串
format! 的用法与 print! 的用法类似，详见格式化输出。

    let s1 = "hello";
    let s2 = String::from("rust");
    let s = format!("{} {}!", s1, s2);
    println!("{}", s);

## 遍历
### loop char
    for c in "中国人".chars() {
        println!("{}", c); //type: char
    }
### loop bytes
    for b in "中国人".bytes() {
        println!("{}", b);  // 类型:u8
    }

## slice 字串
标准库做不到，得用这个
https://crates.io/crates/utf8_slice
