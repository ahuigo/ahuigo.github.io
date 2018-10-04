---
title: install:
date: 2018-10-04
---
install:
```
pip3 install pyyaml
```
```
>>> import yaml
>>> a=yaml.load(open('a.conf'))
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
FileNotFoundError: [Errno 2] No such file or directory: 'a.conf'
>>> a=yaml.load(open('a.conf'))
```