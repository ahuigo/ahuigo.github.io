---
title: println
date: 2018-09-27
---
# print
## println
System.out.println
System.out.print

    public class Hello{
        public static void main(String[] args) {
            System.out.println("Hello, World");
        }
    }

> In General, class name should be uppercase like `Hello`, (while `hello` is not forbidden)
> main method shuld have `String[] args`

## printf

    %d	格式化输出整数
    %x	格式化输出十六进制整数
    %f	格式化输出浮点数
    %e	格式化输出科学计数法表示的浮点数
    %s	格式化字符串
    System.out.printf("%.4f\n", d); // 显示4位小数3.1416

# Input
## Scanner
而System.in代表标准输入流。直接使用System.in读取用户输入虽然是可以的，但需要更复杂的代码，而通过Scanner就可以简化后续的代码。

    import java.util.Scanner;

    public class Main {
        public static void main(String[] args) {
            Scanner scanner = new Scanner(System.in); // 创建Scanner对象
            System.out.print("Input your name: "); // 打印提示
            String name = scanner.nextLine(); // 读取一行输入并获取字符串
            System.out.print("Input your age: "); // 打印提示
            int age = scanner.nextInt(); // 读取一行输入并获取整数
            System.out.printf("Hi, %s, you are %d\n", name, age); // 格式化输出
        }
    }

## Argument

    public static void main(String[] args) {
       System.out.print("Hi, ");
       System.out.print(args[0]);
       System.out.println(". How are you
    }