---
title: python yaml
date: 2018-10-04
private:
---
# install:
    ```
    pip3 install pyyaml
    ```

# load
    ```
    >>> import yaml
    >>> a=yaml.load(open('a.conf'))
    conf = yaml.load(open(sys.argv[1]), Loader=yaml.FullLoader)

    ```

## load str
    obj = yaml.safe_load('''
    xata: adf
    ''')

## dump

    yaml.dump(obj)
    yaml.dump(obj, default_flow_style=True)
    yaml.dump(obj, Dumper=yaml.CDumper)
