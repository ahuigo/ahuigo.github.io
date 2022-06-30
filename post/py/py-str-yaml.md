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

    # or
    conf = yaml.safe_load(open(sys.argv[1]))
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

    
    pip install ruamel_yaml

    def initYaml():
        from ruamel.yaml.representer import RoundTripRepresenter
        from ruamel.yaml import YAML
        def repr_str(dumper: RoundTripRepresenter, data: str):
            if '\n' in data:
                return dumper.represent_scalar('tag:yaml.org,2002:str', data, style='|')
            return dumper.represent_scalar('tag:yaml.org,2002:str', data)

        yaml = YAML()
        yaml.representer.add_representer(str, repr_str)
        return yaml

    def yamlDump(data):
        from io import StringIO
        f = StringIO()
        yaml.dump(data, f)
        #yaml.dump(data, sys.stdout)
        return f.getvalue()
    yaml = initYaml()
    conf = yaml.load(open(helmPath,'r'))
    yamlDump(conf)

## keep comments
    import sys
    import ruamel.yaml

    yaml_str = """
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

# 语法
## 类型
    boolean: 
        - TRUE  #true,True都可以
        - FALSE  #false，False都可以
    float:
        - 3.14
        - 6.8523015e+5  #可以使用科学计数法
    int:
        - 123
        - 0b1010_0111_0100_1010_1110    #二进制表示
    null:
        nodeName: 'node'
        parent: ~  #使用~表示null
    string:
        - 哈哈
        - 'Hello world'  #可以使用双引号或者单引号包裹特殊字符
        - newline
        newline2    #字符串可以拆成多行，每一行会被转化成一个空格
    date:
        - 2018-02-17    #日期必须使用ISO 8601格式，即yyyy-MM-dd
    datetime: 
        -  2018-02-17T15:02:31+08:00    #时间使用ISO 8601格式，时间和日期之间使用T连接，最后使用+代表时区

## 多行
多行字符串可以使用|保留换行符，也可以使用>折叠换行。

    # { this: 'Foo\nBar\n', that: 'Foo Bar\n' }
    this: |
      Foo
      Bar
    that: >
      Foo
      Bar

+表示保留文字块末尾的换行，-表示删除字符串末尾的换行。


    #{ s1: 'Foo\n', s2: 'Foo\n\n', s3: 'Foo' }
    s1: |
      Foo
    s2: |+
      Foo

    s3: |-
      Foo

## 引用

    defaults: &defaults
      adapter:  postgres
      host:     localhost

    development:
      database: myapp_development
      <<: *defaults

    test:
      database: myapp_test
      <<: *defaults

& 用来建立锚点（defaults），<< 表示合并到当前数据，* 用来引用锚点。

下面是另一个例子:

    # [ 'Steve', 'Clark', 'Steve' ]
    - &showell Steve 
    - Clark 
    - *showell 