---
title: Java String
date: 2019-09-08
private:
---
# Java String
## define
### char
注意char类型使用单引号'，且仅有一个字符，要和双引号"的字符串类型区分开

        char a = 'A';
        char zh = '中';
        char c3 = '\u0041'; // 'A'，因为十六进制0041 = 十进制65
        char c4 = '\u4e2d'; // '中'，因为十六进制4e2d = 十进制20013
### int to char

    // unicode
    var a = 31;
    var b = 31;
    int c = 65281;
    String s = "" + (char)a + (char)b  + (char)c;

### null string
    String s1 = null; // s1是null
    String s2; // 没有赋初值值，s2也是null
    String s3 = s1; // s3也是null


## 字符串不可变
下列代码只是s 的指向变了

    String s = "hello";
    s = "world";

### string 是不可变的引用类型
Refer: https://www.liaoxuefeng.com/wiki/1252599548343744/1255941599809248

    String[] names = {"ABC", "XYZ", "zoo"};
    String s = names[1];    //s 指向“ABC”
    names[1] = "cat";       //s 还是指向“ABC”

# str func
## equal

1. == tests for reference equality (whether they are the same object).
2. .equals() tests for value equality (whether they are logically "equal").

Consequently, if you want to test whether two strings have the same value you will probably want to use `Objects.equals()`.

    // These two have the same value
    new String("test").equals("test") // --> true

    // ... but they are not the same object
    new String("test") == "test" // --> false

    // ... neither are these
    new String("test") == new String("test") // --> false

    // ... but these are because literals are interned by
    // the compiler and thus refer to the same object
    "test" == "test" // --> true

    // ... but you should really just call Objects.equals()
    Objects.equals("test", new String("test")) // --> true
    Objects.equals(null, "test") // --> false

## preg
与pcre 不完全相同, 默认"^$"

    import java.util.regex.Pattern;
    import java.util.regex.Matcher;

    String p = "Host: (.*)\\r\\n";
    String input = "Host: example.com\r\n";
    Pattern pattern = Pattern.compile(p);
    Matcher matcher = pattern.matcher(input);
    if(matcher.matches()) {
      String output = matcher.group(1);
        System.out.println(output);
    } else {
        System.out.println("not found");
    }

## url

### parse_str

    public Map<String,String> parse_str(String query){
        Map<String,String> fbParam = new HashMap<String,String> ();
        String[] pairs = query.split("&");
        for(String pair : pairs) {
          String[] keyval = pair.split("=");
          fbParam.put(keyval[0], keyval[1]);
        }
        return fbParam;
    }

on android:

    import android.net.Uri;

    Uri uri=Uri.parse(url_string);
    uri.getQueryParameter("para1");
