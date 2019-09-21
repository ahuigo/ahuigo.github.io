---
title: Java expr
date: 2018-09-27
pvivate:
---
# Switch语句块
    switch (option) {
    case 3:
        ...
        break;
    case 2:
        ...
        break;

## Switch 表达式

    String fruit = "apple";
    int opt = switch (fruit) {
        case "apple" -> 1;
        case "pear", "mango" -> 2;
        default -> 0;
    }; // 注意赋值语句要以;结束
    System.out.println("opt = " + opt);

switch表达式是作为Java 12的预览特性（Preview Language Features）实现的，编译的时候，我们还需要给编译器加上参数：

    javac --source 12 --enable-preview Main.java

# for

    // 不设置结束条件:
    for (int i=0; ; i++) {
        ...
    }
    // 不设置结束条件和更新语句:
    for (int i=0; ;) {
        ...
    }
    // 什么都不设置:
    for (;;) {
        ...
    }

## for each

    int[] ns = { 1, 4, 9, 16, 25 };
    for (int n : ns) {
        System.out.println(n);
    }

# break continue
不支持

    break 2;
    continue 2;