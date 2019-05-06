---
title: Shell make
date: 2019-05-06
private:
---
# Shell make
    $ make test FLAG=debug

然后

    FLAG?=default_value
    test:
        echo $(FLAG)

