# Type

## Type Convert

### int to string

　　int i = Integer.parseInt(str);
　　int i = Integer.parseInt([String],[int radix]);
　　int i = Integer.valueOf(my_str).intValue();

### string to int
有叁种方法:

　　String s = String.valueOf(i);
　　String s = Integer.toString(i);
　　String s = "" + i;

# string

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

# Map

## put

    Map<String,String> m = new HashMap<String,String> ();
    m.put(key, value)

## key

    map.containsKey(key)
    map.get(key)!=null

# array

## define:

    String[] logs;
    String[] logs = msg.split("\n");

example:

    // Create an array with room for 100 integers
    int[] nums = new int[100];

    // Fill it with numbers using a for-loop
    for (int i = 0; i < nums.length; i++)
        nums[i] = i + 1;  // +1 since we want 1-100 and not 0-99

    // Compute sum
    int sum = 0;
    for (int n : nums)
        sum += n;

    // Print the result (5050)
    System.out.println(sum);

## explode

    String partsColl = "A,B,C";
    String[] partsCollArr;
    String delimiter = ",";
    partsCollArr = partsColl.split(delimiter);
