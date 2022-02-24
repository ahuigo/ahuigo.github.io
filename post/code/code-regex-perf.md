---
title:	正则性能优化
date: 2018-08-18
---
# 回溯优化
鸟哥有一个示例：

    $reg = "/<script>.*?<\/script>/is";
    $str = "at:<script>********".str_repeat("*", 1e6)."</script>end";
    echo preg_repalce($reg, "", $str); //返回NULL 其原因就是回溯太多了，直到造成耗尽栈空间爆栈(？)

对于字符串：

	<script>123456</script>
  
对于以下表达式的回溯次数分别为：

    /<script>.+<\/script>/;    //9次 </script> 9
    /<script>.+?<\/script>/;  //5次  23456
    /<script>(?:(?!<\/script>).)+<\/script>/;  //7次 123456< 走到< 时，就pass

## 通过去除特定字符避免
中间部分不回溯的改进例子: 但是有bug
	
	/<script>[^<]*<\/script>/is //但是如果中单有字符`<` 就无法匹配了


## 固化分组
具体来说，使用`(?>…)`的匹配,固化为一个单元，只能作为整体而保留或放弃

比如要匹配如下表达式`[1-9]?`先匹配3, `\d+` 无法匹配，所以回溯`[1-9]?` 匹配空，再`\d+`匹配3

    '123'.match(/12([1-9]?)\d+/)

当无法匹配时可以不回溯吗？可以的

    '123'.match(/12(?>[1-9]?)\d+/)

好的表达式是利用非回溯子表达式`?>`,正如栖草所写的正则[php正则效率:回溯]：

	/<script>(?>[^<]*)(?>(?!</?script>)<[^<]*)*</script>/

    # split 一下
	/<script>
    固化1 (?>[^<]*)   非<
    固化2 (?> (?!</?script>) <[^<]*)*  <符
    </script>/

js测试一下, js 不支持固化：

    > '<script>a<script></script>end'.match(/<script>([^<]*)((?!<\/?script>)<[^<]*)*<\/script>/)
    [ "<script></script>", "", undefined ]
    > '<script>a<script ></script>end'.match(/<script>([^<]*)((?!<\/?script>)<[^<]*)*<\/script>/)
    [ "<script>a<script ></script>", "a", "<script >" ]

# Reference
- [php正则效率:回溯]

[php正则效率:回溯]: http://www.cnxct.com/php%E6%AD%A3%E5%88%99%E8%A1%A8%E8%BE%BE%E5%BC%8F%E7%9A%84%E6%95%88%E7%8E%87%EF%BC%9A%E5%9B%9E%E6%BA%AF%E4%B8%8E%E5%9B%BA%E5%8C%96%E5%88%86%E7%BB%84/
