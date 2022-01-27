---
title: Java String
date: 2019-09-08
private:
---
# define string
## char
注意char类型使用单引号`'`，且仅有一个字符，要和双引号`"`的字符串类型区分开

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

### char2int

    (int)'a'

## string

### raw string(java>=15)
raw1:

    String s = """
    line1 \
    Or even double-quotes "
    """

raw2:

    `This uses single backtick`
    ``This can contain backtick `, see?``
    ```Can use any number of backticks```

### null string
    String s1 = null; // s1是null
    String s2; // 没有赋初值值，s2也是null
    String s3 = s1; // s3也是null

## toCharArray
    for (char ch: string.toCharArray()) {
        String.format("%04x", (int) ch));
    }

## bytes
类似于golang bytes，是int

### str2byte
    String str = "Example String";
    byte[] b = str.getBytes();

    System.out.println("Array " + b);
    // Array [B@3578436e
    System.out.println("Array as String" + Arrays.toString(b));
    //Array as String[69, 120, 97, 109, 112, 108, 101, 32, 83, 116, 114, 105, 110, 103]

### byte2str

## str2hex
    public static String toHexString(String s) {
        StringBuilder str = new StringBuilder();
        var ba = s.getBytes();
        for(int i = 0; i < ba.length; i++)
            str.append(String.format("%02x", ba[i]));
        return str.toString();
    }

    public static String fromHexString(String hex) {
        StringBuilder str = new StringBuilder();
        for (int i = 0; i < hex.length(); i+=2) {
            str.append((char) Integer.parseInt(hex.substring(i, i + 2), 16));
        }
        return str.toString();
    }

hex2decimal

    var i = Integer.parseInt("0A0a",16);

# string pointer
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
matcher 隐含了"^$"

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

## replace
string:

    s1.replaceAll(" ","")

replace with preg

    str.replaceAll("word(?!([^<]+)?>)", "repl");

## concat

    s1+s2
    s1.concat(s2)

StringBuilder

    StringBuilder str = new StringBuilder();
    str.append(s1)
    str.append(s2)


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
