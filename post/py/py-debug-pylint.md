---
title: pylint
date: 2018-09-28
---
# pylint
用来规范代码风格

## config
1. touch ~/.pylintrc
2. generate stdrc: `pylint --generate-rcfile > ~/.pylintrc`

### message 
for command line:
```
pylint --msg-template='{path}:{line}: [{msg_id}({symbol}), {obj}] {msg}' a.py
```
for .pylintrc
```
msg-template={path}:{line}: [{msg_id}({symbol}), {obj}] {msg}
```
### enable
```s
[MESSAGES CONTROL]
enable=cyclic-import
```

### disable message
under '[MESSAGES CONTROL]', uncomment 'disable=' and add the message ID's you want to disable, e.g.:
```s
[MESSAGES CONTROL]
disable=W0511, C11, E7,
    trailing-whitespace
```
> You can also add a comment at the top of your code that will be interpreted by pylint: `# pylint: disable=C0321`

### disable whitespace
    a.py:52:16: C0303: Trailing whitespace (trailing-whitespace)

忽略以上错误，可以选择忽略C0303 或错误的名 trailing-whitespace

```s
[MESSAGES CONTROL]
disable=trailing-whitespace,
    C0303
```
## 检查单行
    # pylint: disable=all
    # pylint: enable=circular-import
    span._iter_exit()  # pylint: disable=all

## check单个文件：
在文件头部加：

    # pylint: disable=all
    # pylint: enable=circular-import

或者：
    pylint --rcfile=pylint.conf manage.py

check结果总览：
```
************* Module manage
C:  1, 0: Missing module docstring (missing-docstring)
W: 14,12: Unused import django (unused-import)
```

## check整个工程：
如果在工程根目录下添加init.py文件，即把工程当做一个python包的话，可以对整个工程进行pylint。

    pylint api(api为包名称)

# autopep8
要自动修正 Python 文件格式，可以使用 autopep8 或 black 这类工具。