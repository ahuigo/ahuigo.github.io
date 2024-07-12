---
title: Shell Directory
date: 2020-01-05
private: 
---
# Shell Directory

## tempfile
给临时文件一个不可预测的文件名是很重要的。这就避免了一种为大众所知的 temp race 攻击。 一种创建一个不可预测的（但是仍有意义的）临时文件名的方法是，做一些像这样的事情：

	tempfile=/tmp/$(basename $0).$$.$RANDOM

`$$` 是pid, `$RANDOM` 的范围比较小`1-32767`.

我们可以使用`mktemp`, 它接受一个用于创建文件名的模板作为参数。这个模板应该包含一系列的 “X” 字符， 随后这些字符会被相应数量的随机字母和数字替换掉。一连串的 “X” 字符越长，则一连串的随机字符也就越长

	tempfile=$(mktemp /tmp/foobar.$$.XXXXXXXXXX) ;# /tmp/foobar.6593.UOZuvM6654

### -d参数可以创建一个临时目录。

    $ mktemp -d
    /tmp/tmp.Wcau5UjmN6

### 临时文件所在的目录
-p参数可以指定临时文件所在的目录。默认是使用`$TMPDIR`环境变量指定的目录，如果这个变量没设置，那么使用/tmp目录。

    $ mktemp -p /home/ruanyf/
    /home/ruanyf/tmp.FOKEtvs2H3
