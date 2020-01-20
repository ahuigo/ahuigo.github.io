---
title: Python func/method bound/unbound
date: 2020-01-18
private: 
---
# Python func/method bound/unbound
## bound magic get
> 更多magic: py-magic.md

相当js的this

    In [13]: bar.__get__(a)
    Out[13]: <bound method bar of <__main__.A object at 0x107924160>>

经常

    def bar(self, name):
        self.show(name)

    obj.bar = bar.__get__(obj)
    # or bar = bar.__get__(obj)
    obj.bar('name')

## super bound/unbound
see py-obj-type-super.md for `bound and unbound with super`

## module bound

    # lib/logger.py
    import logging
    logger = logging.root

注意不是：

    >>> from lib import logger
    <module 'lib.logger' from '/.../lib/logger.py'>

而是

    from lib.logger import logger