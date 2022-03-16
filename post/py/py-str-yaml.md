---
title: python yaml
date: 2018-10-04
private:
---
# install:
    ```
    pip3 install pyyaml
    ```

# load file
    ```
    >>> import yaml
    >>> a=yaml.load(open('a.conf'))
    conf = yaml.load(open(sys.argv[1]), Loader=yaml.FullLoader)

    ```

## load str
    obj = yaml.safe_load('''
    xata: adf
    ''')


# dump

    out = yaml.dump(obj)
    yaml.dump(obj, sys.stdout)
    yaml.dump(obj, open('a.yaml', 'w+'))

dummper style

    yaml.dump(obj, default_flow_style=True)
    yaml.dump(obj, Dumper=yaml.CDumper)


### dump and preserve linebreak
为增强yaml可读性, yaml.dump 时保留换行，我们可以定义add_representer：

    import sys
    import yaml 

    def repr_str(dumper, data: str):
        if '\n' in data:
            return dumper.represent_scalar('tag:yaml.org,2002:str', data, style='|')
        return dumper.represent_scalar('tag:yaml.org,2002:str', data)

    yaml.add_representer(str, repr_str)
    print(yaml.dump({'a': 1, 'b': {"conf":'hello\n world'}}))

输出

    a: 1
    b:
    conf: |-
        hello
        world

不过，上面的例子对 `yaml.dump('\"key:value\",\n \n') `无效. 我们可以采用下面的示例解决此问题

    def dump_with_newline2(data):
        from ruamel.yaml.representer import RoundTripRepresenter
        from ruamel.yaml import YAML
        def repr_str(dumper: RoundTripRepresenter, data: str):
            if '\n' in data:
                return dumper.represent_scalar('tag:yaml.org,2002:str', data, style='|')
            return dumper.represent_scalar('tag:yaml.org,2002:str', data)

        yaml = YAML()
        yaml.representer.add_representer(str, repr_str)
        yaml.dump(data, sys.stdout)

上例封装中，必须传sys.stdout, 可用stringIO 替代 sys.stdout

    from io import StringIO
    f = StringIO()
    yaml.dump(data, f)
    return f.getvalue()


## keep comments
import sys
import ruamel.yaml

yaml_str = """\
# example
    name:
      # details
      family: Smith   # very common
      given: Alice    # one of the siblings
    """

    yaml = ruamel.yaml.YAML()  # defaults to round-trip if no parameters given
    code = yaml.load(yaml_str)
    code['name']['given'] = 'Bob'

    yaml.dump(code, sys.stdout)

with result:

    # example
    name:
      # details
      family: Smith   # very common
      given: Bob      # one of the siblings