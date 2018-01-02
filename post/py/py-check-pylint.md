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

### disable message
under '[MESSAGES CONTROL]', uncomment 'disable=' and add the message ID's you want to disable, e.g.:
```s
[MESSAGES CONTROL]
disable=W0511, C11, E7
```
> You can also add a comment at the top of your code that will be interpreted by pylint: `# pylint: disable=C0321`


## check单个文件：

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
